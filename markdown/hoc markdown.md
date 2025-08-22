# Hướng dẫn Markdown từ A-Z - Cẩm nang học và thực hành

## Markdown là gì?

Markdown là ngôn ngữ đánh dấu văn bản đơn giản, giúp bạn định dạng văn bản chỉ bằng ký tự thường. Được sử dụng rộng rãi trên GitHub, Reddit, Discord, Notion và nhiều nền tảng khác.

## Tại sao nên học Markdown?

- Viết nhanh hơn so với Word
- Tương thích mọi thiết bị và hệ điều hành
- Dễ đọc ngay cả khi chưa render
- Chuẩn của lập trình viên và người làm nội dung
- Không bao giờ lỗi font hay định dạng

## Phần 1: Cú pháp cơ bản - Học trong 15 phút đầu

### 1.1 Tiêu đề (Headers)

```
# Tiêu đề cấp 1 - Lớn nhất
## Tiêu đề cấp 2 - Vừa
### Tiêu đề cấp 3 - Nhỏ hơn
#### Tiêu đề cấp 4
##### Tiêu đề cấp 5
###### Tiêu đề cấp 6 - Nhỏ nhất
```

**Quy tắc quan trọng:**
- Luôn có dấu cách sau dấu thăng
- Chỉ dùng 1-6 dấu thăng
- Nên có dòng trống trước và sau tiêu đề

### 1.2 Định dạng văn bản

```
**Chữ đậm** hoặc __Chữ đậm__
*Chữ nghiêng* hoặc _Chữ nghiêng_
***Vừa đậm vừa nghiêng***
~~Gạch ngang~~
`Code inline` - dùng cho từ khóa, tên file
```

### 1.3 Danh sách

**Danh sách có đánh số:**
```
1. Mục đầu tiên
2. Mục thứ hai
3. Mục thứ ba
   1. Mục con 3.1
   2. Mục con 3.2
4. Mục thứ tư
```

**Danh sách không đánh số:**
```
- Mục 1
- Mục 2
- Mục 3
  - Mục con
  - Mục con khác
- Mục 4

* Cũng có thể dùng dấu sao
+ Hoặc dấu cộng
```

### 1.4 Liên kết và hình ảnh

**Liên kết:**
```
[Tên hiển thị](https://example.com)
[Google](https://google.com)
https://example.com - Liên kết trực tiếp
```

**Hình ảnh:**
```
![Mô tả ảnh](đường-dẫn-ảnh.jpg)
![Logo GitHub](https://github.com/logo.png)
```

## Phần 2: Kỹ năng trung cấp - Thực hành sau 30 phút

### 2.1 Trích dẫn (Blockquotes)

```
> Đây là trích dẫn cấp 1
> Tiếp tục trích dẫn cùng cấp

> Trích dẫn mới
>> Trích dẫn lồng trong trích dẫn
```

### 2.2 Code blocks

**Code inline:** `git status`

**Code block:**
```
```
def hello_world():
    print("Hello, World!")
```
```

**Code với highlight ngôn ngữ:**
```
```python
def calculate(a, b):
    return a + b
```

```javascript
function greet(name) {
    console.log(`Hello, ${name}!`);
}
```
```

### 2.3 Bảng

```
| Cột 1 | Cột 2 | Cột 3 |
|-------|-------|-------|
| Dữ liệu 1 | Dữ liệu 2 | Dữ liệu 3 |
| Hàng 2 | Hàng 2 | Hàng 2 |

| Căn trái | Căn giữa | Căn phải |
|:---------|:--------:|---------:|
| Trái     | Giữa     | Phải     |
```

### 2.4 Đường kẻ ngang

```
---
***
___
```

### 2.5 Escape characters

Để hiển thị ký tự đặc biệt:
```
\* Không thành chữ nghiêng
\# Không thành tiêu đề
\` Không thành code
```

## Phần 3: Kỹ thuật nâng cao

### 3.1 Liên kết tham chiếu

```
Đây là [liên kết tham chiếu][1] trong văn bản.
Và đây là [liên kết khác][google].

[1]: https://example.com
[google]: https://google.com
```

### 3.2 Checkbox (GitHub Flavored Markdown)

```
- [ ] Task chưa hoàn thành
- [x] Task đã hoàn thành
- [ ] Task khác chưa làm
```

### 3.3 Footnotes

```
Đây là văn bản có chú thích[^1].

[^1]: Đây là nội dung chú thích.
```

### 3.4 HTML trong Markdown

```
<details>
<summary>Click để mở rộng</summary>

Nội dung ẩn ở đây.

</details>

<mark>Highlight text</mark>
<sub>Chữ nhỏ dưới</sub>
<sup>Chữ nhỏ trên</sup>
```

## Phần 4: Luyện tập thực hành

### Bài tập 1: Tạo CV đơn giản
Tạo file CV bằng Markdown với:
- Tiêu đề tên bạn
- Thông tin liên lạc
- Danh sách học vấn
- Danh sách kinh nghiệm
- Kỹ năng dạng checkbox

### Bài tập 2: Viết hướng dẫn công thức nấu ăn
- Tiêu đề món ăn
- Danh sách nguyên liệu
- Các bước thực hiện có đánh số
- Mẹo nhỏ dạng trích dẫn

