# Hướng dẫn triển khai Chatbot (RAG) sử dụng Supabase + React

**Mục tiêu:** tạo một giao diện chat trên website React, cho phép người dùng hỏi về dữ liệu nội bộ lưu trong Supabase. Hệ thống sẽ dùng kỹ thuật *Retrieval-Augmented Generation (RAG)*: tìm đoạn liên quan bằng vector search rồi đưa vào prompt cho LLM trả lời.

> Tài liệu này là một *guide-to-implementation* — có các đoạn code mẫu (minh họa), schema DB, và các bước triển khai từ dev → staging → production.

---

## Tóm tắt kiến trúc (ngắn)

- **Supabase Postgres**: lưu dữ liệu chính (bảng, file) + extension `pgvector` để lưu embeddings.
- **Indexer** (background job): chia nhỏ văn bản → tạo embedding → lưu embedding + metadata vào bảng `documents_vectors`.
- **Backend / Edge Function**: nhận query từ frontend → tạo embedding query → vector-search → build prompt (kèm source snippets) → gọi LLM → trả về kết quả + nguồn.
- **Frontend (React)**: chat UI, hiển thị câu trả lời + nguồn, gửi feedback.

```
User (React) -> Backend API/Edge -> (1) Supabase vector search -> (2) LLM provider -> Backend -> React display
                      ^                                             |
                      |---------------------------------------------|
                             Indexer (batch/webhook) cập nhật vectors
```

---

## 1) Yêu cầu & tiền đề

- Tài khoản Supabase, project đã có DB và Storage
- React app (CRA / Vite / Next.js) hiện có code frontend
- Key cho LLM mà bạn chọn (OpenAI / Anthropic / Google Gemini) — **đặt ở backend**
- Node.js trên môi trường dev để chạy indexer và deploy Edge Function

---

## 2) Thiết kế dữ liệu (Postgres + pgvector)

> **Lưu ý:** `embedding` dimension phụ thuộc model bạn dùng. Ở dưới dùng `vector(<EMBED_DIM>)` — thay `<EMBED_DIM>` bằng kích thước embedding thực tế.

### 2.1. Cài extension và bảng lưu embeddings

```sql
-- bật extension pgvector (chạy trên DB supabase)
CREATE EXTENSION IF NOT EXISTS vector;

-- bảng lưu văn bản gốc (nếu bạn chưa có)
CREATE TABLE IF NOT EXISTS docs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text,         -- nguồn / tên file / bảng
  content text,        -- nội dung đoạn
  metadata jsonb,      -- bất kỳ metadata nào (table, row_id, url...)
  created_at timestamptz DEFAULT now()
);

-- bảng embeddings (có thể gộp vào docs nếu muốn)
CREATE TABLE IF NOT EXISTS doc_vectors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doc_id uuid REFERENCES docs(id) ON DELETE CASCADE,
  embedding vector,    -- vector(<EMBED_DIM>) nếu muốn cố định
  chunk text,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- index giúp search nhanh (ví dụ approximate)
CREATE INDEX IF NOT EXISTS idx_doc_vectors_embedding ON doc_vectors USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

**Ghi chú:** operator và index loại `ivfflat` cần tuning theo kích thước dữ liệu. Nếu bạn dùng Supabase managed, kiểm tra document pgvector tương ứng.

### 2.2. (Tùy chọn) Tạo function để match (gọi bằng RPC từ supabase-js)

```sql
CREATE OR REPLACE FUNCTION match_docs(query_embedding vector, match_count int)
RETURNS TABLE(doc_id uuid, chunk text, metadata jsonb, distance float)
AS $$
  SELECT doc_id, chunk, metadata, (embedding <-> query_embedding) as distance
  FROM doc_vectors
  ORDER BY distance
  LIMIT match_count;
$$ LANGUAGE sql STABLE;
```

> Thay `(<->)` bằng operator distance phù hợp (ví dụ euclidean). Điều chỉnh theo cách bạn muốn tính tương đồng (cosine/inner product...).

---

## 3) Indexer (đọc dữ liệu + tạo embeddings + ghi vào Supabase)

**Mục tiêu:** tách các docs lớn thành `chunks`, tạo embedding cho từng chunk, lưu vào `docs` + `doc_vectors`.

### 3.1. Mã mẫu (Node.js)

> Mẫu dưới sử dụng `@supabase/supabase-js` và `openai` (hoặc SDK tương tự). Đây là ví dụ minh họa — kiểm tra phiên bản SDK khi áp dụng.

```js
// scripts/indexer.js
import fs from 'fs';
import OpenAI from 'openai';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY; // secret
const OPENAI_KEY = process.env.OPENAI_API_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
const openai = new OpenAI({ apiKey: OPENAI_KEY });

// very simple chunker: split by paragraphs and keep under N chars
function chunkText(text, maxLen = 1000) {
  const paragraphs = text.split(/\n\n+/).map(p => p.trim()).filter(Boolean);
  const chunks = [];
  let cur = '';
  for (const p of paragraphs) {
    if ((cur + '\n\n' + p).length > maxLen) {
      if (cur) chunks.push(cur);
      cur = p;
    } else {
      cur = cur ? cur + '\n\n' + p : p;
    }
  }
  if (cur) chunks.push(cur);
  return chunks;
}

async function embedText(text) {
  const res = await openai.embeddings.create({
    model: 'text-embedding-3-small', // ví dụ, thay theo model bạn dùng
    input: text,
  });
  return res.data[0].embedding; // array of floats
}

