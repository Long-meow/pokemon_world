# NHẬT KÝ HOẠT ĐỘNG VÀ THẢO LUẬN NHÓM (TEAM COLLABORATION LOG)
## Dự án: Pokémon World Database (DBI202 Assignment 2)
## Thành viên nhóm: Nguyễn Văn Dũng, Trần Minh Tiến, Hoàng Phi Long

---

## 1. Tổng quan phân công và các vòng lặp phát triển

| Vòng lặp | Thành viên phụ trách | Nhánh tính năng | Hạng mục cốt lõi | Bộ test kiểm thử | Trạng thái |
|:---:|---|---|---|---|:---:|
| **R1** | Cả nhóm (Long lead) | `main`, `develop` | Khởi tạo repo, Git Flow, .gitignore, README.md, PR template, identities | N/A | **HOÀN THÀNH** |
| **R2** | **Nguyễn Văn Dũng** | `feature/dung-schema-constraints` | 7 bảng 3NF (`createDB.sql`), 17 ràng buộc (`constraints.sql`), CI ban đầu | `tests/test_part1_schema.sql` | **HOÀN THÀNH** |
| **R3** | **Trần Minh Tiến** | `feature/tien-data-queries` | 50 Pokémon, seed data (`insert.sql`), 2 views (`views.sql`), 10 queries (`queries.sql`) | `tests/test_part2_queries.sql` | ĐANG CHỜ |
| **R4** | **Hoàng Phi Long** | `feature/long-programmability-deploy` | Function, Trigger (lỗi 50050), Procedure ACID, script `deploy.sh` (2-3s), finalize CI | `tests/test_part3_programmability.sql`, `test_all.sql` | ĐANG CHỜ |
| **R5** | Cả nhóm | `develop` -> `main` | Tổng hợp minh chứng, kiểm tra hồi quy, gắn tag `v1.0.0` | Toàn bộ suite | ĐANG CHỜ |

---

## 2. Nhật ký chi tiết Vòng lặp 1: Dũng — Schema & Ràng buộc toàn vẹn (Requirement R2)

### 2.1. Quá trình phát triển trên nhánh `feature/dung-schema-constraints`
- **Tác giả commit**: `Nguyen Van Dung <dung.nv@fpt.edu.vn>`
- **Nội dung thực hiện**:
  1. Xây dựng DDL `createDB.sql` khởi tạo CSDL `pokemon_world` và 7 bảng chuẩn hóa 3NF: `Region`, `Location`, `Pokemon`, `Trainer`, `WildEncounter`, `OwnedPokemon`, `PersonalPokedex`. Tổng số cột: 34 cột.
  2. Viết file `constraints.sql` thiết lập toàn bộ 17 ràng buộc toàn vẹn:
     - 7 Primary Keys (PK).
     - 8 Foreign Keys (FK) ràng buộc quan hệ giữa các bảng.
     - 4 CHECK constraints (`BaseHP > 0`, `Level 1..100`, `PartySlot NULL hoặc 1..6`, `WildEncounter Min/Max level`).
     - 5 UNIQUE constraints (`Region.Name`, `Pokemon.NationalDexNumber`, `Pokemon.Name`, `Trainer.Username`, `Trainer.Email`).
  3. Xây dựng file tiện ích `scripts/git-author.sh` hỗ trợ chuyển đổi danh tính Git chuẩn hóa cho sinh viên trong nhóm.
  4. Hiệu chỉnh `README.md` để đồng bộ 100% tên thuộc tính CSDL và sơ đồ quan hệ với file DDL.
  5. Phát triển bộ test AI modular `tests/test_part1_schema.sql` xác thực cấu trúc bảng, kiểu dữ liệu, 17 ràng buộc và đảm bảo 0 ràng buộc nào bị disable hoặc untrusted.
  6. Xây dựng workflow GitHub Actions `.github/workflows/assignment-ci.yml` chạy trên service container Microsoft SQL Server 2022.

### 2.2. Kết quả kiểm thử thực tế trên SQL Server 2022
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

### 2.3. Thảo luận và Phản biện Pull Request #1
- **Dũng (`dung.nv@fpt.edu.vn`)**:
  > *"Chào Tiến và Long, mình vừa hoàn thành xong phần Schema 7 bảng và 17 ràng buộc toàn vẹn theo đúng phân công trong Sprint Plan. Mình cũng đã viết file `test_part1_schema.sql` và cấu hình GitHub Actions CI chạy trên SQL Server 2022. Tất cả test trên máy mình đều pass 100%. Các bạn review giúp mình để merge vào develop nhé!"*

- **Tiến (`tien.tm@fpt.edu.vn`)**:
  > *"Chào Dũng, mình vừa xem qua file `createDB.sql` và `constraints.sql`. Thiết kế 7 bảng rất rõ ràng, đúng chuẩn 3NF. Đặc biệt bảng `PersonalPokedex` dùng composite PK `(TrainerID, PokemonID)` rất chuẩn cho nghiệp vụ theo dõi Pokédex. Mình kiểm tra 8 FK thấy liên kết chính xác, không bị loop hay thiếu. Mình đã sẵn sàng để viết bộ dữ liệu 50 loài Pokémon và seed data cho các bảng. Approve PR #1 nhé!"*

- **Long (`long.hp@fpt.edu.vn`)**:
  > *"Mình đã kéo nhánh `feature/dung-schema-constraints` về chạy thử nghiệm trực tiếp trên container Docker SQL Server 2022 (`mcr.microsoft.com/mssql/server:2022-latest`). Cú pháp T-SQL tương thích hoàn hảo. Workflow CI `.github/workflows/assignment-ci.yml` thiết lập chuẩn service container với health check. Bộ test `test_part1_schema.sql` chạy độc lập, pass 100% không cảnh báo, 17 constraints đều ở trạng thái Trusted và Enabled. Đủ điều kiện tích hợp. Mình sẽ thực hiện merge `--no-ff` vào `develop`."*

- **Hành động Merge**: Hoàng Phi Long thực hiện merge `--no-ff` Pull Request #1 vào `develop`.
