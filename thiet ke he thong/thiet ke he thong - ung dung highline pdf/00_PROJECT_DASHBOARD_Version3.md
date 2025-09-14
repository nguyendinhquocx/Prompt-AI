# BẢNG ĐIỀU KHIỂN DỰ ÁN: PDF Insight Extractor

**Cập nhật lần cuối:** 2025-09-13

## TẦM NHÌN & SỨ MỆNH DỰ ÁN

Xây dựng một ứng dụng desktop (Python) cho phép người dùng dễ dàng trích xuất các đoạn văn bản được highlight từ file PDF và lưu chúng thành một file Markdown có cấu trúc. Mục tiêu là biến kiến thức bị lãng quên trong các file PDF thành một thư viện tri thức có thể tìm kiếm và sử dụng được.

## BẢNG THEO DÕI TÍNH NĂNG (FEATURE TRACKING)

| ID | Tính Năng (Feature) | Trạng Thái | Người Phụ Trách | Link đến FSD | Ghi Chú |
|:---|:---|:---|:---|:---|:---|
| F-01 | **Core Engine:** Lõi trích xuất highlight từ file PDF | 🔵 Chờ Thực Thi | @Claude-Agent | [FSD_Core_Engine_v2.md](./FSD_Core_Engine_v2.md) | Trái tim của ứng dụng, không có giao diện. |
| F-02 | **GUI Layer:** Giao diện người dùng cơ bản | 🔵 Chờ Thực Thi | @Claude-Agent | [FSD_GUI_Layer.md](./FSD_GUI_Layer.md) | Xây dựng bộ mặt cho ứng dụng. |
| F-03 | **Integration:** Tích hợp Core Engine vào GUI | ⚫️ Đang Thiết Kế | @nguyendinhquocx | | Kết nối não bộ với cơ thể. |
| F-04 | **Batch Processing:** Xử lý hàng loạt file | ⚪️ Ý Tưởng | @nguyendinhquocx | | Tính năng nâng cao cho phiên bản sau. |
| F-05 | **Packaging:** Đóng gói thành file thực thi (.exe) | ⚪️ Ý Tưởng | @nguyendinhquocx | | Để phân phối cho người dùng cuối. |

---
**Định nghĩa Trạng Thái:**
- ⚪️ **Ý Tưởng (Idea):** Mới chỉ là ý nghĩ.
- ⚫️ **Đang Thiết Kế (Designing):** Mày đang trong quá trình viết FSD.
- 🔵 **Chờ Thực Thi (Ready for Dev):** Bản vẽ FSD đã hoàn tất, sẵn sàng giao cho AI.
- 🟡 **Đang Thực Thi (In Progress):** AI đang code.
- ✅ **Hoàn thành (Done):** Đã code xong, tích hợp, kiểm thử.