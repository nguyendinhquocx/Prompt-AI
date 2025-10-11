# Bộ soạn thảo Nâng cao Power Query – M Language cho dân chơi dữ liệu

## 1. Bản chất Bộ soạn thảo Nâng cao
- Là cổng để truy cập, chỉnh sửa trực tiếp code M Language phía sau Power Query.
- Cho phép thao tác logic xử lý dữ liệu chi tiết, không bị giới hạn bởi giao diện GUI.

## 2. Sức mạnh của dân chuyên
- Kiểm soát tuyệt đối các bước biến đổi, logic, tham số, hàm custom, xử lý lỗi.
- Tái sử dụng, tối ưu hóa: Viết hàm dùng lại, sửa một chỗ ăn mọi nơi.
- Hiệu năng: Quản lý query folding, đẩy xử lý về nguồn dữ liệu.
- Automation: Biến thao tác lặp lại thành hàm tự động.
- Xử lý kịch bản phức tạp: Merge, split, pivot, API, dataflow, regex, mapping...

## 3. Cách dùng cơ bản
- Mở Bộ soạn thảo Nâng cao 
- Xem logic toàn bộ truy vấn dưới dạng code
- Chỉnh, thêm, xóa, viết lại logic, thêm hàm, lồng ghép IF, TRY, LIST, TABLE…
- Debug nhanh, sửa trực tiếp code, không mò từng bước GUI.

## 4. Kịch bản ứng dụng bá đạo
- Xử lý file hàng loạt, đọc API động, làm sạch dữ liệu siêu bẩn, tối ưu hóa refresh.

## 5. Lưu ý cho thằng chưa tỉnh ngộ
- Muốn làm chủ phải học M Language, kiểu dữ liệu, cú pháp.
- Đọc code, viết hàm, hiểu rõ list, table, record.
- Không biết thì search "M Language Power Query".

## 6. Chiến lược chuẩn hóa, tái sử dụng
- Đặt tên bước rõ ràng, tiếng Việt, chức năng từng bước.
- Bước sau dùng lại tên bước trước, dễ sửa, dễ bảo trì.
- “in” là tên bước cuối cùng, muốn debug đổi “in” thành tên bước muốn test.
- Tách nhỏ từng xử lý, comment code nếu cần.
- Viết hàm cho logic lặp lại, copy đoạn code sang truy vấn khác cực nhanh.
- Kiểm tra query folding để tối ưu hiệu năng.

## 7. Quy trình chuẩn hóa Power Query
1. Bấm GUI để sinh bước cơ bản.
2. Vào Bộ soạn thảo Nâng cao sửa tên, tối ưu logic, viết hàm.
3. Tách xử lý độc lập thành hàm dùng lại.
4. Comment code chú thích rõ ràng.
5. Lưu template hoặc copy sang truy vấn mới khi cần.

## 8. Ví dụ đoạn mã chuẩn hóa

```powerquery
let
    // 1. Kết nối nguồn Google BigQuery
    Nguon_BigQuery = GoogleBigQuery.Database(),
    // 2. Truy xuất database "hoan-my-sai-gon"
    DB_HoanMy = Nguon_BigQuery{[Name="hoan-my-sai-gon"]}[Data],
    // 3. Lấy schema "kdx"
    Schema_KDX = DB_HoanMy{[Name="kdx", Kind="Schema"]}[Data],
    // 4. Lấy bảng "thongtingoikham"
    Table_ThongTinGoiKham = Schema_KDX{[Name="thongtingoikham", Kind="Table"]}[Data],
    // 5. Lọc hàng theo điều kiện
    Bang_DaLoc = Table.SelectRows(Table_ThongTinGoiKham, each ([note] = null) and ([ten_goi_kham_his] <> null)),
    // 6. Chọn cột cần thiết
    Bang_ChonCot = Table.SelectColumns(Bang_DaLoc, {"ten_goi", "gia_goi_goc", "khuyen_mai", "gia_goi_sau_cung", "ma_goi_new", "ten_doi_tuong", "ten_loai_hinh", "ten_nhom"}),
    // 7. Đổi kiểu dữ liệu
    Bang_DoiKieuDuLieu = Table.TransformColumnTypes(Bang_ChonCot, {{"khuyen_mai", Percentage.Type}}),
    // 8. Sắp xếp theo "gia_goi_goc" giảm dần
    Bang_SapXep = Table.Sort(Bang_DoiKieuDuLieu, {{"gia_goi_goc", Order.Descending}})
in
    Bang_SapXep
```

## 9. Hàm tối ưu cho tái sử dụng

```powerquery
let
    XuLy_ThongTinGoiKham = (BangDauVao as table) as table =>
    let
        Bang_DaLoc = Table.SelectRows(BangDauVao, each ([note] = null) and ([ten_goi_kham_his] <> null)),
        Bang_ChonCot = Table.SelectColumns(Bang_DaLoc, {"ten_goi", "gia_goi_goc", "khuyen_mai", "gia_goi_sau_cung", "ma_goi_new", "ten_doi_tuong", "ten_loai_hinh", "ten_nhom"}),
        Bang_DoiKieuDuLieu = Table.TransformColumnTypes(Bang_ChonCot, {{"khuyen_mai", Percentage.Type}}),
        Bang_SapXep = Table.Sort(Bang_DoiKieuDuLieu, {{"gia_goi_goc", Order.Descending}})
    in
        Bang_SapXep
in
    XuLy_ThongTinGoiKham(Table_ThongTinGoiKham)
```

## 10. Chốt
- Đặt tên rõ ràng, chia nhỏ từng bước, comment code, tối ưu cho bảo trì/mở rộng.
- Viết hàm để tái sử dụng, nguồn nào cũng chạy được.
- Đừng để code như bãi rác, quay lại đọc chỉ muốn đập mặt vào tường.