# HỆ THỐNG KIẾN TẠO PHẦN MỀM VỚI AI: PHÂN CHIA LAO ĐỘNG TRÍ TUỆ

## I. TRIẾT LÝ CỐT LÕI

Hệ thống này dựa trên một nguyên tắc cơ bản: **Chuyên môn hóa**. Thay vì bắt một con AI duy nhất làm tất cả mọi việc từ tư duy chiến lược đến code chi tiết, chúng ta phân chia công việc thành hai vai trò riêng biệt, tương ứng với hai loại hình trí tuệ khác nhau:

1.  **Trí tuệ Phân tích & Kiến trúc (The Architect Mind):** Giỏi đặt câu hỏi, phản biện, cấu trúc hóa ý tưởng, và thiết kế hệ thống ở tầm vĩ mô.
2.  **Trí tuệ Thực thi & Lắp ráp (The Builder Mind):** Giỏi tuân thủ bản vẽ, viết code sạch, và hoàn thành các nhiệm vụ cụ thể một cách hiệu quả.

Việc cố gắng bắt một con AI làm cả hai sẽ dẫn đến kết quả hời hợt: nó vừa thiết kế thiếu sâu sắc, vừa code thiếu tập trung. Hệ thống này giải quyết triệt để vấn đề đó.

## II. CÁC VAI TRÒ TRONG HỆ THỐNG

1.  **Kiến Trúc Sư Trưởng (Mày):**
    *   **Nhiệm vụ:** Là người nắm giữ tầm nhìn cuối cùng. Đưa ra ý tưởng ban đầu và là người ra quyết định cuối cùng.
    *   **Trách nhiệm:** Giám sát toàn bộ quy trình, đảm bảo chất lượng đầu ra ở mỗi giai đoạn.

2.  **Agent Phân Tích (Kiến Trúc Sư Phụ):**
    *   **Danh tính:** `Quantum Problem Analysis & Solution Flow Architect`.
    *   **Nhiệm vụ:** Đối tác tư duy của mày. Giúp mày mổ xẻ ý tưởng, đặt câu hỏi phản biện, và cấu trúc hóa suy nghĩ thành một bộ tài liệu đặc tả (FSD) hoàn chỉnh.
    *   **Đặc điểm:** Không code. Chỉ tư duy, phân tích, và lập kế hoạch.

3.  **Agent Thực Thi (Thợ Cả AI - Ví dụ: Claude):**
    *   **Danh tính:** Một con AI thuần code.
    *   **Nhiệm vụ:** Nhận bản vẽ (FSD) đã hoàn chỉnh và thực thi từng task trong đó một cách răm rắp.
    *   **Đặc điểm:** Không tự ý sáng tạo ngoài bản vẽ. Chỉ nhận lệnh, code, và báo cáo.

## III. QUY TRÌNH LÀM VIỆC HAI GIAI ĐOẠN

### GIAI ĐOẠN 1: THIẾT KẾ CHIẾN LƯỢC (Mày + Agent Phân Tích)

**Mục tiêu:** Biến một ý tưởng mơ hồ thành một bộ "bản vẽ" chi tiết, không kẽ hở.

*   **Bước 1: Triệu Hồi Agent Phân Tích**
    *   Mở một phiên làm việc mới với AI.
    *   Gửi prompt khởi tạo, bao gồm:
        1.  File định nghĩa danh tính và giao thức làm việc (`AGENT_MASTER_ANALYST_PERSONA.md`).
        2.  Các file template trống cần được điền (`00_PROJECT_DASHBOARD.md`, `FSD_[Template].md`).
        3.  Yêu cầu AI xác nhận đã hiểu vai trò và sẵn sàng bắt đầu.

*   **Bước 2: Đối Thoại Gợi Mở & Phản Biện**
    *   Agent sẽ không tự điền thông tin. Thay vào đó, nó sẽ dẫn dắt mày qua từng mục của tài liệu FSD bằng cách đặt câu hỏi (phương pháp Socratic).
    *   Mày trả lời, tranh luận, và động não.
    *   Agent sẽ phản biện nếu phát hiện mâu thuẫn, thiếu sót (ví dụ: bỏ qua luồng lỗi, task quá lớn), buộc mày phải suy nghĩ sâu hơn.

