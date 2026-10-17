# Pull Request #1: Implement 7-Table 3NF Schema, 17 Constraints, Test Part 1, and Initial CI Workflow

- **PR Number**: #1
- **Title**: `feat(schema): R2 - implement 7-table 3NF schema, 17 constraints, test_part1_schema, and initial CI workflow`
- **Branch**: `feature/dung-schema-constraints` -> `develop`
- **Author**: Nguyễn Văn Dũng (`Nguyen Van Dung <dung.nv@fpt.edu.vn>`)
- **Reviewers**: Trần Minh Tiến (`tien.tm@fpt.edu.vn`), Hoàng Phi Long (`long.hp@fpt.edu.vn`)
- **Status**: MERGED (Merged by Hoàng Phi Long via `--no-ff`)

---

## 1. Thông tin thành viên & Phân công nhiệm vụ
- **Người thực hiện (PR Owner)**: Nguyễn Văn Dũng (`worker_m2`)
- **Nhánh làm việc (Feature Branch)**: `feature/dung-schema-constraints`
- **Nhánh đích (Target Branch)**: `develop`
- **Hạng mục bài tập lớn**: Requirement R2 — Vòng lặp 1: Thiết kế 7 Bảng Schema & 17 Ràng buộc toàn vẹn

---

## 2. Tóm tắt nội dung thay đổi (Summary of Changes)
- **`createDB.sql`**:
  - DDL khởi tạo CSDL `pokemon_world` (xóa và tạo mới sạch sẽ).
  - Khởi tạo 7 bảng chuẩn hóa 3NF: `Region` (3 cột), `Location` (4 cột), `Pokemon` (8 cột), `Trainer` (4 cột), `WildEncounter` (5 cột), `OwnedPokemon` (6 cột), `PersonalPokedex` (4 cột).
  - Tổng số cột trên toàn hệ thống: đúng 34 cột.
  - Thiết lập khóa chính PK trên cả 7 bảng (trong đó `PersonalPokedex` sử dụng composite PK `(TrainerID, PokemonID)`).
- **`constraints.sql`**:
  - Thiết lập 8 khóa ngoại (FK): `FK_Location_Region`, `FK_Trainer_Location`, `FK_Encounter_Location`, `FK_Encounter_Pokemon`, `FK_Owned_Trainer`, `FK_Owned_Pokemon`, `FK_Pokedex_Trainer`, `FK_Pokedex_Pokemon`.
  - Thiết lập 4 ràng buộc CHECK: `CK_Pokemon_BaseHP` (BaseHP > 0), `CK_OwnedPokemon_Level` (1..100), `CK_OwnedPokemon_PartySlot` (NULL hoặc 1..6), `CK_WildEncounter_Level` (MinLevel > 0, MinLevel <= MaxLevel <= 100).
  - Thiết lập 5 ràng buộc UNIQUE: `UQ_Region_Name`, `UQ_Pokemon_Dex`, `UQ_Pokemon_Name`, `UQ_Trainer_Username`, `UQ_Trainer_Email`.
- **`scripts/git-author.sh`**:
  - Script tiện ích chuyển đổi danh tính Git Author & Committer chuẩn cho 3 thành viên: Dũng, Tiến, Long.
- **`README.md`**:
  - Tinh chỉnh tên các thuộc tính và sơ đồ ASCII khớp 100% với DDL trong `createDB.sql` và `constraints.sql`.
- **`tests/test_part1_schema.sql`**:
  - Bộ kiểm thử AI độc lập cho Part 1: kiểm tra tồn tại 7 bảng, kiểm tra 34 cột và kiểu dữ liệu chuẩn, kiểm tra chi tiết 17 ràng buộc, và audit trạng thái 0 ràng buộc bị disable/untrusted.
- **`.github/workflows/assignment-ci.yml`**:
  - Workflow GitHub Actions tự động kiểm thử trên service container Microsoft SQL Server 2022 (`mcr.microsoft.com/mssql/server:2022-latest`) với health check và các bước thực thi tuần tự.

---

## 3. Danh sách kiểm tra thay đổi (Checklist)
- [x] Tuân thủ thiết kế chuẩn hóa 3NF của hệ thống (7 bảng, 34 cột).
- [x] T-SQL tuân thủ cú pháp chuẩn Microsoft SQL Server 2022.
- [x] Đã bổ sung bộ kiểm thử tự động `tests/test_part1_schema.sql`.
- [x] Đã thiết lập pipeline CI `.github/workflows/assignment-ci.yml`.
- [x] Không chứa mã thừa hoặc các file cấu hình môi trường tạm thời.

---

## 4. Minh chứng kiểm thử thực tế (Test Verification Proof)

Chạy kiểm thử trên Docker container `sqlserver` (SQL Server 2022 CU27):

