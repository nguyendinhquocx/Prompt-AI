# 📝 FSD: [Điền Tên Tính Năng Ở Đây]

**ID:** `F-XX`
**Trạng thái:** `Chờ Thực Thi`
**Ngày tạo:** `YYYY-MM-DD`
**Người thiết kế:** `@nguyendinhquocx`

---

## GIAI ĐOẠN 1: MỔ XẺ & ĐỊNH NGHĨA

### 1. Tuyên Bố Sứ Mệnh (Mission Statement)
*Tính năng này cho phép người dùng **[làm hành động gì]** để đạt được **[kết quả giá trị gì]**.*

### 2. Bối Cảnh & Vấn Đề (Context & Problem)
*Mô tả nỗi đau hiện tại của người dùng. Tại sao chúng ta cần làm cái này?*

### 3. Tiêu Chí Thành Công (Success Criteria)
*Làm sao biết đã làm đúng và làm tốt? (Định lượng nếu có thể)*
- [ ] Tiêu chí 1: ...
- [ ] Tiêu chí 2: ...
- [ ] Tiêu chí 3: ...

---

## GIAI ĐOẠN 2: THIẾT KẾ LUỒNG & CẤU TRÚC

### 1. Luồng Người Dùng (User Flow)
*Mô tả các bước người dùng tương tác, bao gồm cả luồng lỗi.*
1.  **Luồng chính:**
    - Bước 1: ...
    - Bước 2: ...
2.  **Luồng lỗi:**
    - Nếu [điều kiện lỗi]: ...

### 2. Kiến Trúc Dữ Liệu (Data Architecture)
*Các model/bảng dữ liệu mới hoặc cần thay đổi. Chỉ cần rõ các trường chính và mối quan hệ.*
- **Model/Bảng `[Tên]`:**
  - `id`: Primary Key
  - `user_id`: Foreign Key
  - `field_1`: [Kiểu dữ liệu] - [Mô tả]
  - `field_2`: [Kiểu dữ liệu] - [Mô tả]

### 3. Giao Diện & Tương Tác (UI & Interactions)
*Mô tả đơn giản bố cục màn hình và các hành vi. Không cần đẹp, chỉ cần rõ.*
- **Màn hình chính:** Gồm có [thành phần A], [thành phần B].
- **Khi bấm nút A:** Hiện ra [modal C].
- **Modal C:** Có [input D] và [nút E].

---

## GIAI ĐOẠN 3: PHÂN RÃ & GIAO VIỆC

### 1. Phân Rã Công Việc (Task Breakdown)
*Checklist chi tiết cho AI. Mỗi task phải đủ nhỏ để làm và kiểm tra được ngay.*

**Backend:**
- [ ] Task 1: Tạo migration cho bảng `[Tên]`.
- [ ] Task 2: Viết API endpoint `GET /endpoint`.
- [ ] Task 3: Viết API endpoint `POST /endpoint`.

**Frontend:**
- [ ] Task 4: Tạo component `[Tên Component]`.
- [ ] Task 5: Tích hợp API `GET /endpoint` vào component.
- [ ] Task 6: Xử lý logic form cho `POST /endpoint`.

**Kiểm thử & Hoàn thiện:**
- [ ] Task 7: Viết unit test cho logic X.
- [ ] Task 8: Kiểm tra tích hợp E2E.

### 2. Chỉ Dẫn Đặc Biệt (Special Instructions)
*Các quy tắc, yêu cầu phi chức năng, hoặc lưu ý quan trọng cho AI.*
- **Ngôn ngữ/Framework:** Dùng `[Tên ngôn ngữ, framework]`.
- **Thư viện:** Ưu tiên dùng `[Thư viện X]`, không dùng `[Thư viện Y]`.
- **Coding Style:** Tuân thủ theo linter đã cấu hình.
- **Lưu ý:** Chú ý xử lý bất đồng bộ ở `[chức năng Z]`.