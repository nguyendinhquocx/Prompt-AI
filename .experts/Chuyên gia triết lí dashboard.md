# Prompt Triết Lý Business Chart - Agent AI

## 1. Triết lý tổng thể

- Tối giản, sắc nét, loại bỏ chi tiết thừa.
- Màu sắc nhẹ nhàng, nền trắng tuyệt đối, không hiệu ứng lòe loẹt.
- Đường viền, trục, grid: chỉ giữ tối thiểu, nét mỏng, màu xám/đen nhạt, loại bỏ mọi border thừa.
- Font chữ rõ, nhỏ vừa đủ, không font lạ, không đậm màu, phù hợp slide business.
- Giá trị số trên trục: tự động chuyển đổi đơn vị (triệu/tỉ), luôn làm tròn, không lẻ thập phân, dấu phẩy phân tách chuẩn Việt.
- Nhãn giá trị/bar: font nhỏ, căn phải, background trắng, không bị đè lên biểu đồ.
- Tiêu đề: căn giữa, nổi bật, đẩy lên cao bằng `pad`, không dùng hiệu ứng shadow, không chèn logo.
- Chỉ giữ lại thông tin business quan trọng, loại bỏ chú thích thừa, không dùng icon/emojis.
- Tên chuyên khoa/gói dịch vụ: luôn lấy phần sau dấu ‘ - ’ nếu có.
- Mọi biểu đồ đều phải “business-ready”, phù hợp stakeholder khó tính nhất.

## 2. Code chuẩn Agent AI business chart

- Bar chart: màu trắng, viền đen mỏng, có thể tô xám nhạt cho bar đặc biệt (top/bottom).
- Đường trung bình: nét chấm, mỏng, màu đen, có nhãn số tròn bên phải.
- Trục x: formatter tự động triệu/tỉ, số tròn, dấu phẩy, không thập phân.
- Trục y: chỉ giữ lại hoặc custom nếu cần, nhãn chuyên khoa ngắn gọn.
- Không grid, không nền màu, chỉ giữ trục bottom/left nếu thật sự cần.
- Đặt mọi số, nhãn, tiêu đề, chú thích đúng vị trí business logic, không dàn trải lung tung.

## 3. Khi tạo chart/report, luôn tuân thủ triết lý này:

- Nếu dữ liệu chưa đạt chuẩn, agent AI phải tự động xử lý về đúng format (tên, số, nhãn…).
- Mọi code ví dụ đều có thể copy-paste ra business dashboard mà không phải chỉnh lại.
- Nếu có yêu cầu đặc biệt, chỉ mở rộng triết lý này chứ không phá vỡ nguyên tắc gốc.

---

> Đây là prompt nền tảng, chỉ cần add vào rules cho Agent AI là mọi biểu đồ business sẽ luôn đúng “chuẩn stakeholder khó tính nhất”.