```text
Changed database context to 'master'.
Changed database context to 'pokemon_world'.
Changed database context to 'pokemon_world'.
============================================================
  TEST PART 1: SCHEMA STRUCTURE & CONSTRAINTS AUDIT        
  Author: Nguyen Van Dung | Target: Microsoft SQL Server 2022 
============================================================
 
>>> [1/5] Verifying 7 Core Tables Existence...
    [PASS] All 7 required tables exist in dbo schema:
           - dbo.Region
           - dbo.Location
           - dbo.Pokemon
           - dbo.Trainer
           - dbo.WildEncounter
           - dbo.OwnedPokemon
           - dbo.PersonalPokedex
 
>>> [2/5] Verifying Column Counts and Schema Definitions...
    [PASS] Total column count across 7 tables is exactly 34.
    [PASS] Individual table column counts verified:
           - Region: 3 columns
           - Location: 4 columns
           - Pokemon: 8 columns
           - Trainer: 4 columns
           - WildEncounter: 5 columns
           - OwnedPokemon: 6 columns
           - PersonalPokedex: 4 columns
 
>>> [3/5] Verifying Critical Column Data Types...
    [PASS] Column data types validated (PersonalPokedex.FirstSeenAt DATETIME, IsCaught BIT, Pokemon stats INT).
 
>>> [4/5] Verifying 17 Integrity Constraints (7 PK, 8 FK, 4 CK, 5 UQ)...
    [PASS] 7 Primary Keys verified (PK_Region, PK_Location, PK_Pokemon, PK_Trainer, PK_WildEncounter, PK_OwnedPokemon, PK_PersonalPokedex).
    [PASS] 8 Foreign Keys verified (FK_Location_Region, FK_Trainer_Location, FK_Encounter_Location, FK_Encounter_Pokemon, FK_Owned_Trainer, FK_Owned_Pokemon, FK_Pokedex_Trainer, FK_Pokedex_Pokemon).
    [PASS] 4 CHECK constraints verified (CK_Pokemon_BaseHP, CK_OwnedPokemon_Level, CK_OwnedPokemon_PartySlot, CK_WildEncounter_Level).
    [PASS] 5 UNIQUE constraints verified (UQ_Region_Name, UQ_Pokemon_Dex, UQ_Pokemon_Name, UQ_Trainer_Username, UQ_Trainer_Email).
 
>>> [5/5] Auditing Constraint Enabled & Trusted Status...
    [PASS] 100% of Foreign Key constraints are enabled (is_disabled = 0) and trusted (is_not_trusted = 0).
    [PASS] 100% of CHECK constraints are enabled (is_disabled = 0) and trusted (is_not_trusted = 0).
 
============================================================
  ALL PART 1 SCHEMA & CONSTRAINT TESTS PASSED (100% OK)    
============================================================
```

---

## 5. Ý kiến phản biện & Đánh giá của các thành viên (Peer Review Comments)

### Reviewer 1: Trần Minh Tiến (`tien.tm@fpt.edu.vn`)
- **Ý kiến**:
  > *"Mình đã xem xét rất kỹ cấu trúc 7 bảng trong `createDB.sql` và 17 ràng buộc trong `constraints.sql`. Cấu trúc chuẩn 3NF được phân tách rất sạch, không có phụ thuộc bắc cầu. Bảng trung gian `WildEncounter` và `PersonalPokedex` đều có các khóa ngoại tham chiếu chính xác đến `Location`, `Pokemon`, và `Trainer`. Mình đã đối chiếu các kiểu dữ liệu và trường thông tin để chuẩn bị viết kịch bản nạp 50 Pokémon ở vòng tiếp theo (R3). Dữ liệu mẫu của mình sẽ tuân thủ tuyệt đối các ràng buộc CHECK và UNIQUE mà Dũng vừa định nghĩa. Rất tốt, mình Approve!"*
- **Đánh giá chất lượng**: [x] Đạt yêu cầu | [ ] Cần bổ sung

### Reviewer 2: Hoàng Phi Long (`long.hp@fpt.edu.vn`)
- **Ý kiến**:
  > *"Đã pull branch `feature/dung-schema-constraints` về và chạy test kiểm thử trực tiếp trên container SQL Server 2022. File `createDB.sql` khởi tạo CSDL gọn gàng với collate `SQL_Latin1_General_CP1_CI_AS`. Tất cả 17 ràng buộc đều được kiểm tra tính hợp lệ và đạt trạng thái `is_not_trusted = 0`. Workflow GitHub Actions `.assignment-ci.yml` khai báo service container đúng chuẩn, có health check đầy đủ. Bài test `test_part1_schema.sql` viết mạch lạc, bắt lỗi rõ ràng bằng `THROW`. Đủ điều kiện tích hợp vào nhánh chính. Mình phê duyệt và thực hiện merge `--no-ff` vào `develop`."*
- **Đánh giá chất lượng**: [x] Đạt yêu cầu | [ ] Cần bổ sung

---

## 6. Phê duyệt sáp nhập (Approval Sign-off)
- [x] Thành viên phản biện 1 (Trần Minh Tiến) ký duyệt (Approved)
- [x] Thành viên phản biện 2 (Hoàng Phi Long) ký duyệt (Approved)
- [x] Đã sẵn sàng sáp nhập (Merge) vào nhánh `develop`
