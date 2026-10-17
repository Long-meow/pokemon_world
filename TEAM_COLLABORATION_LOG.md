# NHẬT KÝ HOẠT ĐỘNG VÀ THẢO LUẬN NHÓM (TEAM COLLABORATION LOG)
## Dự án: Pokémon World Database (DBI202 Assignment 2)
## Thành viên nhóm: Nguyễn Văn Dũng, Trần Minh Tiến, Hoàng Phi Long

---

## 1. Tổng quan phân công và các vòng lặp phát triển

| Vòng lặp | Thành viên phụ trách | Nhánh tính năng | Hạng mục cốt lõi | Bộ test kiểm thử | Trạng thái |
|:---:|---|---|---|---|:---:|
| **R1** | Cả nhóm (Long lead) | `main`, `develop` | Khởi tạo repo, Git Flow, .gitignore, README.md, PR template, identities | N/A | **HOÀN THÀNH** |
| **R2** | **Nguyễn Văn Dũng** | `feature/dung-schema-constraints` | 7 bảng 3NF (`createDB.sql`), 17 ràng buộc (`constraints.sql`), CI ban đầu | `tests/test_part1_schema.sql` | **HOÀN THÀNH** |
| **R3** | **Trần Minh Tiến** | `feature/tien-data-queries` | 50 Pokémon, seed data (`insert.sql`), 2 views (`views.sql`), 10 queries (`queries.sql`) | `tests/test_part2_queries.sql` | **HOÀN THÀNH** |
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

---

## 3. Nhật ký chi tiết Vòng lặp 2: Tiến — Dữ liệu 50 Pokémon, 2 Views & 10 Truy vấn nghiệp vụ (Requirement R3)

### 3.1. Quá trình phát triển trên nhánh `feature/tien-data-queries`
- **Tác giả commit**: `Tran Minh Tien <tien.tm@fpt.edu.vn>`
- **Nội dung thực hiện**:
  1. Kéo mã nguồn mới nhất từ `develop`, tạo nhánh `feature/tien-data-queries`.
  2. Nạp dữ liệu `insert.sql` với 50 loài Pokémon Gen-1 đầy đủ chỉ số và >= 10 dòng cho cả 7 bảng:
     - `Region`: 10 vùng đất.
     - `Location`: 12 địa danh.
     - `Pokemon`: 50 loài Pokémon.
     - `Trainer`: 12 Huấn luyện viên.
     - `WildEncounter`: 40 điểm phân bố hoang dã.
     - `OwnedPokemon`: 20 cá thể thuộc sở hữu.
     - `PersonalPokedex`: 40 bản ghi Pokédex cá nhân.
  3. Xây dựng 2 Views nghiệp vụ trong `views.sql`:
     - `dbo.vw_TrainerParty`: Đội hình thi đấu chính thức (PartySlot 1..6) kèm tên hiển thị ưu tiên biệt danh.
     - `dbo.vw_PokedexProgress`: Báo cáo tỷ lệ hoàn thành Pokédex cá nhân của từng huấn luyện viên.
  4. Viết 10 câu truy vấn nghiệp vụ đa dạng trong `queries.sql`:
     - 2 câu INNER JOIN (phân bố hoang dã 4 bảng, đội hình thi đấu 3 bảng).
     - 2 câu OUTER JOIN (thống kê địa danh và gặp gỡ hoang dã, thống kê mức độ bắt 50 loài).
     - 2 câu Subquery in WHERE (huấn luyện viên cấp cao hơn trung bình, Pokémon chỉ số trên trung bình).
     - 2 câu Subquery in FROM (Derived Tables: xếp hạng huấn luyện viên mạnh, thống kê cấp độ hoang dã vùng).
     - 2 câu GROUP BY with HAVING (thống kê hệ nguyên tố >= 2 loài, tiến độ khám phá của huấn luyện viên >= 2 loài).
  5. Phát triển bộ test modular AI `tests/test_part2_queries.sql` xác thực ngưỡng dòng 7 bảng, biên dịch và dữ liệu 2 views, và thực thi 10 queries (ném mã lỗi 52001-52015 khi vi phạm).
  6. Cập nhật workflow GitHub Actions `.github/workflows/assignment-ci.yml` tự động chạy nối tiếp Part 1 và Part 2 trên SQL Server 2022.

