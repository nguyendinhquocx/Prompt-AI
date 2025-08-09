# Complete RAG Integration Guide: From Supabase to Production

## 📋 **Table of Contents**

1. [Overview & Architecture](#overview--architecture)
2. [Simple RAG Implementation](#simple-rag-implementation)
3. [Multi-Source RAG Implementation](#multi-source-rag-implementation)
4. [Production Deployment](#production-deployment)
5. [Optimization & Monitoring](#optimization--monitoring)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 **Overview & Architecture**

### **What is RAG (Retrieval-Augmented Generation)?**

RAG combines information retrieval với generative AI để tạo responses dựa trên specific knowledge base thay vì chỉ dựa vào pre-trained knowledge.

```
Traditional AI: User Query → LLM → Generic Response
RAG AI: User Query → Search Relevant Data → LLM + Context → Specific Response
```

### **Simple RAG vs Multi-Source RAG**

| Feature | Simple RAG | Multi-Source RAG |
|---------|------------|------------------|
| **Data Sources** | Chỉ database | Database + Code + Docs + APIs |
| **Complexity** | Low | High |
| **Setup Time** | 1-2 weeks | 4-6 weeks |
| **Capabilities** | Basic Q&A | Business Intelligence |
| **Cost** | $2-10/month | $25-100/month |

---

## 🔄 **Simple RAG Implementation**

### **Phase 1: Environment Setup**

#### **1.1. Dependencies Installation**
```bash
# Core dependencies
npm install @supabase/supabase-js openai
npm install @xenova/transformers  # For local embeddings (optional)
npm install langchain             # For advanced text processing

# React UI dependencies
npm install @heroicons/react tailwindcss
npm install react-markdown        # For formatted responses
```

#### **1.2. Environment Variables**
```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# LLM Provider (choose one)
OPENAI_API_KEY=your_openai_key
GOOGLE_AI_API_KEY=your_google_key
ANTHROPIC_API_KEY=your_anthropic_key
```

### **Phase 2: Database Setup**

#### **2.1. Enable pgvector Extension**
```sql
-- Run in Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS vector;
```

#### **2.2. Create Core Tables**
```sql
-- Documents table
CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  source text,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Document chunks với embeddings
CREATE TABLE document_chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES documents(id) ON DELETE CASCADE,
  chunk_text text NOT NULL,
  chunk_index integer NOT NULL,
  embedding vector(1536), -- OpenAI embedding dimension
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- Create index for vector similarity search
CREATE INDEX ON document_chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Chat history (optional)
CREATE TABLE chat_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text,
  session_id text NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  sources jsonb DEFAULT '[]',
  created_at timestamptz DEFAULT now()
);
```

#### **2.3. Vector Search Function**
```sql
-- Vector similarity search function
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.8,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  document_id uuid,
  chunk_text text,
  metadata jsonb,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    document_chunks.id,
    document_chunks.document_id,
    document_chunks.chunk_text,
    document_chunks.metadata,
    1 - (document_chunks.embedding <=> query_embedding) as similarity
  FROM document_chunks
  WHERE 1 - (document_chunks.embedding <=> query_embedding) > match_threshold
  ORDER BY document_chunks.embedding <=> query_embedding
  LIMIT match_count;
$$;
```

### **Phase 3: Data Indexing System**

#### **3.1. Basic Text Chunker**
```javascript
// utils/textChunker.js
export class CodeAnalyzer {
  constructor() {
    this.businessLogicPatterns = [
      /calculate/i,
      /compute/i,
      /process/i,
      /validate/i,
      /transform/i,
      /generate/i,
      /predict/i,
      /analyze/i
    ];
    
    this.healthcarePatterns = [
      /patient/i,
      /doctor/i,
      /appointment/i,
      /medical/i,
      /health/i,
      /diagnosis/i,
      /treatment/i,
      /prescription/i
    ];
  }

  async analyzeProject(projectPath) {
    const results = {
      functions: [],
      components: [],
      businessRules: [],
      apiEndpoints: []
    };

    await this.walkDirectory(projectPath, async (filePath) => {
      if (this.isCodeFile(filePath)) {
        const analysis = await this.analyzeFile(filePath);
        results.functions.push(...analysis.functions);
        results.components.push(...analysis.components);
        results.businessRules.push(...analysis.businessRules);
        results.apiEndpoints.push(...analysis.apiEndpoints);
      }
    });

    return results;
  }

  async analyzeFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const results = {
      functions: [],
      components: [],
      businessRules: [],
      apiEndpoints: []
    };

    try {
      const ast = parse(content, {
        sourceType: 'module',
        plugins: ['jsx', 'typescript', 'decorators-legacy']
      });

      traverse.default(ast, {
        // Function declarations
        FunctionDeclaration: (path) => {
          const func = this.extractFunction(path.node, filePath, content);
          if (func) results.functions.push(func);
        },

        // Arrow functions và function expressions
        VariableDeclarator: (path) => {
          if (t.isArrowFunctionExpression(path.node.init) || 
              t.isFunctionExpression(path.node.init)) {
            const func = this.extractFunction(path.node, filePath, content);
            if (func) results.functions.push(func);
          }
        },

        // React components
        ExportDefaultDeclaration: (path) => {
          if (t.isFunctionDeclaration(path.node.declaration) ||
              t.isArrowFunctionExpression(path.node.declaration)) {
            const component = this.extractComponent(path.node, filePath, content);
            if (component) results.components.push(component);
          }
        },

        // API routes (Next.js pattern)
        ObjectMethod: (path) => {
          if (['get', 'post', 'put', 'delete'].includes(path.node.key.name?.toLowerCase())) {
            const endpoint = this.extractAPIEndpoint(path.node, filePath);
            if (endpoint) results.apiEndpoints.push(endpoint);
          }
        }
      });

    } catch (error) {
      console.warn(`Could not parse ${filePath}:`, error.message);
    }

    return results;
  }

  extractFunction(node, filePath, content) {
    const name = node.id?.name || node.key?.name || 'anonymous';
    const start = node.start;
    const end = node.end;
    const implementation = content.slice(start, end);

    // Extract docstring/comments
    const docstring = this.extractDocstring(node, content);
    
    // Determine if this is business logic
    const isBusinessLogic = this.isBusinessLogic(name, implementation, docstring);
    
    // Extract parameters
    const parameters = this.extractParameters(node);

    // Extract business logic tags
    const businessTags = this.extractBusinessTags(name, implementation, docstring);

    return {
      name,
      filePath,
      signature: this.generateSignature(name, parameters),
      implementation,
      docstring,
      parameters,
      isBusinessLogic,
      businessTags,
      lineStart: this.getLineNumber(content, start),
      lineEnd: this.getLineNumber(content, end)
    };
  }

  extractComponent(node, filePath, content) {
    const name = node.declaration?.id?.name || path.basename(filePath, path.extname(filePath));
    const implementation = content.slice(node.start, node.end);
    
    // Extract props
    const props = this.extractComponentProps(node);
    
    // Extract JSX structure
    const jsxElements = this.extractJSXElements(node);

    return {
      name,
      filePath,
      type: 'react_component',
      implementation,
      props,
      jsxElements,
      isPage: filePath.includes('/pages/') || filePath.includes('/app/'),
      isComponent: filePath.includes('/components/')
    };
  }

  extractAPIEndpoint(node, filePath) {
    const method = node.key.name.toUpperCase();
    const routePath = this.extractRoutePath(filePath);
    
    return {
      method,
      path: routePath,
      filePath,
      implementation: node.value ? node.value.toString() : '',
      parameters: this.extractAPIParameters(node),
      middleware: this.extractMiddleware(node)
    };
  }

  isBusinessLogic(name, implementation, docstring) {
    const text = `${name} ${implementation} ${docstring}`.toLowerCase();
    
    return this.businessLogicPatterns.some(pattern => pattern.test(text)) ||
           this.healthcarePatterns.some(pattern => pattern.test(text));
  }

  extractBusinessTags(name, implementation, docstring) {
    const text = `${name} ${implementation} ${docstring}`.toLowerCase();
    const tags = [];

    // Healthcare specific tags
    if (/patient|appointment|booking/.test(text)) tags.push('patient_management');
    if (/doctor|physician|staff/.test(text)) tags.push('staff_management');
    if (/calculate|compute|formula/.test(text)) tags.push('calculation');
    if (/validate|check|verify/.test(text)) tags.push('validation');
    if (/report|analytics|statistics/.test(text)) tags.push('reporting');
    if (/schedule|calendar|time/.test(text)) tags.push('scheduling');
    if (/payment|billing|invoice/.test(text)) tags.push('billing');

    return tags;
  }

  extractDocstring(node, content) {
    // Look for comments before the function
    const lines = content.split('\n');
    const startLine = this.getLineNumber(content, node.start);
    
    let docstring = '';
    for (let i = startLine - 2; i >= 0; i--) {
      const line = lines[i].trim();
      if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) {
        docstring = line + '\n' + docstring;
      } else if (line === '') {
        continue;
      } else {
        break;
      }
    }

    return docstring.trim();
  }

  extractParameters(node) {
    const params = [];
    
    if (node.params) {
      node.params.forEach(param => {
        if (t.isIdentifier(param)) {
          params.push({ name: param.name, type: 'any' });
        } else if (t.isObjectPattern(param)) {
          param.properties.forEach(prop => {
            if (t.isObjectProperty(prop) && t.isIdentifier(prop.key)) {
              params.push({ name: prop.key.name, type: 'object_prop' });
            }
          });
        }
      });
    }

    return params;
  }

  generateSignature(name, parameters) {
    const paramStr = parameters.map(p => p.name).join(', ');
    return `${name}(${paramStr})`;
  }

  getLineNumber(content, position) {
    return content.slice(0, position).split('\n').length;
  }

  isCodeFile(filePath) {
    const extensions = ['.js', '.jsx', '.ts', '.tsx', '.vue', '.py'];
    return extensions.some(ext => filePath.endsWith(ext));
  }

  async walkDirectory(dir, callback) {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      
      if (stat.isDirectory() && !this.shouldSkipDirectory(file)) {
        await this.walkDirectory(filePath, callback);
      } else if (stat.isFile()) {
        await callback(filePath);
      }
    }
  }

  shouldSkipDirectory(dirName) {
    const skipDirs = ['node_modules', '.git', '.next', 'dist', 'build', '.cache'];
    return skipDirs.includes(dirName);
  }

  extractRoutePath(filePath) {
    // Next.js API route pattern
    if (filePath.includes('/api/')) {
      const apiPath = filePath.split('/api/')[1];
      return '/api/' + apiPath.replace(/\.(js|ts)$/, '');
    }
    
    return filePath;
  }

  extractAPIParameters(node) {
    // Analyze function body for req.body, req.query, etc.
    const params = [];
    // This would require more sophisticated AST traversal
    return params;
  }

  extractMiddleware(node) {
    // Extract middleware usage
    return [];
  }

  extractComponentProps(node) {
    // Extract React component props
    const props = [];
    // This would require analyzing the function parameters
    return props;
  }

  extractJSXElements(node) {
    // Extract JSX structure
    const elements = [];
    // This would require JSX-specific traversal
    return elements;
  }
}
```

#### **2.2. Multi-Source Indexer**
```javascript
// utils/multiSourceIndexer.js
import { CodeAnalyzer } from './codeAnalyzer.js';
import { EmbeddingGenerator } from './embeddings.js';
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

export class MultiSourceIndexer {
  constructor() {
    this.supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    );
    this.codeAnalyzer = new CodeAnalyzer();
    this.embedder = new EmbeddingGenerator('openai');
  }

  async indexProject(projectPath) {
    console.log('🚀 Starting multi-source indexing...');
    
    // 1. Index database schema
    await this.indexDatabaseSchema();
    
    // 2. Index code
    await this.indexCodebase(projectPath);
    
    // 3. Index documentation
    await this.indexDocumentation(path.join(projectPath, 'docs'));
    
    // 4. Index business rules
    await this.indexBusinessRules(projectPath);
    
    // 5. Index API endpoints
    await this.indexAPIEndpoints(projectPath);
    
    console.log('✅ Multi-source indexing completed!');
  }

  async indexDatabaseSchema() {
    console.log('📊 Indexing database schema...');
    
    // Get table information
    const { data: tables } = await this.supabase
      .from('information_schema.tables')
      .select('table_name, table_comment')
      .eq('table_schema', 'public');

    for (const table of tables) {
      // Get column information
      const { data: columns } = await this.supabase
        .from('information_schema.columns')
        .select('column_name, data_type, is_nullable, column_default, column_comment')
        .eq('table_name', table.table_name);

      const schemaDoc = this.generateSchemaDocumentation(table, columns);
      const embedding = await this.embedder.generateEmbedding(schemaDoc);

      await this.supabase
        .from('knowledge_base')
        .insert({
          source_type: 'database',
          source_path: `schema:${table.table_name}`,
          title: `Table: ${table.table_name}`,
          content: schemaDoc,
          embedding,
          metadata: {
            table_name: table.table_name,
            column_count: columns.length,
            columns: columns.map(c => c.column_name)
          }
        });
    }
  }

  async indexCodebase(projectPath) {
    console.log('💻 Indexing codebase...');
    
    const analysis = await this.codeAnalyzer.analyzeProject(projectPath);
    
    // Index functions
    for (const func of analysis.functions) {
      if (func.isBusinessLogic) {
        const docContent = this.generateFunctionDocumentation(func);
        const embedding = await this.embedder.generateEmbedding(docContent);

        await this.supabase
          .from('code_functions')
          .insert({
            file_path: func.filePath,
            function_name: func.name,
            function_signature: func.signature,
            docstring: func.docstring,
            implementation: func.implementation,
            business_logic_tags: func.businessTags,
            embedding,
            metadata: {
              parameters: func.parameters,
              line_start: func.lineStart,
              line_end: func.lineEnd
            }
          });
      }
    }

    // Index components
    for (const component of analysis.components) {
      const docContent = this.generateComponentDocumentation(component);
      const embedding = await this.embedder.generateEmbedding(docContent);

      await this.supabase
        .from('knowledge_base')
        .insert({
          source_type: 'code',
          source_path: component.filePath,
          title: `Component: ${component.name}`,
          content: docContent,
          embedding,
          metadata: {
            type: 'react_component',
            props: component.props,
            is_page: component.isPage
          }
        });
    }
  }

  async indexDocumentation(docsPath) {
    if (!fs.existsSync(docsPath)) return;
    
    console.log('📚 Indexing documentation...');
    
    await this.walkDirectory(docsPath, async (filePath) => {
      if (filePath.endsWith('.md') || filePath.endsWith('.txt')) {
        const content = fs.readFileSync(filePath, 'utf8');
        const title = path.basename(filePath, path.extname(filePath));
        
        // Split into sections if it's a large document
        const sections = this.splitDocumentSections(content);
        
        for (const section of sections) {
          const embedding = await this.embedder.generateEmbedding(section.content);
          
          await this.supabase
            .from('knowledge_base')
            .insert({
              source_type: 'documentation',
              source_path: filePath,
              title: section.title || title,
              content: section.content,
              embedding,
              metadata: {
                file_type: path.extname(filePath),
                section_index: section.index
              }
            });
        }
      }
    });
  }

  async indexBusinessRules(projectPath) {
    console.log('⚖️ Indexing business rules...');
    
    // Look for business rules in config files, comments, etc.
    const rulesPath = path.join(projectPath, 'business-rules.json');
    
    if (fs.existsSync(rulesPath)) {
      const rules = JSON.parse(fs.readFileSync(rulesPath, 'utf8'));
      
      for (const rule of rules) {
        const ruleDoc = this.generateBusinessRuleDocumentation(rule);
        const embedding = await this.embedder.generateEmbedding(ruleDoc);
        
        await this.supabase
          .from('business_rules')
          .insert({
            rule_name: rule.name,
            description: rule.description,
            rule_type: rule.type,
            implementation: rule.implementation,
            related_entities: rule.entities,
            embedding
          });
      }
    }
  }

  async indexAPIEndpoints(projectPath) {
    console.log('🔌 Indexing API endpoints...');
    
    const analysis = await this.codeAnalyzer.analyzeProject(projectPath);
    
    for (const endpoint of analysis.apiEndpoints) {
      const docContent = this.generateAPIDocumentation(endpoint);
      const embedding = await this.embedder.generateEmbedding(docContent);
      
      await this.supabase
        .from('api_endpoints')
        .insert({
          endpoint_path: endpoint.path,
          method: endpoint.method,
          description: docContent,
          parameters: { params: endpoint.parameters },
          examples: { implementation: endpoint.implementation },
          embedding
        });
    }
  }

  generateSchemaDocumentation(table, columns) {
    let doc = `Database Table: ${table.table_name}\n\n`;
    
    if (table.table_comment) {
      doc += `Description: ${table.table_comment}\n\n`;
    }
    
    doc += 'Columns:\n';
    for (const col of columns) {
      doc += `- ${col.column_name}: ${col.data_type}`;
      if (col.column_comment) {
        doc += ` - ${col.column_comment}`;
      }
      doc += '\n';
    }
    
    return doc;
  }

  generateFunctionDocumentation(func) {
    let doc = `Function: ${func.name}\n\n`;
    
    if (func.docstring) {
      doc += `Description: ${func.docstring}\n\n`;
    }
    
    doc += `Signature: ${func.signature}\n\n`;
    
    if (func.parameters.length > 0) {
      doc += 'Parameters:\n';
      for (const param of func.parameters) {
        doc += `- ${param.name}: ${param.type}\n`;
      }
      doc += '\n';
    }
    
    if (func.businessTags.length > 0) {
      doc += `Business Logic: ${func.businessTags.join(', ')}\n\n`;
    }
    
    doc += `File: ${func.filePath}\n`;
    doc += `Lines: ${func.lineStart}-${func.lineEnd}\n\n`;
    
    // Include implementation for better context
    doc += `Implementation:\n${func.implementation}`;
    
    return doc;
  }

  generateComponentDocumentation(component) {
    let doc = `React Component: ${component.name}\n\n`;
    doc += `File: ${component.filePath}\n`;
    doc += `Type: ${component.isPage ? 'Page' : 'Component'}\n\n`;
    
    if (component.props.length > 0) {
      doc += 'Props:\n';
      for (const prop of component.props) {
        doc += `- ${prop.name}: ${prop.type}\n`;
      }
      doc += '\n';
    }
    
    return doc;
  }

  generateBusinessRuleDocumentation(rule) {
    let doc = `Business Rule: ${rule.name}\n\n`;
    doc += `Description: ${rule.description}\n\n`;
    doc += `Type: ${rule.type}\n\n`;
    
    if (rule.implementation) {
      doc += `Implementation: ${JSON.stringify(rule.implementation, null, 2)}\n\n`;
    }
    
    if (rule.entities) {
      doc += `Related Entities: ${rule.entities.join(', ')}\n`;
    }
    
    return doc;
  }

  generateAPIDocumentation(endpoint) {
    let doc = `API Endpoint: ${endpoint.method} ${endpoint.path}\n\n`;
    doc += `File: ${endpoint.filePath}\n\n`;
    
    if (endpoint.parameters.length > 0) {
      doc += 'Parameters:\n';
      for (const param of endpoint.parameters) {
        doc += `- ${param.name}: ${param.type}\n`;
      }
      doc += '\n';
    }
    
    return doc;
  }

  splitDocumentSections(content) {
    const sections = [];
    const lines = content.split('\n');
    let currentSection = { title: null, content: '', index: 0 };
    
    for (const line of lines) {
      if (line.match(/^#{1,3}\s/)) {
        // New section
        if (currentSection.content.trim()) {
          sections.push({ ...currentSection });
        }
        currentSection = {
          title: line.replace(/^#+\s/, ''),
          content: line + '\n',
          index: sections.length
        };
      } else {
        currentSection.content += line + '\n';
      }
    }
    
    if (currentSection.content.trim()) {
      sections.push(currentSection);
    }
    
    return sections;
  }

  async walkDirectory(dir, callback) {
    if (!fs.existsSync(dir)) return;
    
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      
      if (stat.isDirectory()) {
        await this.walkDirectory(filePath, callback);
      } else if (stat.isFile()) {
        await callback(filePath);
      }
    }
  }
}
```

### **Phase 3: Advanced Query Engine**

#### **3.1. Intelligent Query Router**
```javascript
// utils/queryRouter.js
import { EmbeddingGenerator } from './embeddings.js';
import { createClient } from '@supabase/supabase-js';

export class IntelligentQueryRouter {
  constructor() {
    this.supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    );
    this.embedder = new EmbeddingGenerator('openai');
  }

  async analyzeQuery(question) {
    const analysisPrompt = `
Analyze this query and determine what types of knowledge sources are needed:

Query: "${question}"

Return JSON with:
{
  "intent": "data_query|calculation|explanation|prediction|comparison",
  "entities": ["entity1", "entity2"],
  "sources_needed": ["database", "code", "documentation", "business_rules"],
  "complexity": "simple|medium|complex",
  "requires_calculation": true/false,
  "requires_business_logic": true/false,
  "table_hints": ["table1", "table2"],
  "function_hints": ["function1", "function2"]
}
`;

    // Use LLM to analyze the query
    const analysis = await this.callLLM(analysisPrompt);
    return JSON.parse(analysis);
  }

  async routeQuery(question) {
    const analysis = await this.analyzeQuery(question);
    const queryEmbedding = await this.embedder.generateEmbedding(question);
    
    const context = {
      database: [],
      code: [],
      documentation: [],
      businessRules: []
    };

    // Route to appropriate sources based on analysis
    if (analysis.sources_needed.includes('database')) {
      context.database = await this.searchDatabase(queryEmbedding, analysis);
    }

    if (analysis.sources_needed.includes('code')) {
      context.code = await this.searchCode(queryEmbedding, analysis);
    }

    if (analysis.sources_needed.includes('documentation')) {
      context.documentation = await this.searchDocumentation(queryEmbedding);
    }

    if (analysis.sources_needed.includes('business_rules')) {
      context.businessRules = await this.searchBusinessRules(queryEmbedding);
    }

    return { analysis, context };
  }

  async searchDatabase(queryEmbedding, analysis) {
    // Search relevant database schema và data
    const { data: schemaMatches } = await this.supabase
      .rpc('search_knowledge_multi_source', {
        query_embedding: queryEmbedding,
        source_types: ['database'],
        match_count: 5
      });

    // If we have table hints, also get actual data
    const dataContext = [];
    if (analysis.table_hints && analysis.table_hints.length > 0) {
      for (const table of analysis.table_hints) {
        try {
          const { data: sampleData } = await this.supabase
            .from(table)
            .select('*')
            .limit(3);
          
          if (sampleData) {
            dataContext.push({
              table,
              sample_data: sampleData,
              type: 'data_sample'
            });
          }
        } catch (error) {
          console.warn(`Could not fetch sample from ${table}:`, error.message);
        }
      }
    }

    return { schema: schemaMatches, data: dataContext };
  }

  async searchCode(queryEmbedding, analysis) {
    const { data: codeMatches } = await this.supabase
      .rpc('search_code_functions', {
        query_embedding: queryEmbedding,
        business_tags: analysis.function_hints || [],
        match_count: 5
      });

    return codeMatches;
  }

  async searchDocumentation(queryEmbedding) {
    const { data: docMatches } = await this.supabase
      .rpc('search_knowledge_multi_source', {
        query_embedding: queryEmbedding,
        source_types: ['documentation'],
        match_count: 3
      });

    return docMatches;
  }

  async searchBusinessRules(queryEmbedding) {
    const { data: ruleMatches } = await this.supabase
      .from('business_rules')
      .select('*')
      .order('embedding <=> $1', { 
        params: [queryEmbedding] 
      })
      .limit(3);

    return ruleMatches;
  }

  async callLLM(prompt) {
    // Implementation depends on your LLM provider
    // This is a placeholder - implement based on your chosen provider
    return '{}';
  }
}
```

#### **3.2. Advanced Response Generator**
```javascript
// utils/responseGenerator.js
import OpenAI from 'openai';

export class AdvancedResponseGenerator {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
  }

  async generateResponse(question, context, analysis) {
    const systemPrompt = this.buildSystemPrompt(context, analysis);
    const userPrompt = this.buildUserPrompt(question, context);

    const completion = await this.openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      max_tokens: 2000,
      temperature: 0.1
    });

    const response = completion.choices[0].message.content;
    
    return {
      answer: response,
      sources: this.extractSources(context),
      analysis,
      confidence: this.calculateConfidence(context)
    };
  }

  buildSystemPrompt(context, analysis) {
    let prompt = `You are an advanced AI assistant for a healthcare management system with access to multiple knowledge sources.

Your capabilities:
- Database query and analysis
- Code understanding and business logic explanation
- Documentation reference
- Business rule application
- Calculation and prediction

Guidelines:
1. Always cite your sources specifically
2. If you need to perform calculations, show your work
3. If information is not available, say so clearly
4. Provide actionable insights when possible
5. Use business logic from code when making recommendations

Query Analysis:
- Intent: ${analysis.intent}
- Complexity: ${analysis.complexity}
- Requires Calculation: ${analysis.requires_calculation}
- Requires Business Logic: ${analysis.requires_business_logic}

Available Knowledge Sources:`;

    if (context.database?.schema?.length > 0) {
      prompt += `

DATABASE SCHEMA:
${context.database.schema.map(s => `Table: ${s.title}\n${s.content}`).join('\n\n')}`;
    }

    if (context.database?.data?.length > 0) {
      prompt += `

SAMPLE DATA:
${context.database.data.map(d => `Table: ${d.table}\nSample: ${JSON.stringify(d.sample_data, null, 2)}`).join('\n\n')}`;
    }

    if (context.code?.length > 0) {
      prompt += `

BUSINESS LOGIC FUNCTIONS:
${context.code.map(c => `Function: ${c.function_name}\nFile: ${c.file_path}\nTags: ${c.business_logic_tags?.join(', ')}\nImplementation: ${c.implementation.slice(0, 500)}...`).join('\n\n')}`;
    }

    if (context.documentation?.length > 0) {
      prompt += `

DOCUMENTATION:
${context.documentation.map(d => `${d.title}:\n${d.content}`).join('\n\n')}`;
    }

    if (context.businessRules?.length > 0) {
      prompt += `

BUSINESS RULES:
${context.businessRules.map(r => `Rule: ${r.rule_name}\nDescription: ${r.description}\nType: ${r.rule_type}`).join('\n\n')}`;
    }

    return prompt;
  }

  buildUserPrompt(question, context) {
    return `Please answer this question using the provided knowledge sources:

Question: ${question}

Requirements:
1. Provide a comprehensive answer
2. Show calculations if needed
3. Cite specific sources
4. Include recommendations if appropriate
5. Format response clearly for healthcare professionals`;
  }

  extractSources(context) {
    const sources = [];

    if (context.database?.schema) {
      sources.push(...context.database.schema.map(s => ({
        type: 'database_schema',
        title: s.title,
        similarity: s.similarity
      })));
    }

    if (context.database?.data) {
      sources.push(...context.database.data.map(d => ({
        type: 'database_data',
        title: `Table: ${d.table}`,
        table: d.table
      })));
    }

    if (context.code) {
      sources.push(...context.code.map(c => ({
        type: 'code_function',
        title: `Function: ${c.function_name}`,
        file: c.file_path,
        similarity: c.similarity
      })));
    }

    if (context.documentation) {
      sources.push(...context.documentation.map(d => ({
        type: 'documentation',
        title: d.title,
        similarity: d.similarity
      })));
    }

    if (context.businessRules) {
      sources.push(...context.businessRules.map(r => ({
        type: 'business_rule',
        title: r.rule_name,
        rule_type: r.rule_type
      })));
    }

    return sources;
  }

  calculateConfidence(context) {
    let confidence = 0;
    let sourceCount = 0;

    // Calculate confidence based on available sources
    if (context.database?.schema?.length > 0) {
      confidence += context.database.schema.reduce((acc, s) => acc + s.similarity, 0) / context.database.schema.length;
      sourceCount++;
    }

    if (context.code?.length > 0) {
      confidence += context.code.reduce((acc, c) => acc + c.similarity, 0) / context.code.length;
      sourceCount++;
    }

    if (context.documentation?.length > 0) {
      confidence += context.documentation.reduce((acc, d) => acc + d.similarity, 0) / context.documentation.length;
      sourceCount++;
    }

    if (context.businessRules?.length > 0) {
      confidence += 0.8; // Business rules are generally high confidence
      sourceCount++;
    }

    return sourceCount > 0 ? confidence / sourceCount : 0;
  }
}
```

#### **3.3. Multi-Source Chat API**
```javascript
// pages/api/chat-advanced.js
import { IntelligentQueryRouter } from '../../utils/queryRouter';
import { AdvancedResponseGenerator } from '../../utils/responseGenerator';

const router = new IntelligentQueryRouter();
const generator = new AdvancedResponseGenerator();

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { question, sessionId, userId, context: userContext = {} } = req.body;

    if (!question) {
      return res.status(400).json({ error: 'Question is required' });
    }

    console.log(`Processing query: ${question}`);

    // 1. Route query to appropriate sources
    const { analysis, context } = await router.routeQuery(question);

    console.log(`Query analysis:`, analysis);

    // 2. Generate intelligent response
    const response = await generator.generateResponse(question, context, analysis);

    // 3. Log interaction for analytics
    await logInteraction({
      userId,
      sessionId,
      question,
      analysis,
      response,
      sources_used: response.sources.length
    });

    res.json({
      answer: response.answer,
      sources: response.sources,
      analysis: response.analysis,
      confidence: response.confidence,
      sessionId
    });

  } catch (error) {
    console.error('Advanced chat API error:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

async function logInteraction(data) {
  try {
    // Log to analytics table
    await supabase.from('chat_analytics').insert({
      user_id: data.userId,
      session_id: data.sessionId,
      question: data.question,
      intent: data.analysis.intent,
      complexity: data.analysis.complexity,
      sources_used: data.sources_used,
      confidence_score: data.response.confidence,
      response_length: data.response.answer.length,
      created_at: new Date()
    });
  } catch (error) {
    console.warn('Failed to log interaction:', error);
  }
}
```

### **Phase 4: Advanced Frontend Components**

#### **4.1. Multi-Source Chat Interface**
```jsx
// components/AdvancedChat.jsx
import { useState, useEffect, useRef } from 'react';
import { ChartBarIcon, CodeBracketIcon, DocumentTextIcon, CogIcon } from '@heroicons/react/24/outline';

export default function AdvancedChat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [sessionId] = useState(() => Math.random().toString(36).substr(2, 9));
  const [showSources, setShowSources] = useState(true);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(scrollToBottom, [messages]);

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage = { 
      role: 'user', 
      content: input, 
      timestamp: Date.now() 
    };
    
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch('/api/chat-advanced', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          question: input,
          sessionId,
          userId: 'current-user'
        })
      });

      const data = await response.json();

      if (response.ok) {
        const assistantMessage = {
          role: 'assistant',
          content: data.answer,
          sources: data.sources,
          analysis: data.analysis,
          confidence: data.confidence,
          timestamp: Date.now()
        };
        setMessages(prev => [...prev, assistantMessage]);
      } else {
        throw new Error(data.error);
      }
    } catch (error) {
      const errorMessage = {
        role: 'assistant',
        content: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        error: true,
        timestamp: Date.now()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const getSourceIcon = (sourceType) => {
    switch (sourceType) {
      case 'database_schema':
      case 'database_data':
        return <ChartBarIcon className="w-4 h-4" />;
      case 'code_function':
        return <CodeBracketIcon className="w-4 h-4" />;
      case 'documentation':
        return <DocumentTextIcon className="w-4 h-4" />;
      case 'business_rule':
        return <CogIcon className="w-4 h-4" />;
      default:
        return <DocumentTextIcon className="w-4 h-4" />;
    }
  };

  const getConfidenceColor = (confidence) => {
    if (confidence >= 0.8) return 'text-green-600';
    if (confidence >= 0.6) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getSuggestedQuestions = () => [
    "Số người khám hôm nay là bao nhiêu?",
    "Công ty nào có số lượng nhân viên khám nhiều nhất?",
    "Làm thế nào để tính capacity bác sĩ siêu âm?",
    "Quy trình booking lịch khám như thế nào?",
    "Dự báo nhu cầu bác sĩ cho tuần tới"
  ];

  return (
    <div className="flex flex-col h-[600px] border rounded-lg bg-white shadow-lg">
      {/* Header */}
      <div className="p-4 border-b bg-gradient-to-r from-blue-50 to-indigo-50">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-lg">Healthcare Intelligence Assistant</h3>
            <p className="text-sm text-gray-600">
              Multi-source AI với database, code, và business logic
            </p>
          </div>
          <button
            onClick={() => setShowSources(!showSources)}
            className="px-3 py-1 text-xs border rounded-full hover:bg-gray-50"
          >
            {showSources ? 'Hide Sources' : 'Show Sources'}
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 && (
          <div className="text-center text-gray-500">
            <div className="mb-4">
              <h4 className="font-medium mb-2">Bắt đầu cuộc trò chuyện</h4>
              <p className="text-sm">Hỏi về dữ liệu, code logic, hoặc business rules</p>
            </div>
            
            <div className="grid gap-2 max-w-md mx-auto">
              <p className="text-xs font-medium text-left">Câu hỏi gợi ý:</p>
              {getSuggestedQuestions().map((question, index) => (
                <button
                  key={index}
                  onClick={() => setInput(question)}
                  className="text-left text-sm p-2 border rounded hover:bg-blue-50 transition-colors"
                >
                  {question}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((message, index) => (
          <div
            key={index}
            className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div className={`max-w-4xl ${message.role === 'user' ? 'w-auto' : 'w-full'}`}>
              <div
                className={`px-4 py-3 rounded-lg ${
                  message.role === 'user'
                    ? 'bg-blue-500 text-white ml-12'
                    : message.error
                    ? 'bg-red-50 text-red-800 border border-red-200'
                    : 'bg-gray-50 text-gray-800'
                }`}
              >
                {/* Message Content */}
                <div className="whitespace-pre-wrap">{message.content}</div>

                {/* Analysis Info */}
                {message.analysis && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <div className="flex items-center gap-4 text-xs">
                      <span className="font-medium">Intent: {message.analysis.intent}</span>
                      <span>Complexity: {message.analysis.complexity}</span>
                      <span className={getConfidenceColor(message.confidence)}>
                        Confidence: {Math.round(message.confidence * 100)}%
                      </span>
                    </div>
                  </div>
                )}

                {/* Sources */}
                {message.sources && message.sources.length > 0 && showSources && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <p className="text-xs font-semibold mb-2">Sources ({message.sources.length}):</p>
                    <div className="space-y-1">
                      {message.sources.slice(0, 5).map((source, idx) => (
                        <div key={idx} className="flex items-center gap-2 text-xs">
                          {getSourceIcon(source.type)}
                          <span className="flex-1">{source.title}</span>
                          {source.similarity && (
                            <span className="text-gray-500">
                              {Math.round(source.similarity * 100)}%
                            </span>
                          )}
                        </div>
                      ))}
                      {message.sources.length > 5 && (
                        <div className="text-xs text-gray-500">
                          +{message.sources.length - 5} more sources...
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {/* Timestamp */}
                <div className="text-xs opacity-50 mt-2">
                  {new Date(message.timestamp).toLocaleTimeString()}
                </div>
              </div>
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex justify-start">
            <div className="bg-gray-100 px-4 py-3 rounded-lg">
              <div className="flex items-center space-x-2">
                <div className="flex space-x-1">
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
                </div>
                <span className="text-sm text-gray-600">Analyzing multiple sources...</span>
              </div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t bg-gray-50">
        <div className="flex space-x-2">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
              }
            }}
            placeholder="Hỏi về dữ liệu, business logic, hoặc cách thức hoạt động..."
            className="flex-1 p-3 border rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"
            rows="2"
            disabled={loading}
          />
          <button
            onClick={sendMessage}
            disabled={loading || !input.trim()}
            className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {loading ? (
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
            ) : (
              'Send'
            )}
          </button>
        </div>
        
        <div className="mt-2 text-xs text-gray-500">
          Tip: Hỏi về calculations, business rules, hoặc specific data insights
        </div>
      </div>
    </div>
  );
}
```

---

## 🚀 **Production Deployment**

### **Phase 1: Environment Setup**

#### **1.1. Supabase Production Configuration**
```sql
-- Production optimizations
ALTER DATABASE postgres SET work_mem = '256MB';
ALTER DATABASE postgres SET shared_buffers = '512MB';
ALTER DATABASE postgres SET effective_cache_size = '2GB';

-- Enhanced vector search performance
CREATE INDEX CONCURRENTLY idx_document_chunks_embedding_hnsw 
ON document_chunks USING hnsw (embedding vector_cosine_ops) 
WITH (m = 16, ef_construction = 64);

-- Partitioning for large tables
CREATE TABLE chat_sessions_partitioned (LIKE chat_sessions INCLUDING ALL)
PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE chat_sessions_2024_01 PARTITION OF chat_sessions_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

#### **1.2. Edge Function Deployment**
```bash
# Install Supabase CLI
npm install -g supabase

# Initialize functions
supabase functions new chat-advanced
supabase functions new indexer-webhook

# Deploy functions
supabase functions deploy chat-advanced --project-ref your-project-ref
supabase functions deploy indexer-webhook --project-ref your-project-ref
```

#### **1.3. Environment Variables for Production**
```bash
# Production .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# LLM Provider
OPENAI_API_KEY=your-openai-key

# Security
NEXTAUTH_SECRET=your-next-auth-secret
NEXTAUTH_URL=https://your-domain.com

# Monitoring
SENTRY_DSN=your-sentry-dsn
ANALYTICS_API_KEY=your-analytics-key
```

### **Phase 2: Performance Optimization**

#### **2.1. Response Caching System**
```javascript
// utils/cache.js
import Redis from 'ioredis';

class ResponseCache {
  constructor() {
    this.redis = new Redis(process.env.REDIS_URL);
    this.defaultTTL = 3600; // 1 hour
  }

  generateCacheKey(question, userId = 'anonymous') {
    const questionHash = this.hashString(question.toLowerCase());
    return `chat:${userId}:${questionHash}`;
  }

  async get(question, userId) {
    const key = this.generateCacheKey(question, userId);
    const cached = await this.redis.get(key);
    return cached ? JSON.parse(cached) : null;
  }

  async set(question, userId, response, ttl = this.defaultTTL) {
    const key = this.generateCacheKey(question, userId);
    await this.redis.setex(key, ttl, JSON.stringify(response));
  }

  async invalidateUserCache(userId) {
    const pattern = `chat:${userId}:*`;
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }

  hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash.toString(36);
  }
}

export default ResponseCache;
```

#### **2.2. Database Connection Pooling**
```javascript
// utils/supabaseOptimized.js
import { createClient } from '@supabase/supabase-js';

class OptimizedSupabaseClient {
  constructor() {
    this.client = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      {
        db: {
          schema: 'public',
        },
        auth: {
          persistSession: false,
        },
        global: {
          headers: { 'x-my-custom-header': 'healthcare-rag' },
        },
      }
    );
    
    // Connection pool management
    this.connectionCount = 0;
    this.maxConnections = 10;
  }

  async query(query, params = {}) {
    if (this.connectionCount >= this.maxConnections) {
      await this.waitForConnection();
    }

    this.connectionCount++;
    
    try {
      const result = await this.client.rpc(query, params);
      return result;
    } finally {
      this.connectionCount--;
    }
  }

  async waitForConnection() {
    return new Promise((resolve) => {
      const checkConnection = () => {
        if (this.connectionCount < this.maxConnections) {
          resolve();
        } else {
          setTimeout(checkConnection, 100);
        }
      };
      checkConnection();
    });
  }
}

export default new OptimizedSupabaseClient();
```

#### **2.3. Real-time Indexing Pipeline**
```javascript
// utils/realtimeIndexer.js
import { MultiSourceIndexer } from './multiSourceIndexer.js';

export class RealtimeIndexer {
  constructor() {
    this.indexer = new MultiSourceIndexer();
    this.indexQueue = [];
    this.isProcessing = false;
  }

  async startRealtimeIndexing() {
    // Listen for database changes
    const supabase = this.indexer.supabase;
    
    // Listen to changes in main tables
    const channels = [
      'lich_kham',
      'documents',
      'companies'
    ].map(table => 
      supabase
        .channel(`realtime:${table}`)
        .on('postgres_changes', {
          event: '*',
          schema: 'public',
          table: table
        }, (payload) => {
          this.queueIndexing(table, payload);
        })
        .subscribe()
    );

    console.log('🔄 Real-time indexing started');
    return channels;
  }

  queueIndexing(table, payload) {
    this.indexQueue.push({ table, payload, timestamp: Date.now() });
    
    if (!this.isProcessing) {
      this.processQueue();
    }
  }

  async processQueue() {
    this.isProcessing = true;
    
    while (this.indexQueue.length > 0) {
      const job = this.indexQueue.shift();
      
      try {
        await this.processIndexingJob(job);
      } catch (error) {
        console.error('Indexing job failed:', error);
        // Could implement retry logic here
      }
    }
    
    this.isProcessing = false;
  }

  async processIndexingJob({ table, payload }) {
    const { eventType, new: newRecord, old: oldRecord } = payload;

    switch (eventType) {
      case 'INSERT':
        await this.indexNewRecord(table, newRecord);
        break;
      case 'UPDATE':
        await this.updateIndexedRecord(table, newRecord, oldRecord);
        break;
      case 'DELETE':
        await this.removeFromIndex(table, oldRecord);
        break;
    }
  }

  async indexNewRecord(table, record) {
    // Determine which fields contain text content
    const textFields = this.getTextFields(table);
    
    for (const field of textFields) {
      if (record[field]) {
        await this.indexer.indexDocument(
          `${table}:${record.id}:${field}`,
          record[field],
          `database:${table}`,
          { 
            table, 
            record_id: record.id, 
            field,
            ...record 
          }
        );
      }
    }
  }

  getTextFields(table) {
    const fieldMap = {
      'lich_kham': ['ghi_chu', 'ket_qua_kham'],
      'companies': ['ten_cong_ty', 'mo_ta'],
      'documents': ['content', 'title']
    };
    
    return fieldMap[table] || [];
  }
}
```

### **Phase 3: Monitoring & Analytics**

#### **3.1. Performance Monitoring**
```javascript
// utils/monitoring.js
export class ChatbotMonitoring {
  constructor() {
    this.metrics = {
      totalQueries: 0,
      averageResponseTime: 0,
      sourceUtilization: {},
      errorRate: 0,
      userSatisfaction: 0
    };
  }

  async trackQuery(queryData) {
    const startTime = Date.now();
    
    try {
      // Track the query
      await this.supabase
        .from('chat_analytics')
        .insert({
          query: queryData.question,
          user_id: queryData.userId,
          session_id: queryData.sessionId,
          sources_used: queryData.sourcesUsed,
          response_time: Date.now() - startTime,
          success: true,
          created_at: new Date()
        });

      this.updateMetrics(queryData, Date.now() - startTime, true);
      
    } catch (error) {
      await this.trackError(error, queryData);
      this.updateMetrics(queryData, Date.now() - startTime, false);
    }
  }

  async trackError(error, queryData) {
    await this.supabase
      .from('error_logs')
      .insert({
        error_message: error.message,
        error_stack: error.stack,
        query_data: queryData,
        created_at: new Date()
      });
  }

  updateMetrics(queryData, responseTime, success) {
    this.metrics.totalQueries++;
    
    // Update average response time
    this.metrics.averageResponseTime = 
      (this.metrics.averageResponseTime + responseTime) / 2;
    
    // Track source utilization
    if (queryData.sourcesUsed) {
      queryData.sourcesUsed.forEach(source => {
        this.metrics.sourceUtilization[source.type] = 
          (this.metrics.sourceUtilization[source.type] || 0) + 1;
      });
    }
    
    // Update error rate
    if (!success) {
      this.metrics.errorRate = 
        (this.metrics.errorRate * (this.metrics.totalQueries - 1) + 1) / 
        this.metrics.totalQueries;
    }
  }

  async generateReport(timeframe = '24h') {
    const timeAgo = new Date();
    timeAgo.setHours(timeAgo.getHours() - (timeframe === '24h' ? 24 : 24 * 7));

    const { data: analytics } = await this.supabase
      .from('chat_analytics')
      .select('*')
      .gte('created_at', timeAgo.toISOString());

    return {
      totalQueries: analytics.length,
      averageResponseTime: analytics.reduce((acc, a) => acc + a.response_time, 0) / analytics.length,
      successRate: (analytics.filter(a => a.success).length / analytics.length) * 100,
      popularQueries: this.getPopularQueries(analytics),
      sourceUtilization: this.calculateSourceUtilization(analytics),
      userEngagement: this.calculateUserEngagement(analytics)
    };
  }

  getPopularQueries(analytics) {
    const queryCount = {};
    analytics.forEach(a => {
      queryCount[a.query] = (queryCount[a.query] || 0) + 1;
    });
    
    return Object.entries(queryCount)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 10)
      .map(([query, count]) => ({ query, count }));
  }

  calculateSourceUtilization(analytics) {
    const utilization = {};
    analytics.forEach(a => {
      if (a.sources_used) {
        a.sources_used.forEach(source => {
          utilization[source.type] = (utilization[source.type] || 0) + 1;
        });
      }
    });
    return utilization;
  }

  calculateUserEngagement(analytics) {
    const sessions = {};
    analytics.forEach(a => {
      if (!sessions[a.session_id]) {
        sessions[a.session_id] = [];
      }
      sessions[a.session_id].push(a);
    });

    const sessionLengths = Object.values(sessions).map(s => s.length);
    const averageSessionLength = sessionLengths.reduce((acc, len) => acc + len, 0) / sessionLengths.length;

    return {
      totalSessions: Object.keys(sessions).length,
      averageSessionLength,
      totalUsers: new Set(analytics.map(a => a.user_id)).size
    };
  }
}
```

---

## 📊 **Optimization & Monitoring**

### **Performance Optimization Checklist**

#### **Database Optimization**
- [ ] Proper vector indexes (HNSW for production)
- [ ] Connection pooling configured
- [ ] Query optimization với EXPLAIN ANALYZE
- [ ] Table partitioning for large datasets
- [ ] Regular VACUUM và ANALYZE

#### **Caching Strategy**
- [ ] Response caching implemented
- [ ] Embedding caching for frequent queries
- [ ] CDN for static assets
- [ ] Redis for session management

#### **API Optimization**
- [ ] Rate limiting implemented
- [ ] Request compression enabled
- [ ] Streaming responses for long queries
- [ ] Error handling và retry logic

#### **Frontend Optimization**
- [ ] Code splitting implemented
- [ ] Lazy loading for components
- [ ] Optimistic UI updates
- [ ] Progressive enhancement

### **Monitoring Dashboards**

#### **System Health Metrics**
```javascript
// Dashboard metrics to track
const healthMetrics = {
  // Performance
  averageResponseTime: '<2000ms',
  databaseQueryTime: '<500ms',
  vectorSearchTime: '<300ms',
  
  // Availability
  uptime: '>99.9%',
  errorRate: '<1%',
  
  // Usage
  dailyActiveUsers: 'tracked',
  queriesPerDay: 'tracked',
  sourceUtilization: 'tracked',
  
  // Quality
  userSatisfactionRating: '>4.0/5',
  queryResolutionRate: '>85%',
  responseAccuracy: '>90%'
};
```

---

## 🔧 **Troubleshooting**

### **Common Issues & Solutions**

#### **1. Slow Vector Search**
```sql
-- Problem: Vector search too slow
-- Solution: Optimize indexes
REINDEX INDEX CONCURRENTLY idx_document_chunks_embedding_hnsw;

-- Tune search parameters
ALTER TABLE document_chunks 
SET (hnsw.ef_search = 100); -- Increase for better accuracy vs speed
```

#### **2. Memory Issues**
```javascript
// Problem: High memory usage
// Solution: Implement streaming và chunking
const processLargeDocument = async (document) => {
  const stream = new ReadableStream({
    start(controller) {
      const chunks = chunkDocument(document, 1000);
      chunks.forEach(chunk => controller.enqueue(chunk));
      controller.close();
    }
  });
  
  return stream;
};
```

#### **3. Rate Limiting Issues**
```javascript
// Problem: API rate limits exceeded
// Solution: Implement exponential backoff
const callWithBackoff = async (fn, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && i < maxRetries - 1) {
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, i) * 1000)
        );
      } else {
        throw error;
      }
    }
  }
};
```

#### **4. Context Length Limits**
```javascript
// Problem: Context too long for LLM
// Solution: Smart context truncation
const optimizeContext = (context, maxTokens = 6000) => {
  let totalTokens = 0;
  const optimizedContext = [];
   TextChunker {
  constructor(chunkSize = 1000, overlap = 200) {
    this.chunkSize = chunkSize;
    this.overlap = overlap;
  }

  chunkText(text) {
    const chunks = [];
    let start = 0;

    while (start < text.length) {
      const end = Math.min(start + this.chunkSize, text.length);
      const chunk = text.slice(start, end);
      
      // Find last complete sentence trong chunk
      const lastPeriod = chunk.lastIndexOf('.');
      const finalChunk = lastPeriod > this.chunkSize * 0.5 
        ? chunk.slice(0, lastPeriod + 1)
        : chunk;

      chunks.push({
        text: finalChunk.trim(),
        start,
        end: start + finalChunk.length
      });

      start += finalChunk.length - this.overlap;
    }

    return chunks;
  }

  semanticChunk(text) {
    // Split by paragraphs first
    const paragraphs = text.split(/\n\s*\n/).filter(p => p.trim());
    const chunks = [];
    let currentChunk = '';

    for (const paragraph of paragraphs) {
      if ((currentChunk + paragraph).length > this.chunkSize) {
        if (currentChunk) {
          chunks.push(currentChunk.trim());
          currentChunk = paragraph;
        } else {
          // Paragraph quá dài, chia nhỏ
          const subChunks = this.chunkText(paragraph);
          chunks.push(...subChunks.map(c => c.text));
        }
      } else {
        currentChunk += (currentChunk ? '\n\n' : '') + paragraph;
      }
    }

    if (currentChunk) {
      chunks.push(currentChunk.trim());
    }

    return chunks.map((text, index) => ({ text, index }));
  }
}
```

#### **3.2. Embedding Generator**
```javascript
// utils/embeddings.js
import OpenAI from 'openai';

export class EmbeddingGenerator {
  constructor(provider = 'openai') {
    this.provider = provider;
    
    if (provider === 'openai') {
      this.client = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY
      });
    }
  }

  async generateEmbedding(text) {
    try {
      switch (this.provider) {
        case 'openai':
          const response = await this.client.embeddings.create({
            model: 'text-embedding-3-small',
            input: text.slice(0, 8000), // Token limit
          });
          return response.data[0].embedding;

        case 'local':
          // Sử dụng local transformer
          const { pipeline } = await import('@xenova/transformers');
          const embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
          const output = await embedder(text, { pooling: 'mean', normalize: true });
          return Array.from(output.data);

        default:
          throw new Error(`Unsupported provider: ${this.provider}`);
      }
    } catch (error) {
      console.error('Embedding generation failed:', error);
      throw error;
    }
  }

  async batchGenerate(texts, batchSize = 10) {
    const results = [];
    
    for (let i = 0; i < texts.length; i += batchSize) {
      const batch = texts.slice(i, i + batchSize);
      const embeddings = await Promise.all(
        batch.map(text => this.generateEmbedding(text))
      );
      results.push(...embeddings);
      
      // Rate limiting
      if (i + batchSize < texts.length) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
    
    return results;
  }
}
```

#### **3.3. Document Indexer**
```javascript
// scripts/indexer.js
import { createClient } from '@supabase/supabase-js';
import { TextChunker } from '../utils/textChunker.js';
import { EmbeddingGenerator } from '../utils/embeddings.js';

