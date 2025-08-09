# Enhanced Multi-Source RAG System cho Healthcare Dashboard

## 🎯 **Vấn đề Core: RAG cần hiểu cả Data + Code + Business Logic**

### **Current Limitation**
```
User: "Ngày nào tháng này số người khám đông nhất, công ty nào và dự báo số bác sĩ siêu âm?"

Simple RAG (chỉ data): ❌
- Chỉ có thể query: "SELECT * FROM lich_kham WHERE..."
- KHÔNG biết công thức tính load, capacity planning
- KHÔNG hiểu business rules của từng công ty
```

### **Enhanced Solution**
```
Enhanced RAG (Data + Code + Domain): ✅
- Hiểu data structure từ Supabase
- Hiểu business logic từ source code  
- Hiểu domain rules từ documentation
- Có thể predict và recommend
```

## 🧠 **Multi-Source Knowledge Architecture**

### **1. Data Layer (Supabase)**
```sql
-- Vector embeddings cho database schema và sample data
CREATE TABLE knowledge_vectors (
  id uuid PRIMARY KEY,
  source_type text, -- 'schema', 'data_sample', 'code', 'docs'
  content text,
  embedding vector,
  metadata jsonb,
  created_at timestamp
);

-- Index các loại knowledge khác nhau
CREATE INDEX idx_knowledge_by_type ON knowledge_vectors(source_type);
```

### **2. Code Intelligence Layer**
```javascript
// Indexer cho source code
class CodeIntelligenceIndexer {
  async indexCodebase(projectPath) {
    const files = await this.scanCodeFiles(projectPath);
    
    for (const file of files) {
      // Parse functions, classes, business logic
      const codeStructure = await this.parseCodeStructure(file);
      
      // Extract business rules
      const businessRules = await this.extractBusinessRules(file);
      
      // Create embeddings cho từng component
      await this.indexCodeComponents(codeStructure, businessRules);
    }
  }
  
  async extractBusinessRules(file) {
    // Tìm functions liên quan đến healthcare calculations
    const healthcarePatterns = [
      /calculate.*load/i,
      /predict.*doctor/i,
      /capacity.*planning/i,
      /company.*rules/i
    ];
    
    return this.extractPatternsFromCode(file, healthcarePatterns);
  }
}
```

### **3. Domain Knowledge Layer**
```javascript
// Healthcare domain knowledge base
const healthcareDomainKnowledge = {
  capacityPlanning: {
    rules: [
      "Bác sĩ siêu âm: 1 bác sĩ / 15 patients per hour",
      "Peak hours: 8-10AM, 2-4PM",
      "Company-specific multipliers vary by equipment"
    ],
    calculations: `
      requiredDoctors = Math.ceil(
        (peakHourPatients * companyMultiplier) / doctorCapacityPerHour
      )
    `
  },
  
  businessRules: {
    companyTypes: {
      "CORPORATE": { multiplier: 1.2, priority: "high" },
      "INDIVIDUAL": { multiplier: 1.0, priority: "normal" },
      "GOVERNMENT": { multiplier: 0.8, priority: "low" }
    }
  }
};
```

## 🔧 **Enhanced RAG Implementation**

### **1. Multi-Source Query Engine**
```javascript
class EnhancedRAGEngine {
  constructor() {
    this.dataSources = {
      supabase: new SupabaseConnector(),
      codebase: new CodeIntelligenceConnector(),
      domain: new DomainKnowledgeConnector()
    };
  }
  
  async processComplexQuery(question) {
    // 1. Analyze query complexity
    const queryAnalysis = await this.analyzeQuery(question);
    
    // 2. Determine required knowledge sources
    const requiredSources = this.determineRequiredSources(queryAnalysis);
    
    // 3. Multi-source retrieval
    const contexts = await Promise.all(
      requiredSources.map(source => this.retrieveFromSource(source, question))
    );
    
    // 4. Synthesize response với business intelligence
    return this.synthesizeResponse(question, contexts);
  }
  
  async analyzeQuery(question) {
    const analysisPrompt = `
    Analyze this healthcare query and categorize:
    
    Query: "${question}"
    
    Return JSON:
    {
      "requiresData": true/false,
      "requiresCalculation": true/false,
      "requiresBusinessLogic": true/false,
      "requiresPrediction": true/false,
      "entities": ["date", "company", "doctor_type"],
      "complexity": "simple|medium|complex"
    }
    `;
    
    const analysis = await this.callLLM(analysisPrompt);
    return JSON.parse(analysis);
  }
}
```

### **2. Intelligent Code Retrieval**
```javascript
class CodeIntelligenceConnector {
  async retrieveRelevantCode(query) {
    // Vector search trong code embeddings
    const codeMatches = await this.vectorSearchCode(query);
    
    // Extract business logic functions
    const relevantFunctions = codeMatches.filter(match => 
      match.metadata.type === 'business_logic' || 
      match.metadata.type === 'calculation'
    );
    
    return {
      functions: relevantFunctions,
      businessRules: await this.extractBusinessRules(relevantFunctions),
      calculations: await this.extractCalculations(relevantFunctions)
    };
  }
  
  async extractCalculations(functions) {
    // Parse actual calculation logic from code
    return functions.map(func => ({
      name: func.name,
      parameters: func.parameters,
      logic: func.implementation,
      usage: func.usageExamples
    }));
  }
}
```