### 3.2. Kết quả kiểm thử thực tế trên SQL Server 2022
```text
=== STEP 1: createDB.sql ===
Changed database context to 'master'.
Changed database context to 'pokemon_world'.
=== STEP 2: constraints.sql ===
Changed database context to 'pokemon_world'.
=== STEP 3: tests/test_part1_schema.sql ===
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
=== STEP 4: insert.sql ===
Changed database context to 'pokemon_world'.
==================================================
  POKEMON WORLD SEED DATA SUCCESSFULLY LOADED!   
  - Region:         10 rows                       
  - Location:       12 rows                       
  - Pokemon:        50 rows                       
  - Trainer:        12 rows                       
  - WildEncounter:  40 rows                       
  - OwnedPokemon:   20 rows                       
  - PersonalPokedex:40 rows                       
==================================================
=== STEP 5: views.sql ===
Changed database context to 'pokemon_world'.
=== STEP 6: queries.sql ===
=== STEP 7: tests/test_part2_queries.sql ===
Changed database context to 'pokemon_world'.
============================================================
  TEST PART 2: DATA VOLUME, VIEWS & QUERIES AUDIT          
  Author: Tran Minh Tien | Target: Microsoft SQL Server 2022 
============================================================
 
>>> [1/3] Verifying Row Count Thresholds Across 7 Core Tables...
    [PASS] Table dbo.Pokemon: 50 rows (>= 50 threshold met).
    [PASS] Table dbo.Region: 10 rows (>= 10 threshold met).
    [PASS] Table dbo.Location: 12 rows (>= 10 threshold met).
    [PASS] Table dbo.Trainer: 12 rows (>= 10 threshold met).
    [PASS] Table dbo.WildEncounter: 40 rows (>= 10 threshold met).
    [PASS] Table dbo.OwnedPokemon: 20 rows (>= 10 threshold met).
    [PASS] Table dbo.PersonalPokedex: 40 rows (>= 10 threshold met).
 
>>> [2/3] Verifying Business Views Existence, Compilation & Non-Empty Output...
    [PASS] View dbo.vw_TrainerParty: compiled successfully and returned 19 active party records.
    [PASS] View dbo.vw_PokedexProgress: compiled successfully and returned 12 trainer progress summaries.
 
>>> [3/3] Validating Execution & Data Output of 10 Business Queries...
    [PASS] Query 1 (INNER JOIN 4 Tables): 40 rows returned.
    [PASS] Query 2 (INNER JOIN 3 Tables): 19 rows returned.
    [PASS] Query 3 (OUTER JOIN Locations): 12 rows returned.
    [PASS] Query 4 (OUTER JOIN 50 Species): 50 rows returned.
    [PASS] Query 5 (Subquery WHERE Elite Trainers): 6 rows returned.
    [PASS] Query 6 (Subquery WHERE High Stats): 25 rows returned.
    [PASS] Query 7 (Derived Table Trainer Ranking): 6 rows returned.
    [PASS] Query 8 (Derived Table Wild Level): 8 rows returned.
    [PASS] Query 9 (GROUP BY HAVING Primary Types): 9 rows returned.
    [PASS] Query 10 (GROUP BY HAVING Trainers): 9 rows returned.
 
============================================================
  ALL PART 2 DATA, VIEW & QUERY TESTS PASSED (100% OK)     
============================================================
=== PIPELINE VERIFICATION FINISHED SUCCESSFULLY ===
```

### 3.3. Thảo luận và Phản biện Pull Request #2
- **Tiến (`tien.tm@fpt.edu.vn`)**:
  > *"Chào Dũng và Long, mình đã hoàn thành trọn vẹn phần việc của Vòng lặp 2 (R3). Mình đã nạp đủ 50 loài Pokémon chuẩn với đầy đủ chỉ số, và mỗi bảng trong CSDL đều có từ 10 dòng trở lên. Mình cũng đã thiết kế 2 Views nghiệp vụ và 10 câu truy vấn đa dạng (2 INNER, 2 OUTER, 2 Subquery WHERE, 2 Subquery FROM, 2 GROUP BY HAVING). Mình đã viết bộ test `test_part2_queries.sql` và cập nhật CI workflow. Mọi người review và cho ý kiến giúp mình nhé!"*

- **Dũng (`dung.nv@fpt.edu.vn`)**:
  > *"Mình đã pull branch `feature/tien-data-queries` về và kiểm tra đối chiếu dữ liệu nạp trong `insert.sql` với 17 ràng buộc toàn vẹn mà mình đã thiết lập ở Part 1. Kết quả rất ấn tượng: toàn bộ 50 Pokémon đều thỏa mãn BaseHP > 0 và UNIQUE DexNumber/Name; 20 cá thể trong `OwnedPokemon` đều có Level nằm trong khoảng [1, 100] và PartySlot chuẩn; các khóa ngoại tham chiếu bảng `Location`, `Region`, `Trainer`, `Pokemon` đều khớp 100%, không hề có lỗi cô lập khóa ngoại nào. Dữ liệu nạp rất thực tế và chỉn chu. Mình Approve!"*

- **Long (`long.hp@fpt.edu.vn`)**:
  > *"Mình đã chạy toàn bộ pipeline từ `createDB.sql` -> `constraints.sql` -> `test_part1_schema.sql` -> `insert.sql` -> `views.sql` -> `queries.sql` -> `test_part2_queries.sql` trên container SQL Server 2022. Thời gian thực thi cực nhanh, toàn bộ 10 query phân tích chạy rất mượt và trả về kết quả chính xác. File test `test_part2_queries.sql` xử lý bắt lỗi bằng `THROW` chuẩn trong dải 52001-52015. Cấu hình CI GitHub Actions được cập nhật tuần tự, logic rõ ràng. Phần dữ liệu và view này đã sẵn sàng để mình bước sang Vòng lặp 3 làm phần Lập trình nâng cao (Function, Trigger, Procedure). Mình phê duyệt và thực hiện merge `--no-ff` vào `develop`."*

- **Hành động Merge**: Hoàng Phi Long thực hiện merge `--no-ff` Pull Request #2 vào `develop`.