async function indexFile(filePath, sourceName) {
  const text = fs.readFileSync(filePath, 'utf8');
  const chunks = chunkText(text, 1200);

  // create doc entry
  const { data: doc, error: docErr } = await supabase.from('docs').insert({
    source: sourceName,
    content: text.substring(0, 1000),
    metadata: { file: sourceName }
  }).select().single();
  if (docErr) throw docErr;

  for (const chunk of chunks) {
    const embedding = await embedText(chunk);
    // insert into doc_vectors
    const { error } = await supabase.from('doc_vectors').insert({
      doc_id: doc.id,
      embedding, // Supabase client handles arrays to `vector` if configured
      chunk,
      metadata: { source: sourceName }
    });
    if (error) console.error('Insert chunk error', error);
  }
}

// Usage: node scripts/indexer.js path/to/file.md "My File"
(async () => {
  const filePath = process.argv[2];
  const sourceName = process.argv[3] || filePath;
  await indexFile(filePath, sourceName);
  console.log('Indexing done');
})();
```

**Lưu ý:**

- Dùng `SERVICE_ROLE_KEY` khi index write trực tiếp vào bảng vectors. Tuyệt đối **không** dùng key này trên client.
- Chunking nên tinh chỉnh: theo token (tốt nhất) hơn là ký tự. Bạn có thể dùng `tiktoken`/tokenizer để chính xác.

---

## 4) Backend / Edge Function xử lý truy vấn chat

**Mục tiêu:** nhận `user query` → tạo embedding → gọi vector-search → build prompt => gọi LLM => trả về câu trả lời và sources.

### 4.1. Ví dụ Supabase Edge Function (Node)

```js
// functions/chat-handler/index.js (Edge Function)
import OpenAI from 'openai';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export default async function (req, res) {
  const { question, user_id } = await req.json();
  if (!question) return res.status(400).json({ error: 'Missing question' });

  // 1) embed question
  const emb = await openai.embeddings.create({ model: 'text-embedding-3-small', input: question });
  const qvec = emb.data[0].embedding;

  // 2) vector search via RPC
  const { data: matches, error } = await supabase.rpc('match_docs', { query_embedding: qvec, match_count: 5 });
  if (error) return res.status(500).json({ error });

  // 3) build context
  const context = matches.map(m => `Source: ${m.doc_id}\n${m.chunk}`).join('\n\n');

  const system = `You are an internal assistant. Answer briefly. Always cite sources by doc_id. If answer not found, say 'không tìm thấy thông tin'.`;

  const prompt = `${system}\n\nContext:\n${context}\n\nQuestion: ${question}`;

  // 4) call LLM
  const chatResp = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'system', content: system }, { role: 'user', content: prompt }],
    max_tokens: 512
  });

  const answer = chatResp.choices?.[0]?.message?.content || 'Không có câu trả lời.';

  return res.json({ answer, sources: matches });
}
```

**Ghi chú:**

- Thay đổi model & param theo plan/chi phí.
- `supabase.rpc('match_docs', ...)` là cách gợi ý; bạn có thể trực tiếp gọi SQL nếu muốn.
- Bảo mật: function dùng service role key, deploy trên Edge/Server, không đưa key ra client.

---

## 5) Frontend (React) — Chat UI cơ bản

### 5.1. Component Chat đơn giản

```jsx
// src/components/Chat.jsx
import { useState } from 'react';

export default function Chat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  async function send() {
    if (!input.trim()) return;
    const userMsg = { role: 'user', text: input };
    setMessages(m => [...m, userMsg]);
    setInput('');
    setLoading(true);

    try {
      const resp = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: userMsg.text })
      });
      const data = await resp.json();
      const botMsg = { role: 'assistant', text: data.answer, sources: data.sources };
      setMessages(m => [...m, botMsg]);
    } catch (err) {
      setMessages(m => [...m, { role: 'assistant', text: 'Lỗi hệ thống' }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="chat-root">
      <div className="messages">
        {messages.map((m, i) => (
          <div key={i} className={`msg ${m.role}`}>
            <div>{m.text}</div>
            {m.sources && (
              <div className="sources">Sources: {m.sources.map(s => s.doc_id).join(', ')}</div>
            )}
          </div>
        ))}
      </div>
      <div className="input-area">
        <input value={input} onChange={e => setInput(e.target.value)} />
        <button onClick={send} disabled={loading}>Send</button>
      </div>
    </div>
  );
}
```

### 5.2. Kết nối với Supabase Auth (tùy chọn)

- Nếu bạn muốn phân quyền theo user/tenant, dùng Supabase Auth ở frontend để login và kèm `accessToken` trong header khi gọi backend. Backend sẽ dùng thông tin này để filter vector search theo `user_id`.

---

## 6) Bảo mật & quyền truy cập (RLS, service keys)

1. **Service Role Key**: chỉ dùng trên server/edge function để write index và đọc mọi thứ; để trong env variables của server.
2. **Public anon key**: dùng trên client cho các thao tác không nhạy cảm (fetch user profile, storage public..)
3. **Row Level Security (RLS)**: nếu multi-tenant, bật RLS trên `docs`/`doc_vectors` và tạo policy cho phép user chỉ truy vấn theo tenant\_id.

Ví dụ policy (concept):

```sql
ALTER TABLE docs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "allow_tenant" ON docs FOR SELECT USING (metadata->>'tenant_id' = current_setting('
```
