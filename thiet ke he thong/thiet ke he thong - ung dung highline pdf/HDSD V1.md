# Quy Trình Giao Việc Cho AI: **"Blueprint Before Brick" (Bản Vẽ Trước, Gạch Sau)**

## Triết Lý Cốt Lõi
Mày là **Kiến Trúc Sư**, AI là **Thợ Chính**.  
Thợ có giỏi mấy mà không có bản vẽ chi tiết thì cũng chỉ xây được cái chuồng lợn.  
Bản vẽ của mày phải trả lời được 3 câu hỏi:

- **WHAT:** Xây cái gì?
- **WHY:** Tại sao lại xây như vậy?
- **HOW:** Làm thế nào để biết đã xây đúng?

Quy trình này gồm 4 giai đoạn, gói gọn trong một tài liệu duy nhất cho mỗi tính năng lớn – gọi là **FSD (Feature Specification Document)**.

---

## Giai Đoạn 1: Deconstruct – Mổ Xẻ & Định Nghĩa (Mày làm)

### 1.1. Tuyên Bố Sứ Mệnh (Mission Statement)
Viết đúng 1 câu duy nhất mô tả tính năng này để làm cái đéo gì.  
Ví dụ:  
> "Tính năng này cho phép người dùng [làm hành động gì] để đạt được [kết quả giá trị gì]."

✅ **Mục đích:** Giữ cho cả mày và AI không đi lạc.

### 1.2. Bối Cảnh & Vấn Đề (Context & Problem)
- Tại sao tính năng này cần tồn tại?
- Nó giải quyết nỗi đau nào của người dùng?
- Mô tả tình huống hiện tại và sự bất cập của nó.

✅ **Mục đích:** Giúp AI hiểu "linh hồn" của tính năng để code thông minh, không chỉ code ngu.

### 1.3. Tiêu Chí Thành Công (Success Criteria)
Liệt kê 3–5 tiêu chí đo lường được để xác định tính năng đã DONE.

Ví dụ:
- Tỷ lệ người dùng hoàn thành quy trình X tăng 20%.
- Thời gian thực hiện tác vụ Y giảm 50%.
- Số lượng ticket hỗ trợ liên quan đến vấn đề Z giảm xuống 0.

✅ **Mục đích:** Định nghĩa "DONE" rõ ràng.

---

## Giai Đoạn 2: Architect – Thiết Kế Luồng & Cấu Trúc (Mày làm)

### 2.1. Luồng Người Dùng (User Flow)
Mô tả từng bước người dùng tương tác, từ đầu đến cuối.  
Ví dụ:

- Bấm "Tạo Báo Cáo"
- Hiện modal cấu hình
- Chọn ngày, loại báo cáo
- Bấm "Xuất Báo Cáo"
- Hệ thống xử lý -> tải file Excel

⚠️ **Nhớ mô tả luồng phụ & luồng lỗi** (chọn ngày sai, lỗi xử lý, v.v).

### 2.2. Kiến Trúc Dữ Liệu (Data Architecture)
- Cần dữ liệu gì?
- Lưu ở đâu? Cấu trúc thế nào?

Ví dụ:
```
Bảng Reports:
- id
- user_id
- type
- config (JSON)
- status
- created_at
- file_url
```

### 2.3. Giao Diện & Tương Tác (UI & Interactions)
Mô tả bố cục màn hình, các thành phần chính, cách chúng tương tác.

Ví dụ:  
"Màn hình có bảng danh sách báo cáo. Mỗi hàng có tên, ngày tạo, trạng thái, nút 'Tải về'. Phía trên có nút 'Tạo Báo Cáo Mới'."

---

## Giai Đoạn 3: Instruct – Phân Rã & Giao Việc (Mày làm)

### 3.1. Phân Rã Công Việc (Task Breakdown)
Dựa vào giai đoạn 2, chia nhỏ toàn bộ tính năng thành các task cụ thể.  
Dùng checklist dạng `[ ]` trong Markdown.

Ví dụ:
- [ ] Backend: Tạo migration cho bảng `reports`
- [ ] Backend: Tạo API POST `/reports` để tạo báo cáo
- [ ] Backend: Tạo API GET `/reports/:id` để lấy trạng thái
- [ ] Frontend: Dựng component Bảng Danh Sách Báo Cáo
- [ ] Frontend: Dựng Modal Tạo Báo Cáo
- [ ] Frontend: Tích hợp API hiển thị dữ liệu

### 3.2. Chỉ Dẫn Đặc Biệt (Special Instructions)
Liệt kê các quy định hoặc yêu cầu phi chức năng.

Ví dụ:
- Tất cả code phải có comment rõ ràng
- Phải có unit test
- Dùng thư viện X, không dùng thư viện Y
- Chú ý hiệu năng khi xử lý dữ liệu