*   **Bước 3: Hoàn Thiện & Xuất Bản Vẽ**
    *   Khi cuộc thảo luận kết thúc, mày ra lệnh cho Agent tổng hợp lại tất cả thông tin.
    *   Agent sẽ điền toàn bộ thông tin đã được thống nhất vào các file template và xuất ra các file Markdown hoàn chỉnh.
    *   **Kết quả:** Mày có trong tay một file `FSD_[Tên_Tính_Năng].md` chi tiết, logic, sẵn sàng để thi công.

### GIAI ĐOẠN 2: THI CÔNG THỰC THI (Mày + Agent Thực Thi)

**Mục tiêu:** Biến "bản vẽ" thành code chạy được.

*   **Bước 1: Giao Việc Cho Agent Thực Thi**
    *   Mở một phiên làm việc **hoàn toàn mới** với một AI chuyên code (Claude).
    *   Gửi prompt khởi tạo, bao gồm:
        1.  Toàn bộ nội dung file `FSD_[Tên_Tính_Năng].md` đã hoàn thiện ở Giai đoạn 1.
        2.  Mệnh lệnh rõ ràng: "Đây là toàn bộ đặc tả. Đọc và hiểu kỹ. Bắt đầu thực hiện task đầu tiên trong checklist: `[Tên task đầu tiên]`."

*   **Bước 2: Vòng Lặp Thực Thi & Giám Sát**
    *   Agent Thực Thi code và gửi lại kết quả cho từng task.
    *   Mày (Kiến Trúc Sư Trưởng) review code, chạy thử, và xác nhận chất lượng.
    *   Nếu code ổn, mày cập nhật checklist trong file FSD (đánh dấu `[x]`) và ra lệnh cho Agent làm task tiếp theo.
    *   Nếu code lỗi, mày yêu cầu nó sửa lại đúng task đó cho đến khi đạt yêu cầu.

*   **Bước 3: Hoàn Tất & Tích Hợp**
    *   Lặp lại Bước 2 cho đến khi toàn bộ checklist trong FSD được hoàn thành.
    *   Mày có trong tay một tính năng hoàn chỉnh, được xây dựng chính xác theo bản vẽ.
    *   Cập nhật trạng thái của tính năng trong file `00_PROJECT_DASHBOARD.md`.

## IV. LỢI ÍCH VƯỢT TRỘI CỦA HỆ THỐNG

1.  **Chất Lượng Tối Thượng:** Việc tách biệt hai giai đoạn đảm bảo cả khâu thiết kế và khâu thi công đều được thực hiện một cách sâu sắc và tập trung nhất.
2.  **Giảm Thiểu Rủi Ro:** Các lỗ hổng logic, mâu thuẫn, và thiếu sót được phát hiện và xử lý ngay ở Giai đoạn 1 (giai đoạn thiết kế), nơi chi phí thay đổi là rẻ nhất.
3.  **Tăng Tốc Độ Thực Thi:** Agent Thực Thi không phải tốn thời gian suy nghĩ "nên làm gì", nó chỉ cần tập trung vào việc "làm như thế nào" theo một checklist cực kỳ rõ ràng, giúp tăng tốc độ code lên nhiều lần.
4.  **Kiến Thức Được Hệ Thống Hóa:** Toàn bộ quá trình tư duy và thiết kế được lưu lại trong các tài liệu FSD, tạo thành một tài sản tri thức vô giá cho dự án, dễ dàng bàn giao hoặc mở rộng sau này.
5.  **Mày Nắm Toàn Quyền Kiểm Soát:** Mày luôn là người ra quyết định cuối cùng ở mỗi cổng chất lượng (quality gate): duyệt bản vẽ và duyệt code. AI chỉ là công cụ, mày mới là kiến trúc sư.