# FSD: F-02 - GUI Layer: Giao diện người dùng cơ bản

**ID:** F-02
**Trạng thái:** Chờ Thực Thi
**Ngày tạo:** 2025-09-13
**Người thiết kế:** @nguyendinhquocx

---

## GIAI ĐOẠN 1: MỔ XẺ & ĐỊNH NGHĨA

### 1. Tuyên Bố Sứ Mệnh
Xây dựng một ứng dụng có giao diện đồ họa (GUI) đơn giản bằng Python, cho phép người dùng chọn một file PDF, thực hiện trích xuất, và xem kết quả trực tiếp trên giao diện.

### 2. Bối Cảnh & Vấn Đề
Người dùng không chuyên về kỹ thuật không thể sử dụng script dòng lệnh. Họ cần một giao diện trực quan với các nút bấm rõ ràng để thực hiện công việc.

### 3. Tiêu Chí Thành Công
- Ứng dụng khởi chạy và hiển thị một cửa sổ giao diện.
- Người dùng có thể bấm nút để mở hộp thoại chọn file.
- Sau khi xử lý, kết quả được hiển thị trên giao diện.
- Các thông báo lỗi (file không có highlight, file không tồn tại) được hiển thị một cách thân thiện cho người dùng.

---

## GIAI ĐOẠN 2: THIẾT KẾ LUỒNG & CẤU TRÚC

### 1. Phác Thảo Giao Diện (Wireframe)
Cửa sổ ứng dụng sẽ có bố cục như sau:

```
+-------------------------------------------------------------+
| CỬA SỔ ỨNG DỤNG: PDF HIGHLIGHT EXTRACTOR                     |
+-------------------------------------------------------------+
|                                                             |
|  [ Nút: Chọn File PDF ]   [ Label: (Chưa chọn file nào) ]   |
|                                                             |
|  [ Nút: Bắt đầu trích xuất ]                                 |
|                                                             |
|  [ Label: Trạng thái: Sẵn sàng ]                            |
|                                                             |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |   VÙNG KẾT QUẢ (TEXT AREA - CHỈ ĐỌC)                   |  |
|  |   Hiển thị nội dung file Markdown sau khi trích xuất   |  |
|  |                                                       |  |
|  |                                                       |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ Nút: Lưu kết quả ra file .md ]                           |
|                                                             |
+-------------------------------------------------------------+
```

### 2. Luồng Người Dùng (User Flow)
1.  Người dùng khởi chạy ứng dụng. Cửa sổ chính hiện ra. Nút "Bắt đầu trích xuất" và "Lưu kết quả" bị vô hiệu hóa (disabled).
2.  Người dùng bấm nút "Chọn File PDF".
3.  Hộp thoại chọn file của hệ điều hành hiện ra. Người dùng chọn một file `.pdf`.
4.  Đường dẫn file được hiển thị ở label bên cạnh nút "Chọn File". Nút "Bắt đầu trích xuất" được kích hoạt (enabled).
5.  Người dùng bấm "Bắt đầu trích xuất".
    - Label "Trạng thái" đổi thành "Đang xử lý...".
    - Giao diện gọi hàm `extract_highlights` từ module `core_extractor`.
6.  **Kịch bản thành công:**
    - Hàm trả về dictionary dữ liệu.
    - Giao diện định dạng dữ liệu này thành chuỗi Markdown.
    - Chuỗi Markdown được hiển thị trong "Vùng kết quả".
    - Label "Trạng thái" đổi thành "Hoàn thành! Đã tìm thấy X highlights."
    - Nút "Lưu kết quả" được kích hoạt.
7.  **Kịch bản thất bại:**
    - Hàm `extract_highlights` ném ra một exception.
    - Giao diện bắt (catch) exception này.
    - Một hộp thoại thông báo lỗi hiện ra với nội dung thân thiện (ví dụ: "Lỗi: Không tìm thấy highlight nào trong file này.").
    - Label "Trạng thái" đổi thành "Thất bại. Vui lòng thử lại."
8.  Nếu thành công, người dùng bấm "Lưu kết quả".
9.  Hộp thoại lưu file của hệ điều hành hiện ra, gợi ý tên file là `[tên_file_gốc]_highlights.md`.
10. Người dùng chọn vị trí và lưu file. Một thông báo nhỏ xác nhận đã lưu thành công.

---

## GIAI ĐOẠN 3: PHÂN RÃ & GIAO VIỆC

### 1. Phân Rã Công Việc (Task Breakdown)
- [ ] Task 1: Tạo file `main_gui.py`.
- [ ] Task 2: Import thư viện GUI (ví dụ: `tkinter`).
- [ ] Task 3: Dựng khung cửa sổ chính của ứng dụng.
- [ ] Task 4: Thêm các widget vào cửa sổ theo wireframe: các nút (Button), các nhãn (Label), vùng văn bản (Text).
- [ ] Task 5: Viết hàm xử lý sự kiện cho nút "Chọn File PDF", mở hộp thoại chọn file và lưu đường dẫn đã chọn.
- [ ] Task 6: Viết hàm xử lý sự kiện cho nút "Bắt đầu trích xuất".
- [ ] Task 7: Trong hàm ở Task 6, import và gọi hàm `extract_highlights` từ `core_extractor.py`.
- [ ] Task 8: Implement khối `try...except` để xử lý các kết quả thành công và các exception trả về từ `core_extractor`.
- [ ] Task 9: Viết hàm để định dạng dictionary kết quả thành chuỗi Markdown.
- [ ] Task 10: Viết logic để hiển thị chuỗi Markdown hoặc thông báo lỗi lên giao diện.
- [ ] Task 11: Viết hàm xử lý sự kiện cho nút "Lưu kết quả", mở hộp thoại lưu file và ghi nội dung từ vùng kết quả vào file.
- [ ] Task 12: Implement logic vô hiệu hóa/kích hoạt các nút bấm tùy theo trạng thái của ứng dụng.

### 2. Chỉ Dẫn Đặc Biệt
- **Thư viện GUI đề xuất:** `Tkinter` (có sẵn trong Python) cho sự đơn giản, hoặc `PyQt`/`PySide` nếu muốn phức tạp và đẹp hơn. Hãy bắt đầu với `Tkinter`.
- **Nguyên tắc thiết kế:** File `main_gui.py` chỉ chứa code liên quan đến giao diện. Nó không được chứa logic nghiệp vụ trích xuất PDF. Nó **import và sử dụng** `core_extractor.py` như một công cụ.
- **Trải nghiệm người dùng:** Phải có phản hồi trực quan cho mọi hành động (thay đổi trạng thái, thông báo lỗi). Không để ứng dụng bị "đơ" trong lúc xử lý file nặng (cân nhắc dùng `threading` cho các phiên bản sau).
