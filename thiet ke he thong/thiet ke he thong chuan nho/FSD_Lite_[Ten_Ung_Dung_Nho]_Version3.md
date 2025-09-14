# FSD-Lite: [Tên Ứng Dụng Nhỏ]

**Mục tiêu:** (Viết đúng 1 câu) Ứng dụng này làm gì để giải quyết vấn đề gì?
*Ví dụ: "Tool Python này tự động lấy highlight từ PDF và xuất ra file Markdown."*

---

### 1. Luồng Chính & Dữ Liệu (Flow & Data)

*Phần này gộp Giai đoạn 1 và 2 của bản full. Tập trung vào "cái gì" và "như thế nào", bỏ qua "tại sao" vì nó đã quá rõ ràng với dự án nhỏ.*

*   **Luồng hoạt động (User/System Flow):** Mô tả các bước chính, cực kỳ ngắn gọn.
    1.  Người dùng chạy app.
    2.  Hiện ra cửa sổ với nút "Chọn File".
    3.  Người dùng chọn file PDF.
    4.  Bấm nút "Trích xuất".
    5.  App xử lý và lưu file `_highlights.md` bên cạnh file gốc.
    6.  Hiện thông báo "Hoàn thành!".

*   **Dữ liệu (Data I/O):** Chỉ cần mô tả đầu vào và đầu ra.
    *   **Đầu vào:** File PDF.
    *   **Đầu ra:** File Markdown.
    *   **Cấu trúc Output:**
        ```markdown
        # Highlights từ [Tên file]
        - Trang [số]: [Nội dung highlight]
        ```

---

### 2. Checklist Công Việc (Task Breakdown)

*Đây là trái tim của FSD-Lite, gộp từ Giai đoạn 3. Chia nhỏ công việc cho AI, nhưng không cần quá chi tiết như bản full.*

- [ ] **Setup:** Tạo cấu trúc project, cài thư viện (`tkinter`, `PyMuPDF`).
- [ ] **UI:** Dựng giao diện cơ bản với 2 nút ("Chọn File", "Trích xuất") và 1 label trạng thái.
- [ ] **Logic Core:** Viết hàm `extract(file_path)` để mở PDF và lấy highlight.
- [ ] **Logic UI:**
    - [ ] Gắn chức năng chọn file cho nút 1.
    - [ ] Gắn hàm `extract` vào nút 2.
    - [ ] Hiển thị thông báo khi xong.
- [ ] **Đóng gói:** Viết `requirements.txt`.

---

### 3. Lưu Ý Đặc Biệt (Optional)

*Phần này không bắt buộc, chỉ thêm vào nếu có yêu cầu đặc biệt.*
- Dùng thư viện `tkinter` cho GUI.
- Chú ý xử lý lỗi file không tồn tại.