export class DocumentIndexer {
  constructor() {
    this.supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    );
    this.chunker = new TextChunker(1000, 200);
    this.embedder = new EmbeddingGenerator('openai');
  }

  async indexDocument(title, content, source, metadata = {}) {
    try {
      // 1. Create document record
      const { data: doc, error: docError } = await this.supabase
        .from('documents')
        .insert({
          title,
          content: content.slice(0, 2000), // Preview
          source,
          metadata
        })
        .select()
        .single();

      if (docError) throw docError;

      // 2. Chunk the content
      const chunks = this.chunker.semanticChunk(content);

      // 3. Generate embeddings
      const embeddings = await this.embedder.batchGenerate(
        chunks.map(c => c.text)
      );

      // 4. Store chunks với embeddings
      const chunkData = chunks.map((chunk, index) => ({
        document_id: doc.id,
        chunk_text: chunk.text,
        chunk_index: index,
        embedding: embeddings[index],
        metadata: {
          ...metadata,
          chunk_size: chunk.text.length,
          source_section: this.extractSection(chunk.text)
        }
      }));

      const { error: chunkError } = await this.supabase
        .from('document_chunks')
        .insert(chunkData);

      if (chunkError) throw chunkError;

      console.log(`✅ Indexed: ${title} (${chunks.length} chunks)`);
      return doc.id;

    } catch (error) {
      console.error(`❌ Indexing failed for ${title}:`, error);
      throw error;
    }
  }

  async indexFromDatabase(tableName, textColumn, titleColumn = 'id') {
    const { data: records, error } = await this.supabase
      .from(tableName)
      .select('*');

    if (error) throw error;

    for (const record of records) {
      await this.indexDocument(
        record[titleColumn] || record.id,
        record[textColumn],
        `database:${tableName}`,
        { table: tableName, record_id: record.id, ...record }
      );
    }
  }

  async indexDirectory(dirPath) {
    const fs = await import('fs');
    const path = await import('path');
    
    const files = fs.readdirSync(dirPath);
    
    for (const file of files) {
      if (file.endsWith('.md') || file.endsWith('.txt')) {
        const filePath = path.join(dirPath, file);
        const content = fs.readFileSync(filePath, 'utf8');
        
        await this.indexDocument(
          file,
          content,
          `file:${filePath}`,
          { file_type: path.extname(file) }
        );
      }
    }
  }

  extractSection(text) {
    // Extract section từ headers
    const headerMatch = text.match(/^#+\s*(.+)$/m);
    return headerMatch ? headerMatch[1] : null;
  }
}

