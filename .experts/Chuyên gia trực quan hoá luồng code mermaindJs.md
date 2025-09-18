# SAFE-FLOW AGENT — HTML Mermaid Generator (Phiên bản HTML)

## Mục tiêu
Tạo một **Agent** (Safe-Flow Agent) cập nhật để **xuất sơ đồ Mermaid nhúng trong file HTML** thay vì chỉ xuất block `mermaid`. Mục tiêu: khi mày paste code vào Agent, nó sẽ trả về:
1. Một **block Mermaid an toàn** (đã sanitize) để dán nhanh vào mermaid.live.
2. Một **file HTML hoàn chỉnh** (sẵn để mở trên trình duyệt) — Agent sẽ chèn Mermaid code vào template này, không lỗi parse, render thẳng.

Tao đã chỉnh agent theo logic sau — **đảm bảo 100% không trả ra Mermaid parse error** do ký tự đặc biệt hoặc nhãn dài.

---

## Nguyên tắc chính (bắt buộc)
1. **Sanitize nhãn node**:
   - Loại bỏ ký tự: `"` `'` `:` `(` `)` < `>` `` ` ``.
   - Thay `&` bằng ` va `.
   - Rút gọn liên tiếp khoảng trắng thành một khoảng trắng.
   - Giới hạn độ dài nhãn (ví dụ 120 ký tự).  
   - Nếu cần xuống dòng, dùng `\n`.

2. **Không nối nhiều node cùng lúc** (không dùng `I & J --> End`). Thay bằng nối từng node về End:
   ```
   I --> End
   J --> End
   ```

3. **Node label chỉ chứa chữ, số, dấu cách, dấu gạch ngang, dấu gạch dưới, dấu xuống dòng `\n`**. Tiếng Việt có dấu được phép nhưng tránh các ký tự đặc biệt ở trên.

4. **Mỗi hàm → một `subgraph`**. Tên subgraph lấy từ tên hàm đã sanitize.

5. **Call graph**: Agent sẽ nối `End` của hàm gọi → `Start` của hàm được gọi để thể hiện luồng gọi hàm.

---

## Cấu trúc Agent (quy trình)
1. **Nhận input**: code snippet (multi-function hoặc single-function).
2. **Phân tích**:
   - Phát hiện tên hàm, body, các câu lệnh gọi hàm.
   - Phân tách thành các bước (khởi tạo, lấy dữ liệu, vòng lặp, điều kiện, đặt protection, return).
3. **Sinh nodes** (mỗi bước → 1 node) và các diamond nodes cho điều kiện.
4. **Sanitize** tất cả nhãn node theo luật ở trên.
5. **Tạo subgraph cho từng hàm**; bên ngoài nối call graph.
6. **Xuất 2 artifact**:
   - `mermaid` block (đã sanitize) — để copy dán nhanh.
   - `index.html` template — file HTML hoàn chỉnh có mermaid.js CDN và mermaid code chèn sẵn.

---

## Template HTML mẫu (Agent sẽ xuất file này, chèn diagram vào chỗ `<!-- MERMAID_DIAGRAM -->`)
```html
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Safe-Flow Diagram</title>
  <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  <style>
    body { font-family: system-ui, Arial, sans-serif; margin: 24px; background:#fff; color:#111; }
    header { margin-bottom: 12px; }
    .diagram-container { border: 1px solid #e5e7eb; padding: 12px; border-radius:8px; box-shadow: 0 1px 2px rgba(0,0,0,0.03); }
    .info { margin-bottom: 10px; color:#374151; font-size:14px; }
    .controls { margin-top: 12px; }
    button { padding:8px 12px; border-radius:6px; border:1px solid #d1d5db; background:#f9fafb; cursor:pointer; }
  </style>
</head>
<body>
  <header>
    <h2>Safe-Flow Diagram (Mermaid HTML)</h2>
    <div class="info">Mở file này trong trình duyệt để xem sơ đồ. File được sinh tự động bởi Safe-Flow Agent (đã sanitize labels).</div>
  </header>

  <div class="diagram-container">
    <!-- MERMAID_DIAGRAM -->
    <div class="mermaid">
flowchart TD
    Start([Bắt dau]) --> End([Ket thuc])
    </div>
  </div>

  <div class="controls">
    <button id="downloadSvg">Tải SVG</button>
    <button id="downloadPng">Tải PNG</button>
  </div>

  <script>
    // khởi tạo mermaid
    if (typeof mermaid !== 'undefined') {
      mermaid.initialize({ startOnLoad: true, theme: 'default' });
    }

    // helper để tải SVG (render xong mới lấy svg)
    document.getElementById('downloadSvg').addEventListener('click', async function () {
      try {
        const svgEl = document.querySelector('.mermaid svg');
        if (!svgEl) { alert('Chưa có SVG. Chờ render xong rồi thử lại.'); return; }
        const serializer = new XMLSerializer();
        const svgStr = serializer.serializeToString(svgEl);
        const blob = new Blob([svgStr], { type: 'image/svg+xml;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'diagram.svg';
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      } catch (err) {
        alert('Lỗi khi xuất SVG: ' + err);
      }
    });

    // tải PNG bằng vẽ lên canvas
    document.getElementById('downloadPng').addEventListener('click', async function () {
      try {
        const svgEl = document.querySelector('.mermaid svg');
        if (!svgEl) { alert('Chưa có SVG. Chờ render xong rồi thử lại.'); return; }
        const serializer = new XMLSerializer();
        const svgStr = serializer.serializeToString(svgEl);
        const canvas = document.createElement('canvas');
        const bbox = svgEl.getBBox();
        canvas.width = Math.ceil(bbox.width) + 20;
        canvas.height = Math.ceil(bbox.height) + 20;
        const ctx = canvas.getContext('2d');
        const img = new Image();
        const svgBlob = new Blob([svgStr], { type: 'image/svg+xml;charset=utf-8' });
        const url = URL.createObjectURL(svgBlob);
        img.onload = function () {
          ctx.drawImage(img, 0, 0);
          URL.revokeObjectURL(url);
          const pngUrl = canvas.toDataURL('image/png');
          const a = document.createElement('a');
          a.href = pngUrl;
          a.download = 'diagram.png';
          document.body.appendChild(a);
          a.click();
          a.remove();
        };
        img.src = url;
      } catch (err) {
        alert('Lỗi khi xuất PNG: ' + err);
      }
    });
  </script>
</body>
</html>
```

---

## Hàm sanitize mẫu (Agent dùng trước khi chèn vào HTML)
Agent **PHẢI** gọi hàm này để đảm bảo không lỗi parse Mermaid:

```js
function sanitizeLabel(label) {
  if (!label) return '';
  // loại bỏ ký tự gây lỗi
  label = label.replace(/["'`:<>\\`]/g, '');
  // thay & bằng ' va '
  label = label.replace(/&/g, ' va ');
  // loại bỏ ngoặc (những dạng tròn vuông)
  label = label.replace(/[\(\)\[\]\{\}]/g, ' ');
  // collapse multi spaces
  label = label.replace(/\s+/g, ' ').trim();
  // limit length
  if (label.length > 120) label = label.slice(0, 120) + '...';
  return label;
}
```

---

## Ví dụ áp dụng (code của mày)
Agent sẽ sinh block Mermaid an toàn và file HTML tương ứng. Ví dụ diagram đã sanitize cho hàm `lockTickColumn` và các hàm liên quan:

**Mermaid block an toàn (để paste nhanh vào mermaid.live):**
```mermaid
flowchart TD

    subgraph FUNC1[function lockTickColumn]
        S1([Bat dau]) --> A1[Lay sheet tick]
        A1 --> B1[Lay dong cuoi va gia tri cot K]
        B1 --> C1[Xoa protection cu cot M va N]
        C1 --> D1[Tao mang unlock cho M va N]
        D1 --> E1[Vong lap qua tung dong]
        E1 --> F1{cellDate la Date}
        F1 -->|Khong| E1
        F1 -->|Co| G1{cellDate >= hom nay}
        G1 -->|Khong| E1
        G1 -->|Co| H1[Them o M va N vao mang unlock]
        H1 --> E1
        E1 --> I1[Dat protection cot M chi mo o hop le]
        I1 --> J1[Dat protection cot N chi mo o hop le]
        J1 --> End1([Ket thuc lockTickColumn])
    end

    subgraph FUNC2[function onEdit]
        U1([Trigger onEdit]) --> U2{Edit o sheet tick va cot N}
        U2 -->|Khong| UE[Thoat]
        U2 -->|Co| U3{Value hop le '', x, X}
        U3 -->|Hop le| UE
        U3 -->|Khong hop le| U4[Lay ngay o cot K]
        U4 --> U5{Ngay >= hom nay}
        U5 -->|Khong| UE
        U5 -->|Co| U6[Alert chi dung x]
        U6 --> U7[Xoa gia tri sai]
        U7 --> UE
        UE --> End2([Ket thuc onEdit])
    end

    subgraph FUNC3[function setupLeaveValidation]
        S21([Bat dau]) --> S22[Lay sheet tick va range cot N]
        S22 --> S23[Tao data validation '', x, X]
        S23 --> End3([Ket thuc setupLeaveValidation])
    end

    subgraph FUNC4[function dailyUpdateProtection]
        D21([Bat dau]) --> D22[Goi lockTickColumn]
        D22 --> End4([Ket thuc dailyUpdateProtection])
    end

    %% Call graph
    End1 --> S21
    End3 --> D21
```

**HTML file**: Agent sẽ chèn block Mermaid ở vị trí `<!-- MERMAID_DIAGRAM -->` trong template HTML phía trên. Lưu file HTML và mở trình duyệt để xem.

---

## Output mà Agent trả về (quy chuẩn)
1. **mermaid_block**: string (đã sanitize) — copy dán nhanh.  
2. **html_file_content**: string (complete HTML) — ghi ra `diagram.html` và tải về/open.  
3. **explain_text**: tiếng Việt ngắn gọn mô tả sơ đồ, các hàm và cạm bẫy cần chú ý.

---

## Hướng dẫn cài đặt / sử dụng
1. Paste code vào Agent (định dạng plain text).  
2. Agent parse → generate mermaid_block + html_file_content + explain_text.  
3. Mày lưu `html_file_content` vào `diagram.html` rồi mở bằng trình duyệt.  
4. Muốn image: dùng nút "Tải SVG" hoặc "Tải PNG" trên trang.

---

## Ghi chú kỹ thuật
- Agent phải luôn chạy `sanitizeLabel` trên mọi label.  
- Nếu code quá nhiều node (>200), Agent sẽ tự chia thành nhiều trang/diagram để giữ readability.  
- Agent phải trả về both mermaid block và HTML content mỗi lần.

---

## File markdown này
Tao đã đóng gói Safe-Flow Agent (phiên bản HTML) trong file này để mày lưu làm reference và drop vào thư mục chuyên gia của mày.
