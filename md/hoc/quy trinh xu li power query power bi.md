# Tóm tắt quy trình gộp file Excel rác thành file tổng chuẩn chuyên gia

## 1. Chuẩn bị nguồn rác
- Gom hết file cùng cấu trúc vào một folder riêng, đặt tên nhất quán kiểu `YYYY MM doanh thu.xlsx`
- Kiểm tra sơ bộ format: tên sheet, số cột, kiểu dữ liệu, note lại file lỗi để xử lý sau

## 2. Kết nối Power Query tới folder
- Mở Excel > Data > Get Data > From Folder
- Chọn folder chứa file cần gộp
- Combine & Transform Data, chọn đúng sheet
- Tự động import/gộp tất cả file thành 1 bảng tổng

## 3. Xử lý rác trong Power Query
- Kiểm tra cột, kiểu dữ liệu cho nhất quán
- Thêm cột nguồn (Source.Name), extract tháng/năm từ tên file
- Loại bỏ dòng trống, duplicate, dòng lỗi
- Chuẩn hóa giá trị: kiểu ngày/tháng, số, text, mã hàng
- Nếu dòng nào thiếu, lỗi, báo riêng để xử lý

## 4. Đặt lại tên cột (nằm giữa bước combine và transform)
- Sau khi combine file, kiểm tra tên cột
- Đặt lại tên cột cho đồng nhất, chuẩn, dễ trace, hợp chuẩn phân tích
- Đặt tên xong mới bắt đầu các bước transform, chuẩn hóa kiểu dữ liệu

## 5. Tạo file tổng master data
- Close & Load ra sheet/file mới, không sửa trực tiếp
- Dùng làm nguồn cho Power BI, Google Sheets, BigQuery, SQL Server...

## 6. Phân tích, tái sử dụng, copy nguồn khác
- Pivot table, dashboard trực tiếp trên file tổng
- Export/sync sang nguồn khác bằng automation: Apps Script, Power Automate, Dataflow...
- File tổng có trường nguồn, tháng/năm, trace dễ dàng
- Nếu có file mới, chỉ cần thả vào folder, refresh là xong

## 7. Tái xử lý, backup, update
- Sửa file gốc, refresh lại query
- Backup file tổng định kỳ, version theo tháng/năm
- Folder nguồn, file tổng tách biệt, không trộn nhằng

## 8. Logic chuẩn hóa cho tái sử dụng
- Biến bước làm sạch thành hàm tùy chỉnh trong Power Query (.pq), chỉ cần gọi lại là xong
- Lưu template truy vấn/hàm cho dự án khác, truy vấn động, không hardcode đường dẫn

## 9. Mở rộng & kinh nghiệm thực chiến
- Thêm kiểm tra schema tự động, cảnh báo cột lạ nếu cấu trúc thay đổi
- Tích hợp Power Automate, Azure Data Factory cho automation
- Lưu log làm sạch, cảnh báo lỗi cho lần sau
- Luôn xử lý lỗi, loại file bẩn/lạ đầu vào
- Đặt tên truy vấn/hàm rõ ràng, chia nhỏ để tái sử dụng dễ bảo trì

## 10. Tóm tắt cho thằng lười
1. Gom file về 1 thư mục
2. Power Query connect folder, combine
3. Đặt lại tên cột ngay sau combine
4. Transform, làm sạch, chuẩn hóa
5. Tạo file tổng, dùng cho mọi nguồn
6. Refresh, backup, automation, tái sử dụng

---
# Chốt lại
- Đặt lại tên cột nằm giữa combine và transform
- Làm sớm, chuẩn hóa để mọi bước sau mượt mà, automation dễ, chuyển đổi không bị vỡ quy trình