---

## Giai Đoạn 4: Execute & Verify – Thực Thi & Kiểm Tra (AI làm, Mày giám sát)

### 4.1. Giao Việc
Gửi toàn bộ tài liệu FSD cho Claude.  
Câu lệnh:

> "Đây là toàn bộ đặc tả cho tính năng [Tên tính năng]. Đọc và hiểu kỹ. Bắt đầu thực hiện task đầu tiên trong checklist: [Tên task đầu tiên]."

### 4.2. Vòng Lặp Thực Thi
- AI làm xong -> báo cáo -> mày kiểm tra.
- Nếu ổn -> mày dán vào project -> tick `[x]` vào checklist -> giao task tiếp theo.
- Nếu dở -> chửi, feedback, bắt làm lại.

### 4.3. Quản Lý Trạng Thái
FSD với checklist chính là "bộ não ngoài" của dự án.  
Mày nghỉ, quay lại vẫn biết đang ở đâu.

---

## Lợi Ích Của Quy Trình

- **Tinh Gọn:** Không có sprint, backlog, story point. Chỉ có một tài liệu, một checklist.
- **Tập Trung:** Giai đoạn 1 & 2 bắt mày suy nghĩ như kiến trúc sư, không phải culi code.
- **Chống Quên:** Checklist là chân lý. Cả mày và AI đều không lạc.
- **Dễ Kiểm Soát:** Mỗi task là một đơn vị kiểm chứng được.
- **Dễ Mở Rộng:** Tính năng phức tạp -> chỉ cần chia nhỏ hơn, khung quy trình giữ nguyên.
- **Tái Sử Dụng:** Tài liệu FSD là kho tri thức. Người mới vào đọc là hiểu, AI mới vào đọc là làm được.

---

> **Kết Luận:**  
> Trước khi gõ một chữ code, hãy tự hỏi: **"Bản vẽ của tao đâu?"**  
> Làm FSD trước sẽ tốn ít thời gian ban đầu, nhưng tiết kiệm hàng trăm giờ sửa lỗi và cãi nhau về sau.

---

# Hướng Dẫn Chỉ Huy Claude

## 1. Khởi Động (The Kick-off)

1. **Mở một cuộc hội thoại mới với Claude.**
2. **Copy toàn bộ nội dung của file `FSD_Core_Engine.md` và dán vào prompt đầu tiên.**
3. **Kết thúc prompt** bằng một mệnh lệnh rõ ràng, như trong file `LOG_2025-09-13.md`:  
   > "Đọc và hiểu cho kỹ. Bắt đầu thực hiện task đầu tiên trong checklist: [Tên task đầu tiên]".

---

## 2. Vòng Lặp Thực Thi (The Loop)

### Giao Việc
- Giao cho AI từng task một (hoặc một cụm 2-3 task nhỏ liên quan).  
- Đừng giao cả cái FSD một lúc rồi bảo nó "code đi". Làm thế nó sẽ bị ngợp và code ngu.

### Nhận Code
- AI sẽ trả về các đoạn code.

### Kiểm Tra & Tích Hợp
- Mày là **Kiến Trúc Sư**.  
- Mở project, tạo file, dán code vào, chạy thử.

### Phản Hồi
- **Nếu code ngon:**  
  "Tốt. Code chạy đúng. Giờ làm task tiếp theo: [Tên task tiếp theo]".

- **Nếu code ngu hoặc lỗi:**  
  "Code này lỗi rồi. Khi chạy với file X nó báo lỗi Y. Mày phải xử lý cả trường hợp Z nữa. Sửa lại cho tao."

### Cập Nhật
- Sau mỗi lần hoàn thành một task và đã xác nhận:
  - Mở file `FSD_Core_Engine.md` và đánh dấu `[x]` vào task đó.
  - Ghi lại vào file LOG của ngày hôm đó.

---

## 3. Hoàn Tất & Nâng Cấp

1. Khi tất cả các task trong `FSD_Core_Engine.md` đã được đánh dấu `[x]`, nghĩa là mày đã có phiên bản đầu tiên của sản phẩm.
2. Mở file `00_PROJECT_DASHBOARD.md`, đổi trạng thái của **F-01** thành ✅ **Hoàn thành**.
3. Bắt đầu thiết kế cho **F-02** bằng cách tạo file `FSD_Batch_Processing.md` mới và **lặp lại quy trình**.

---

## Triết Lý
Quy trình này biến mày từ một người có ý tưởng thành **Kiến Trúc Sư Trưởng**,  
còn AI là **đội thi công lành nghề**.  
Mày không cần tự tay đặt từng viên gạch, nhưng mày phải là người cầm bản vẽ, giám sát chất lượng và quyết định hướng đi.
