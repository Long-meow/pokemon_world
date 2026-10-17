## Tiêu đề Pull Request
<!-- Định dạng: [feat|fix|test|ci](scope): Mô tả ngắn gọn thay đổi -->
<!-- Ví dụ: feat(schema): thiết kế 7 bảng và 17 ràng buộc toàn vẹn cho CSDL -->

---

### 1. Thông tin thành viên & Phân công nhiệm vụ
- **Người thực hiện (PR Owner)**: <!-- [Nguyễn Văn Dũng | Trần Minh Tiến | Hoàng Phi Long] -->
- **Nhánh làm việc (Feature Branch)**: <!-- [feature/dung-schema-constraints | feature/tien-data-queries | feature/long-programmability-deploy] -->
- **Hạng mục bài tập lớn**: <!-- [R2: Schema & Ràng buộc | R3: Dữ liệu & Truy vấn | R4: Lập trình T-SQL & Deploy] -->

---

### 2. Tóm tắt nội dung thay đổi (Summary of Changes)
<!-- Mô tả chi tiết những gì đã được thêm mới, sửa đổi hoặc cấu hình trong PR này -->
- 

---

### 3. Danh sách kiểm tra thay đổi (Checklist)
- [ ] Tuân thủ thiết kế chuẩn hóa 3NF của hệ thống (7 bảng).
- [ ] T-SQL tuân thủ cú pháp chuẩn Microsoft SQL Server 2022.
- [ ] Đã bổ sung bộ kiểm thử tự động tương ứng trong thư mục `tests/`.
- [ ] Đã cập nhật pipeline CI `.github/workflows/assignment-ci.yml`.
- [ ] Không chứa mã thừa hoặc các file cấu hình môi trường tạm thời.

---

### 4. Minh chứng kiểm thử thực tế (Test Verification Proof)
<!-- Dán log kết quả chạy kiểm thử thực tế trên container Docker SQL Server hoặc GitHub Actions CI -->
```text
(Dán kết quả chạy sqlcmd / deploy.sh / test_*.sql tại đây)
```

---

### 5. Ý kiến phản biện & Đánh giá của các thành viên (Peer Review Comments)
- **Nhận xét của Thành viên 1**:
  - *Ý kiến*: 
  - *Đánh giá chất lượng*: [ ] Đạt yêu cầu | [ ] Cần bổ sung
- **Nhận xét của Thành viên 2**:
  - *Ý kiến*: 
  - *Đánh giá chất lượng*: [ ] Đạt yêu cầu | [ ] Cần bổ sung

---

### 6. Phê duyệt sáp nhập (Approval Sign-off)
- [ ] Thành viên phản biện 1 ký duyệt (Approved)
- [ ] Thành viên phản biện 2 ký duyệt (Approved)
- [ ] Đã sẵn sàng sáp nhập (Merge) vào nhánh `develop`