### Bài tập 3: Tạo notes học tập
- Phân chia theo chương mục
- Highlight từ khóa quan trọng
- Code examples nếu học lập trình
- Liên kết tài liệu tham khảo

## Phần 5: Công cụ và môi trường thực hành

### 5.1 Trình soạn thảo khuyên dùng
- **Typora** - WYSIWYG, dễ dùng nhất cho người mới
- **Mark Text** - Miễn phí, đẹp
- **Obsidian** - Cho ghi chú và quản lý kiến thức
- **VS Code** - Với Markdown Preview Extension
- **GitHub** - Trực tiếp trên web

### 5.2 Trình xem online
- **Dillinger.io** - Soạn và xem ngay lập tức
- **StackEdit** - Đầy đủ tính năng
- **HackMD** - Cộng tác realtime

### 5.3 Lưu ý về các "hương vị" Markdown
- **GitHub Flavored Markdown (GFM)** - Phổ biến nhất
- **CommonMark** - Chuẩn chung
- **MultiMarkdown** - Mở rộng nhiều tính năng

## Phần 6: Lỗi thường gặp và cách khắc phục

### Lỗi 1: Tiêu đề không hiện
```
# Sai: #Thiếu dấu cách
# Đúng: # Có dấu cách
```

### Lỗi 2: Danh sách không indent đúng
```
- Sai:
-Mục 1
  -Mục con không đúng indent

- Đúng:
- Mục 1
  - Mục con đúng indent (2 spaces)
```

### Lỗi 3: Code block không hiện
```
# Sai: dùng quote thay vì backtick
'''python
code here
'''

# Đúng:
```python
code here
```
```

### Lỗi 4: Bảng không hiện
```
# Sai: thiếu dòng phân cách
| Cột 1 | Cột 2 |
| Dữ liệu | Dữ liệu |

# Đúng:
| Cột 1 | Cột 2 |
|-------|-------|
| Dữ liệu | Dữ liệu |
```

## Phần 7: Mẹo tăng tốc độ viết

### 7.1 Keyboard shortcuts phổ biến
- **Ctrl/Cmd + B**: Bold
- **Ctrl/Cmd + I**: Italic
- **Ctrl/Cmd + K**: Insert link
- **Ctrl/Cmd + Shift + C**: Code block

### 7.2 Snippets hữu ích
Tạo template sẵn cho:
- Cấu trúc bài viết blog
- Format meeting notes
- README cho dự án
- Checklist daily tasks

### 7.3 Quy tắc viết nhanh
1. Viết nội dung trước, format sau
2. Dùng shortcuts thay vì gõ tay
3. Tạo template cho các format thường dùng
4. Preview thường xuyên để kiểm tra

## Phần 8: Ứng dụng thực tế

### 8.1 Cho Developer
- README files
- Documentation
- Git commit messages
- Code comments
- Issue tracking

### 8.2 Cho Content Creator
- Blog posts
- Social media captions
- Email newsletters
- Course materials
- Ebooks

### 8.3 Cho Students
- Note taking
- Assignment writing
- Research documentation
- Study guides
- Project reports

## Phần 9: Checklist thành thạo Markdown

### Cấp độ Beginner (1-2 tuần)
- [ ] Viết được tiêu đề các cấp
- [ ] Format text: bold, italic, code
- [ ] Tạo danh sách có và không đánh số
- [ ] Chèn link và hình ảnh cơ bản
- [ ] Viết được đoạn văn có cấu trúc

### Cấp độ Intermediate (3-4 tuần)
- [ ] Tạo bảng phức tạp
- [ ] Sử dụng code blocks với syntax highlighting
- [ ] Viết blockquotes
- [ ] Sử dụng escape characters
- [ ] Kết hợp HTML khi cần thiết

### Cấp độ Advanced (1-2 tháng)
- [ ] Tạo văn bản dài có mục lục
- [ ] Sử dụng footnotes và references
- [ ] Tối ưu cho SEO (nếu viết blog)
- [ ] Customize CSS cho output
- [ ] Tự động hóa workflow với tools

## Phần 10: Tài nguyên học thêm

### 10.1 Cheat sheets
- **GitHub Markdown Guide**: Tài liệu chính thức
- **Markdown Cheatsheet**: Reference nhanh
- **CommonMark Spec**: Hiểu sâu cú pháp

### 10.2 Thực hành
- Viết daily journal bằng Markdown
- Contribute vào open source projects
- Tạo blog cá nhân
- Document các dự án của bạn

### 10.3 Cộng đồng
- **Reddit r/Markdown**
- **Stack Overflow Markdown tag**
- **GitHub Discussions**

## Kết luận: Roadmap 30 ngày thành thạo

**Tuần 1**: Học cú pháp cơ bản, viết mỗi ngày 15 phút
**Tuần 2**: Thực hành bảng, code blocks, formatting phức tạp
**Tuần 3**: Tạo project thực tế (CV, blog post, documentation)
**Tuần 4**: Tối ưu workflow, học shortcuts, customize tools

**Mục tiêu cuối khóa**: Viết Markdown nhanh như gõ văn bản thường, tự tin tạo mọi loại document từ đơn giản đến phức tạp.

**Nguyên tắc vàng**: Practice makes perfect. Hãy viết Markdown mỗi ngày, dù chỉ 10-15 phút!