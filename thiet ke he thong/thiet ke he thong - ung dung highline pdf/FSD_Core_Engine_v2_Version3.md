# FSD: F-01 - Core Engine: Lõi trích xuất highlight từ file PDF (v2)

**ID:** F-01
**Trạng thái:** Chờ Thực Thi
**Ngày tạo:** 2025-09-13
**Người thiết kế:** @nguyendinhquocx

---

## GIAI ĐOẠN 1: MỔ XẺ & ĐỊNH NGHĨA

### 1. Tuyên Bố Sứ Mệnh
Xây dựng một module Python (một file `.py` có thể import được) chứa một hàm duy nhất, có khả năng nhận đường dẫn file PDF đầu vào và trả về một cấu trúc dữ liệu chứa các highlight đã được trích xuất hoặc một lỗi có ý nghĩa.

### 2. Bối Cảnh & Vấn Đề
Để xây dựng một ứng dụng có giao diện, logic xử lý nền (backend) phải được tách biệt hoàn toàn khỏi giao diện người dùng (frontend). Module này chính là logic nền, là bộ não của ứng dụng. Việc tách biệt này giúp dễ dàng kiểm thử, tái sử dụng và thay đổi giao diện trong tương lai mà không ảnh hưởng đến nghiệp vụ cốt lõi.

### 3. Tiêu Chí Thành Công
- Module có thể được import vào một script Python khác mà không gây lỗi.
- Hàm chính `extract_highlights` trả về một dictionary chứa dữ liệu khi thành công.
- Hàm chính `extract_highlights` ném (raise) một exception cụ thể (ví dụ `FileNotFoundError`, `NoHighlightsError`) khi thất bại.
- Logic trích xuất hoạt động chính xác và hiệu quả.

---

## GIAI ĐOẠN 2: THIẾT KẾ LUỒNG & CẤU TRÚC

### 1. Kiến Trúc Hàm (Function Architecture)
- **File:** `core_extractor.py`
- **Hàm chính:** `extract_highlights(pdf_path: str) -> dict`
- **Luồng hoạt động của hàm:**
    1. Kiểm tra xem `pdf_path` có tồn tại không. Nếu không, `raise FileNotFoundError("File không tồn tại.")`.
    2. Mở file PDF bằng `fitz` (PyMuPDF).
    3. Lặp qua từng trang, tìm tất cả các annotation loại 'Highlight'.
    4. Nếu không tìm thấy highlight nào sau khi duyệt hết file, `raise NoHighlightsError("Không tìm thấy highlight nào trong file.")`.
    5. Với mỗi highlight, trích xuất nội dung văn bản và số trang.
    6. Nhóm các highlight theo số trang và trả về một dictionary.

### 2. Kiến Trúc Dữ Liệu (Data Architecture)
- **Input:** `pdf_path` (string) - Đường dẫn tuyệt đối đến file PDF.
- **Output (Thành công):** Một dictionary có cấu trúc:
    ```python
    {
        'file_name': 'ten_file.pdf',
        'total_highlights': 15,
        'highlights_by_page': {
            5: [ # Số trang
                "Nội dung highlight thứ nhất trên trang 5.",
                "Nội dung highlight thứ hai trên trang 5."
            ],
            12: [
                "Nội dung highlight trên trang 12."
            ]
        }
    }
    ```
- **Output (Thất bại):** Ném ra các Exception được định nghĩa riêng.
    - `NoHighlightsError`: Một class Exception tùy chỉnh.
    - `InvalidFileTypeError`: Một class Exception tùy chỉnh nếu file không phải PDF.

---

## GIAI ĐOẠN 3: PHÂN RÃ & GIAO VIỆC

### 1. Phân Rã Công Việc (Task Breakdown)
- [ ] Task 1: Tạo file `core_extractor.py`.
- [ ] Task 2: Định nghĩa các class exception tùy chỉnh: `NoHighlightsError(Exception)` và `InvalidFileTypeError(Exception)`.
- [ ] Task 3: Viết khung hàm `extract_highlights(pdf_path: str) -> dict`.
- [ ] Task 4: Bên trong hàm, implement logic kiểm tra sự tồn tại của file và kiểu file, raise exception tương ứng nếu cần.
- [ ] Task 5: Implement logic mở file PDF và lặp qua các trang để tìm annotation 'Highlight'.
- [ ] Task 6: Implement logic trích xuất văn bản từ các vùng được highlight.
- [ ] Task 7: Implement logic tập hợp các highlight vào cấu trúc dictionary đầu ra như đã thiết kế.
- [ ] Task 8: Implement logic kiểm tra nếu không có highlight nào và raise `NoHighlightsError`.
- [ ] Task 9: Viết docstring chi tiết cho hàm `extract_highlights`, giải thích rõ input, output, và các exception có thể xảy ra.
- [ ] Task 10: Tạo một file riêng `test_core.py` để viết các kịch bản kiểm thử cho hàm `extract_highlights` (ví dụ: test với file có highlight, file không có, file không tồn tại).

### 2. Chỉ Dẫn Đặc Biệt
- **Thư viện bắt buộc:** `PyMuPDF`.
- **Nguyên tắc thiết kế:** Module này phải hoàn toàn "headless" (không có bất kỳ lệnh `print` hay tương tác người dùng nào). Mọi kết quả phải được trả về qua `return` hoặc `raise`.
- **Chất lượng code:** Code phải tuân thủ PEP 8, có type hinting rõ ràng.
