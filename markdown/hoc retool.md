# RETOOL - HƯỚNG DẪN CẦM TAY CHỈ VIỆC CHO NGƯỜI MỚI

## BƯỚC 1: HIỂU GIAO DIỆN CƠ BẢN (5 phút đầu)

### Khi vào Retool, bạn sẽ thấy:

**LEFT SIDEBAR (Thanh bên trái):**
- Apps: Danh sách ứng dụng của bạn
- Workflows: Tự động hóa
- Databases: Kết nối database
- Resources: Các nguồn dữ liệu

**MAIN AREA (Khu vực chính):**
- Canvas: Nơi kéo thả components
- Component Panel (bên phải): Thuộc tính của component đang chọn
- Bottom Panel: Code, Query, State tabs

**TOP BAR:**
- Preview: Xem app như end user
- Share: Chia sẻ app
- Settings: Cài đặt app

## BƯỚC 2: TẠO APP ĐẦU TIÊN (10 phút)

### Thao tác cụ thể:

1. **Click "Create new" > "App"**
2. **Chọn "Start from scratch"**
3. **Đặt tên app**: "My First Dashboard"
4. **Click "Create app"**

### Bạn sẽ thấy:
- Canvas trống màu trắng
- Components panel bên phải với nhiều component
- Bottom panel có Query editor

## BƯỚC 3: THÊM COMPONENT ĐẦU TIÊN

### Thêm Text Component:
1. **Tìm "Text" trong Components panel**
2. **Drag Text vào Canvas**
3. **Double-click vào text để edit**
4. **Gõ: "My First Retool App"**
5. **Enter để save**

### Styling cơ bản:
1. **Click vào Text component**
2. **Bên phải, tìm section "Appearance"**
3. **Font size: đổi thành 24**
4. **Text align: Center**

## BƯỚC 4: THÊM DỮ LIỆU SAMPLE

### Tạo Query với sample data:
1. **Click "+ New" ở bottom panel**
2. **Chọn "Resource query"**
3. **Chọn "Sample data"**
4. **Đặt tên query: "sampleUsers"**
5. **Click "Create query"**

### Chọn sample data:
1. **Trong query editor, chọn "Users" dataset**
2. **Click "Run query" (nút play)**
3. **Bạn sẽ thấy data preview bên dưới**

## BƯỚC 5: HIỂN THỊ DỮ LIỆU BẰNG TABLE

### Thêm Table component:
1. **Drag "Table" từ Components panel vào Canvas**
2. **Đặt dưới Text component**
3. **Click vào Table**

### Kết nối data:
1. **Bên phải, tìm "Data source"**
2. **Trong dropdown, chọn "sampleUsers"**
3. **Table sẽ tự động hiển thị data**

### Cải thiện Table:
1. **Trong Table settings, bật "Search"**
2. **Bật "Download"**
3. **Bật "Pagination"**

## BƯỚC 6: THÊM TƯƠNG TÁC CỚ BẢN

### Thêm Button:
1. **Drag "Button" vào Canvas**
2. **Đặt text: "Refresh Data"**
3. **Click vào Button**

### Tạo Event Handler:
1. **Bên phải, tìm "Event handlers"**
2. **Click "+ Add handler"**
3. **Event: Click**
4. **Action: Run query**
5. **Query: sampleUsers**
6. **Click "Save"**

## BƯỚC 7: PREVIEW VÀ TEST

### Test app:
1. **Click "Preview" ở top bar**
2. **Test search trong table**
3. **Click button "Refresh Data"**
4. **Click "Edit" để quay lại edit mode**

## BƯỚC 8: LAYOUT CẢI THIỆN

### Sắp xếp components:
1. **Click và drag để di chuyển components**
2. **Resize bằng cách drag các góc**
3. **Align components cho đẹp**

### Thêm Container:
1. **Drag "Container" vào Canvas**
2. **Drag các components vào Container**
3. **Set Container title: "User Management"**

## BƯỚC 9: SAVE VÀ DEPLOY

### Save app:
1. **Ctrl+S hoặc click "Save"**
2. **App tự động save**

### Share app:
1. **Click "Share"**
2. **Copy link để chia sẻ**
3. **Hoặc invite team members**

## TIPS QUAN TRỌNG CHO NGƯỜI MỚI

### Navigation cơ bản:
- **Ctrl+Z**: Undo
- **Delete**: Xóa component đang chọn
- **Ctrl+D**: Duplicate component
- **Space + drag**: Pan around canvas

### Debugging:
- **Console tab**: Xem errors
- **State tab**: Xem current state của app
- **Click component name**: Quick select trong outline

### Best Practices:
- **Đặt tên query có ý nghĩa**
- **Group related components trong Container**
- **Test frequently với Preview mode**
- **Save thường xuyên**

## APP ĐẦU TIÊN HOÀN THÀNH

Chúc mừng! Bạn đã có:
- Text header
- Data table với search/pagination
- Interactive button
- Clean layout trong container

### Next Steps:
1. **Thêm forms để create/edit data**
2. **Connect real database**
3. **Add charts và visualizations**
4. **Create multiple pages**
5. **Add authentication**

## CÁC COMPONENT QUAN TRỌNG CẦN BIẾT

### Data Display:
- **Table**: Hiển thị tabular data
- **Chart**: Biểu đồ
- **Text**: Static text và dynamic content
- **Image**: Hiển thị ảnh

### Input Components:
- **Text Input**: Nhập text
- **Select**: Dropdown selection
- **Date Picker**: Chọn ngày
- **Checkbox**: Boolean input

### Action Components:
- **Button**: Trigger actions
- **Link**: Navigation
- **Modal**: Popup dialogs

### Layout Components:
- **Container**: Group components
- **Tabs**: Multiple views
- **Collapsible**: Expandable sections

Với foundation này, bạn đã sẵn sàng build những app phức tạp hơn!