// Usage example
const indexer = new DocumentIndexer();
await indexer.indexFromDatabase('lich_kham', 'ghi_chu', 'id');
```

### **Phase 4: Backend API**

#### **4.1. Chat API Endpoint**
```javascript
// pages/api/chat.js (Next.js) hoặc Edge Function
import { createClient } from '@supabase/supabase-js';
import OpenAI from 'openai';
import { EmbeddingGenerator } from '../../utils/embeddings';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const embedder = new EmbeddingGenerator('openai');

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { question, sessionId, userId } = req.body;

    if (!question) {
      return res.status(400).json({ error: 'Question is required' });
    }

    // 1. Generate query embedding
    const queryEmbedding = await embedder.generateEmbedding(question);

    // 2. Search relevant documents
    const { data: matches, error: searchError } = await supabase
      .rpc('match_documents', {
        query_embedding: queryEmbedding,
        match_threshold: 0.7,
        match_count: 5
      });

    if (searchError) throw searchError;

    // 3. Build context từ relevant chunks
    const context = matches
      .map(match => `Source: ${match.metadata?.source || 'Unknown'}\n${match.chunk_text}`)
      .join('\n\n---\n\n');

    // 4. Generate response với LLM
    const systemPrompt = `You are a helpful assistant for a healthcare management system. 
Answer questions based on the provided context. If the answer is not in the context, 
say "Tôi không tìm thấy thông tin này trong dữ liệu hiện có."

Always cite your sources và provide specific information when available.

Context:
${context}`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: question }
      ],
      max_tokens: 1000,
      temperature: 0.1
    });

    const answer = completion.choices[0].message.content;

    // 5. Save chat history
    await supabase
      .from('chat_sessions')
      .insert({
        user_id: userId,
        session_id: sessionId,
        question,
        answer,
        sources: matches.map(m => ({
          document_id: m.document_id,
          similarity: m.similarity,
          source: m.metadata?.source
        }))
      });

    // 6. Return response
    res.json({
      answer,
      sources: matches,
      sessionId
    });

  } catch (error) {
    console.error('Chat API error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
}
```

#### **4.2. Streaming Response API**
```javascript
// pages/api/chat-stream.js
export default async function handler(req, res) {
  // Set up SSE headers
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*'
  });

  try {
    const { question } = req.body;

    // ... same retrieval logic ...

    const stream = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: question }
      ],
      stream: true
    });

    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content || '';
      if (content) {
        res.write(`data: ${JSON.stringify({ content })}\n\n`);
      }
    }

    res.write(`data: ${JSON.stringify({ done: true })}\n\n`);
    res.end();

  } catch (error) {
    res.write(`data: ${JSON.stringify({ error: error.message })}\n\n`);
    res.end();
  }
}
```

### **Phase 5: Frontend Implementation**

#### **5.1. Chat Component**
```jsx
// components/Chat.jsx
import { useState, useEffect, useRef } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