### **3. Advanced Query Processing**
```javascript
// Xử lý câu hỏi phức tạp: "Ngày nào tháng này số người khám đông nhất..."
async function processHealthcareQuery(question) {
  // Step 1: Extract data requirements
  const dataQuery = `
    SELECT 
      DATE(ngay_bat_dau_kham) as exam_date,
      ten_cong_ty,
      COUNT(*) as patient_count,
      COUNT(CASE WHEN ten_nhan_vien LIKE '%siêu âm%' THEN 1 END) as ultrasound_count
    FROM lich_kham 
    WHERE EXTRACT(MONTH FROM ngay_bat_dau_kham) = EXTRACT(MONTH FROM CURRENT_DATE)
    GROUP BY exam_date, ten_cong_ty
    ORDER BY patient_count DESC
  `;
  
  const rawData = await supabase.rpc('execute_query', { query: dataQuery });
  
  // Step 2: Apply business logic từ code
  const businessLogic = await codeIntelligence.getCapacityCalculations();
  
  // Step 3: Generate predictions
  const predictions = await this.predictDoctorNeeds(rawData, businessLogic);
  
  // Step 4: Build comprehensive response
  return this.buildIntelligentResponse(rawData, predictions, businessLogic);
}
```

## 📊 **Real-world Implementation Example**

### **Complete Flow cho Healthcare Query**
```javascript
const healthcareRAG = new EnhancedRAGEngine();

// User query
const query = "Ngày nào tháng này số người khám đông nhất, công ty nào và dự báo số bác sĩ siêu âm?";

const response = await healthcareRAG.process(query);

// Expected intelligent response:
{
  answer: `
    Dựa trên dữ liệu tháng này:
    
    📅 NGÀY ĐÔNG NHẤT: 15/08/2025 với 134 người khám
    🏢 CÔNG TY: "CÔNG TY TNHH PHÁT TRIỂN GLOBAL" (134 khách)
    
    📈 DỰ BÁO BÁC SĨ SIÊU ÂM:
    - Hiện tại: 2 bác sĩ siêu âm
    - Khuyến nghị: 4 bác sĩ (tăng 100%)
    
    📊 TÍNH TOÁN:
    - Peak load: 134 patients/day
    - Capacity/doctor: 15 patients/hour × 8 hours = 120/day
    - Required: 134 ÷ 120 = 1.12 → 2 doctors minimum
    - Safety buffer (20%): 2 × 1.2 = 2.4 → 3 doctors
    - Company multiplier (Corporate): 3 × 1.2 = 3.6 → 4 doctors
  `,
  
  sources: [
    { type: 'data', table: 'lich_kham', rows: 134 },
    { type: 'code', function: 'calculateDoctorCapacity()' },
    { type: 'business_rule', rule: 'corporate_multiplier: 1.2' }
  ],
  
  calculations: {
    peakDay: "2025-08-15",
    currentDoctors: 2,
    recommendedDoctors: 4,
    confidence: 0.85
  }
}
```

## 🔄 **System Architecture Diagram**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Query    │────│   Query Analyzer │────│  Source Router  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                        ┌────────────────────────────────┼────────────────────────────────┐
                        │                                │                                │
                        ▼                                ▼                                ▼
                ┌───────────────┐                ┌──────────────┐                ┌──────────────┐
                │ Supabase Data │                │ Code Intelligence│              │Domain Knowledge│
                │   - Schema    │                │  - Functions    │              │ - Business Rules│
                │   - Records   │                │  - Algorithms   │              │ - Calculations │
                │   - Metadata  │                │  - Logic        │              │ - Best Practices│
                └───────────────┘                └──────────────┘                └──────────────┘
                        │                                │                                │
                        └────────────────┐               │               ┌────────────────┘
                                         │               │               │
                                         ▼               ▼               ▼
                                    ┌─────────────────────────────────────────┐
                                    │        Response Synthesizer             │
                                    │  - Combine all sources                  │
                                    │  - Apply business logic                 │
                                    │  - Generate predictions                 │
                                    │  - Format for user                      │
                                    └─────────────────────────────────────────┘
                                                         │
                                                         ▼
                                                ┌─────────────────┐
                                                │ Intelligent     │
                                                │ Response        │
                                                └─────────────────┘
```

## 🛠 **Implementation Steps**

### **Phase 1: Code Intelligence Setup**
1. **Code Parsing**: Index toàn bộ React components, utility functions
2. **Business Logic Extraction**: Identify calculation functions, business rules
3. **Domain Knowledge Creation**: Document healthcare-specific knowledge

### **Phase 2: Enhanced Vector Store**
1. **Multi-Source Embeddings**: Separate vector spaces cho data, code, domain
2. **Contextual Retrieval**: Query routing based on complexity analysis
3. **Hybrid Search**: Combine semantic + keyword + code search

### **Phase 3: Intelligent Response Generation**
1. **Query Understanding**: Parse intent, entities, required calculations
2. **Multi-Source Synthesis**: Combine data + code + domain knowledge
3. **Business Intelligence**: Apply calculations với real data

## 📈 **Benefits của Enhanced System**

### **Capabilities**
✅ **Data Queries**: "Ai khám nhiều nhất tháng này?"
✅ **Business Analysis**: "Công ty nào có efficiency cao nhất?"
✅ **Predictive Analytics**: "Cần bao nhiêu bác sĩ cho peak hour?"
✅ **Code Understanding**: "Làm sao system tính capacity?"
✅ **Domain Expertise**: "Best practices cho scheduling?"

### **Unique Value**
- **Context-Aware**: Hiểu business context của healthcare
- **Code-Informed**: Biết cách calculations thực sự hoạt động
- **Predictive**: Không chỉ report mà còn forecast
- **Explainable**: Show calculation steps và reasoning

Với architecture này, chatbot sẽ trở thành một **Healthcare Business Intelligence Assistant** thực sự - không chỉ query data mà còn hiểu business logic và đưa ra insights có giá trị!