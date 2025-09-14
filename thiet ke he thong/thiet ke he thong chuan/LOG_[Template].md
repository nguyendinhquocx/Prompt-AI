# 📖 NHẬT KÝ CÔNG VIỆC - 2025-09-13

**Người thực thi:** `@Claude-Agent`
**Mục tiêu hôm nay:** Bắt đầu thực thi FSD-02: Hệ thống Nhắc nhở Thông minh.

---

### **SESSION 1: 09:00 AM**

**Lệnh Giao Việc (Prompt):**
```
Chào Claude,
Đây là toàn bộ đặc tả cho tính năng "Hệ thống Nhắc nhở Thông minh": [Dán toàn bộ nội dung file FSD_Nhac_Nho_Thong_Minh.md vào đây].
Đọc và hiểu kỹ. Bắt đầu thực hiện task đầu tiên trong checklist: "Backend: Task 1: Tạo migration cho bảng `reminders`".
Cung cấp code migration cho tôi.
```

**Kết Quả (Output của AI):**
```sql
-- Code migration mà AI cung cấp
CREATE TABLE reminders (
    id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL REFERENCES tasks(id),
    remind_at TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Hành Động Của Tao:**
- [x] Đã review code.
- [x] Đã chạy migration thành công.
- [x] Cập nhật checklist trong `FSD_Nhac_Nho_Thong_Minh.md`.

---

### **SESSION 2: 10:30 AM**

**Lệnh Giao Việc (Prompt):**
```
Tốt. Giờ làm task tiếp theo: "Backend: Task 2: Viết API endpoint GET /tasks/:id/reminders để lấy danh sách nhắc nhở của một task".
Sử dụng Node.js và Express.
```

**Kết Quả (Output của AI):**
```javascript
// Code API endpoint mà AI cung cấp
app.get('/tasks/:id/reminders', async (req, res) => {
    // ...
});
```

**Hành Động Của Tao:**
- [x] Review code. Phát hiện logic xử lý timezone chưa ổn.
- [ ] Yêu cầu AI sửa lại ở session tiếp theo.

---
*Cứ thế tiếp tục...*