export default function Chat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [sessionId] = useState(() => Math.random().toString(36).substr(2, 9));
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(scrollToBottom, [messages]);

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage = { role: 'user', content: input, timestamp: Date.now() };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          question: input,
          sessionId,
          userId: 'current-user' // Replace with actual user ID
        })
      });

      const data = await response.json();

      if (response.ok) {
        const assistantMessage = {
          role: 'assistant',
          content: data.answer,
          sources: data.sources,
          timestamp: Date.now()
        };
        setMessages(prev => [...prev, assistantMessage]);
      } else {
        throw new Error(data.error);
      }
    } catch (error) {
      const errorMessage = {
        role: 'assistant',
        content: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        error: true,
        timestamp: Date.now()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div className="flex flex-col h-96 border rounded-lg bg-white">
      {/* Header */}
      <div className="p-4 border-b bg-gray-50">
        <h3 className="font-semibold">Healthcare Assistant</h3>
        <p className="text-sm text-gray-600">Hỏi về dữ liệu khám sức khỏe</p>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 && (
          <div className="text-center text-gray-500">
            <p>Bắt đầu cuộc trò chuyện...</p>
            <div className="mt-2 text-sm">
              <p>Ví dụ: "Số người khám hôm nay là bao nhiêu?"</p>
            </div>
          </div>
        )}

        {messages.map((message, index) => (
          <div
            key={index}
            className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                message.role === 'user'
                  ? 'bg-blue-500 text-white'
                  : message.error
                  ? 'bg-red-100 text-red-800 border border-red-300'
                  : 'bg-gray-100 text-gray-800'
              }`}
            >
              <div className="whitespace-pre-wrap">{message.content}</div>
              
              {/* Sources */}
              {message.sources && message.sources.length > 0 && (
                <div className="mt-2 pt-2 border-t border-gray-300">
                  <p className="text-xs font-semibold mb-1">Sources:</p>
                  {message.sources.slice(0, 3).map((source, idx) => (
                    <div key={idx} className="text-xs opacity-75">
                      • {source.metadata?.source || 'Database'}
                      {source.similarity && (
                        <span className="ml-1">({Math.round(source.similarity * 100)}%)</span>
                      )}
                    </div>
                  ))}
                </div>
              )}

              <div className="text-xs opacity-50 mt-1">
                {new Date(message.timestamp).toLocaleTimeString()}
              </div>
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex justify-start">
            <div className="bg-gray-100 px-4 py-2 rounded-lg">
              <div className="flex space-x-1">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
              </div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t">
        <div className="flex space-x-2">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Nhập câu hỏi của bạn..."
            className="flex-1 p-2 border rounded-lg resize-none"
            rows="1"
            disabled={loading}
          />
          <button
            onClick={sendMessage}
            disabled={loading || !input.trim()}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50"
          >
            {loading ? '...' : 'Gửi'}
          </button>
        </div>
      </div>
    </div>
  );
}
```

#### **5.2. Streaming Chat Component**
```jsx
// components/StreamingChat.jsx
import { useState, useEffect } from 'react';

export default function StreamingChat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const sendStreamingMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);
    
    const currentInput = input;
    setInput('');
    setLoading(true);

    // Add placeholder for assistant response
    const assistantMessageIndex = messages.length + 1;
    setMessages(prev => [...prev, { role: 'assistant', content: '', streaming: true }]);

    try {
      const response = await fetch('/api/chat-stream', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: currentInput })
      });

      const reader = response.body.getReader();
      let accumulatedContent = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = new TextDecoder().decode(value);
        const lines = chunk.split('\n');

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            try {
              const data = JSON.parse(line.slice(6));
              
              if (data.content) {
                accumulatedContent += data.content;
                setMessages(prev => {
                  const newMessages = [...prev];
                  newMessages[assistantMessageIndex] = {
                    role: 'assistant',
                    content: accumulatedContent,
                    streaming: !data.done
                  };
                  return newMessages;
                });
              }

              if (data.done) {
                setMessages(prev => {
                  const newMessages = [...prev];
                  newMessages[assistantMessageIndex].streaming = false;
                  return newMessages;
                });
              }
            } catch (e) {
              // Ignore malformed JSON
            }
          }
        }
      }
    } catch (error) {
      setMessages(prev => {
        const newMessages = [...prev];
        newMessages[assistantMessageIndex] = {
          role: 'assistant',
          content: 'Đã có lỗi xảy ra.',
          error: true
        };
        return newMessages;
      });
    } finally {
      setLoading(false);
    }
  };

  // ... rest of component similar to Chat but với streaming animation
}
```

---

## 🚀 **Multi-Source RAG Implementation**

### **Phase 1: Advanced Architecture Setup**

#### **1.1. Extended Database Schema**
```sql
-- Knowledge source types
CREATE TYPE source_type AS ENUM ('database', 'code', 'documentation', 'api', 'file');

-- Multi-source knowledge base
CREATE TABLE knowledge_base (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type source_type NOT NULL,
  source_path text NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  metadata jsonb DEFAULT '{}',
  embedding vector(1536),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Code intelligence
CREATE TABLE code_functions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  file_path text NOT NULL,
  function_name text NOT NULL,
  function_signature text,
  docstring text,
  implementation text,
  business_logic_tags text[],
  embedding vector(1536),
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- Business rules
CREATE TABLE business_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_name text NOT NULL,
  description text NOT NULL,
  rule_type text, -- calculation, validation, workflow
  implementation jsonb,
  related_entities text[],
  embedding vector(1536),
  created_at timestamptz DEFAULT now()
);

-- API documentation
CREATE TABLE api_endpoints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint_path text NOT NULL,
  method text NOT NULL,
  description text,
  parameters jsonb,
  response_schema jsonb,
  examples jsonb,
  embedding vector(1536),
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_knowledge_base_source_type ON knowledge_base(source_type);
CREATE INDEX idx_knowledge_base_embedding ON knowledge_base USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_code_functions_embedding ON code_functions USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_business_rules_embedding ON business_rules USING ivfflat (embedding vector_cosine_ops);
```

#### **1.2. Advanced Vector Search Functions**
```sql
-- Multi-source search function
CREATE OR REPLACE FUNCTION search_knowledge_multi_source(
  query_embedding vector(1536),
  source_types source_type[] DEFAULT ARRAY['database', 'code', 'documentation'],
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 15
)
RETURNS TABLE (
  id uuid,
  source_type source_type,
  title text,
  content text,
  metadata jsonb,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    kb.id,
    kb.source_type,
    kb.title,
    kb.content,
    kb.metadata,
    1 - (kb.embedding <=> query_embedding) as similarity
  FROM knowledge_base kb
  WHERE kb.source_type = ANY(source_types)
    AND 1 - (kb.embedding <=> query_embedding) > match_threshold
  ORDER BY kb.embedding <=> query_embedding
  LIMIT match_count;
$$;

-- Code-specific search
CREATE OR REPLACE FUNCTION search_code_functions(
  query_embedding vector(1536),
  business_tags text[] DEFAULT '{}',
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 5
)
RETURNS TABLE (
  id uuid,
  function_name text,
  file_path text,
  implementation text,
  business_logic_tags text[],
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    cf.id,
    cf.function_name,
    cf.file_path,
    cf.implementation,
    cf.business_logic_tags,
    1 - (cf.embedding <=> query_embedding) as similarity
  FROM code_functions cf
  WHERE (array_length(business_tags, 1) IS NULL OR cf.business_logic_tags && business_tags)
    AND 1 - (cf.embedding <=> query_embedding) > match_threshold
  ORDER BY cf.embedding <=> query_embedding
  LIMIT match_count;
$$;
```

### **Phase 2: Code Intelligence System**

#### **2.1. Code Parser & Analyzer**
```javascript
// utils/codeAnalyzer.js
import fs from 'fs';
import path from 'path';
import { parse } from '@babel/parser';
import traverse from '@babel/traverse';
import * as t from '@babel/types';

export class