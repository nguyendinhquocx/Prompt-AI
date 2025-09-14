# HỆ THỐNG TÁC CHIẾN TINH GỌN: KIẾN TRÚC SƯ - THỢ CẢ

## I. TRIẾT LÝ CỐT LÕI: DAO MỔ TRÂU VS. DAO GỌT HOA QUẢ

Dùng quy trình phức tạp với nhiều agent cho một dự án nhỏ thì khác đéo gì dùng dao mổ trâu để gọt một quả táo. Kết quả là nát bét và tốn thời gian.

Hệ thống này được sinh ra cho các dự án nhỏ (tool Python, webapp Apps Script, landing page đơn giản...). Nó dựa trên nguyên tắc **hiệu quả tối đa** bằng cách hợp nhất hai vai trò vào một con **Agent lai (Hybrid Agent)**, một thằng "Kiến Trúc Sư - Thợ Cả".

Con Agent này có hai chế độ hoạt động riêng biệt:
1.  **[DESIGN MODE]:** Cùng mày thảo luận, phản biện và phác thảo ra một bản vẽ tinh gọn (FSD-Lite).
2.  **[BUILD MODE]:** Nhận lệnh, cắm đầu vào code theo đúng bản vẽ vừa tạo ra.

Mục tiêu là loại bỏ hoàn toàn ma sát và độ trễ của việc chuyển giao, giúp mày đi từ ý tưởng đến sản phẩm chạy được trong một luồng duy nhất.

## II. CÁC VAI TRÒ TRONG HỆ THỐNG

1.  **Kiến Trúc Sư Trưởng (Mày):**
    *   **Nhiệm vụ:** Nắm giữ ý tưởng, ra quyết định cuối cùng ở mọi bước. Mày là người chèo lái.

2.  **Agent Lai (Kiến Trúc Sư - Thợ Cả):**
    *   **Nhiệm vụ:** Là con dao đa năng của mày. Vừa biết đặt câu hỏi để làm rõ yêu cầu, vừa biết tuân lệnh để viết code.

## III. QUY TRÌNH LÀM VIỆC TRÔI CHẢY

### GIAI ĐOẠN 1: THIẾT KẾ (Mày + Agent ở [DESIGN MODE])

**Mục tiêu:** Tạo ra một bản vẽ tinh gọn (FSD-Lite) trong thời gian ngắn nhất.

*   **Bước 1: Khởi Tạo Phiên Làm Việc**
    *   Mở một phiên làm việc mới với AI.
    *   Gửi prompt khởi tạo, bao gồm:
        1.  File định nghĩa danh tính và hai chế độ hoạt động (`AGENT_ARCHITECT_BUILDER_PERSONA.md`).
        2.  File template trống `FSD-Lite_[Template].md`.
        3.  Yêu cầu AI xác nhận đã hiểu vai trò và bắt đầu ở `[DESIGN MODE]`.

*   **Bước 2: Đối Thoại Tinh Gọn**
    *   Agent sẽ bắt đầu đặt câu hỏi cho mày theo các mục trong FSD-Lite: "Mục tiêu là gì?", "Luồng chính gồm mấy bước?", "Checklist công việc nên có những gì?".
    *   Mày trả lời ngắn gọn, tập trung vào những gì cần thiết nhất. Quá trình này thường chỉ mất vài phút.

*   **Bước 3: Chốt Bản Vẽ**
    *   Khi cuộc thảo luận kết thúc, mày ra lệnh cho Agent: "Ok, đủ rồi. Xuất ra file FSD-Lite hoàn chỉnh."
    *   Agent sẽ trình bày lại toàn bộ nội dung file FSD-Lite đã được điền đầy đủ để mày xác nhận lần cuối.

### ĐIỂM RẼ NHÁNH: QUYỀN QUYẾT ĐỊNH CỦA MÀY

Sau khi có bản vẽ FSD-Lite hoàn chỉnh, mày đứng trước hai lựa chọn:

*   **Lựa chọn A (Tiếp tục thi công):** Mày muốn con Agent này code luôn. Mày ra lệnh: **"Ok, bản vẽ xong. Chuyển sang chế độ BUILD."**
*   **Lựa chọn B (Dừng lại & Tải về):** Mày muốn tự code hoặc giao cho một con AI khác (như Claude) mà mày tin tưởng hơn về khả năng code. Mày nói: **"Tốt, dừng ở đây."** Sau đó mày copy/tải file FSD-Lite về và sử dụng riêng.

### GIAI ĐOẠN 2: THI CÔNG (Mày + Agent ở [BUILD MODE])

**Mục tiêu:** Biến bản vẽ thành code chạy được. Giai đoạn này chỉ xảy ra nếu mày chọn Lựa chọn A.

*   **Bước 1: Chuyển Chế Độ**
    *   Agent nhận lệnh và xác nhận: `"Đã chuyển sang [BUILD MODE]. Bắt đầu thực thi checklist."`
    *   Hành vi của Agent thay đổi: nó ngừng hỏi, chỉ tuân lệnh và code.

*   **Bước 2: Vòng Lặp Code & Review**
    *   Agent thực hiện từng task trong checklist của FSD-Lite và đưa code cho mày.
    *   Mày review, chạy thử. Nếu ổn thì ra lệnh: "Tốt, làm task tiếp theo."
    *   Quá trình lặp lại cho đến khi hết checklist.

## IV. KHI NÀO NÊN DÙNG HỆ THỐNG NÀY?

Đây không phải là quy trình để thay thế hệ thống lớn, mà là để bổ sung. Hãy dùng nó khi dự án có các đặc điểm sau:

*   **Quy mô nhỏ:** Một tool tự động hóa, một script, một ứng dụng đơn giản, một trang web tĩnh...
*   **Mục tiêu rõ ràng:** Mày biết chính xác mình muốn gì, không cần quá nhiều phân tích sâu về thị trường hay người dùng.
*   **Tốc độ là ưu tiên:** Mày muốn có sản phẩm chạy được càng nhanh càng tốt để kiểm thử ý tưởng.
*   **Một người thực hiện:** Chủ yếu là mày làm việc với AI, không có team lớn tham gia.

Đối với các dự án lớn, phức tạp, cần sự tách bạch rõ ràng giữa các khâu, hãy quay lại sử dụng hệ thống "Phân Chia Lao Động Trí Tuệ" với hai Agent riêng biệt. Dùng đúng công cụ cho đúng việc, đó mới là đẳng cấp.