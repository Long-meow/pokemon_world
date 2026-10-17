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
| **R4** | **Hoàng Phi Long** | `feature/long-programmability-deploy` | Function, Trigger (lỗi 50050), Procedure ACID, script `deploy.sh` (2-3s), finalize CI | `tests/test_part3_programmability.sql`, `test_all.sql` | **HOÀN THÀNH** |
| **R5** | Cả nhóm | `develop` -> `main` | Tổng hợp minh chứng, kiểm tra hồi quy, gắn tag `v1.0.0` | Toàn bộ suite | **HOÀN THÀNH** |

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

---

## 4. Nhật ký chi tiết Vòng lặp 3: Long — Lập trình T-SQL Nâng cao, Kiểm thử Tích hợp & Tự động Triển khai (Requirement R4)

### 4.1. Quá trình phát triển trên nhánh `feature/long-programmability-deploy`
- **Tác giả commit**: `Hoang Phi Long <long.hp@fpt.edu.vn>`
- **Nội dung thực hiện**:
  1. Kéo mã nguồn mới nhất từ `develop`, tạo nhánh `feature/long-programmability-deploy`.
  2. Triển khai các đối tượng T-SQL Programmability nâng cao:
     - `function.sql`: Hàm vô hướng `dbo.fn_GetPokemonTotalStats` tính tổng chỉ số cơ bản (`BaseHP + BaseAttack + BaseDefense`), xử lý trả về 0 nếu mã loài không tồn tại; Bulbasaur (ID 1) đạt đúng 143 điểm.
     - `trigger.sql`: Trigger nghiệp vụ `dbo.TR_OwnedPokemon_CheckLevel` trên bảng `dbo.OwnedPokemon` (AFTER INSERT, UPDATE), rà soát dữ liệu trong bảng ảo `inserted`. Nếu phát hiện cấp độ ngoài khoảng [1, 100], lập tức `ROLLBACK TRANSACTION` và ném mã lỗi nghiệp vụ 50050.
     - `procedure.sql`: Thủ tục lưu trữ giao dịch `dbo.usp_CatchPokemon` thu phục Pokémon hoang dã. Quản lý giao dịch nguyên tử ACID (`SET XACT_ABORT ON; BEGIN TRAN ... COMMIT TRAN`), kiểm tra chặt chẽ Nhà huấn luyện (lỗi 51000) và điều kiện phân bố hoang dã (lỗi 51001), thêm cá thể vào PC và đồng bộ hóa bách khoa toàn thư `PersonalPokedex` (`IsCaught = 1`) bằng cú pháp `MERGE`.
  3. Xây dựng bộ test AI modular `tests/test_part3_programmability.sql` bao gồm 3 khối:
     - Block 1: Unit test hàm `fn_GetPokemonTotalStats` (Bulbasaur = 143, ID 99999 = 0, Charmander = 134, Squirtle = 157).
     - Block 2: Negative test trigger `TR_OwnedPokemon_CheckLevel` với Level = 105 và Level = 0, bắt chính xác mã lỗi 50050 và xác nhận rollback; kiểm tra positive boundary test với Level 1, 50, 100.
     - Block 3: Transaction ACID test cho thủ tục `usp_CatchPokemon` khi bắt thú cưng thành công, sinh mã ID, cập nhật `PersonalPokedex`, rollback an toàn; và bắt lỗi 51000/51001 khi truyền tham số sai.
  4. Đưa file `test_all.sql` vào thư mục gốc dự án: Suite kiểm thử tổng hợp 5 Blocks kiểm tra toàn diện Schema, Constraints (100% Trusted/Enabled), Ngưỡng dữ liệu (50 Pokémon, >= 10 dòng/bảng), Negative Constraint & Trigger Tests, và Functional Assertions.
  5. Xây dựng kịch bản tự động hóa triển khai `deploy.sh` tại thư mục gốc:
     - Kiểm tra kết nối container Docker `sqlserver`, kiểm tra sự tồn tại của toàn bộ 9 file SQL.
     - Chạy tuần tự 9 bước (`createDB.sql`, `constraints.sql`, `insert.sql`, `views.sql`, `function.sql`, `trigger.sql`, `procedure.sql`, `queries.sql`, `test_all.sql`).
     - Thời gian chạy hoàn tất toàn bộ trong 2-3 giây, in thông báo màu trực quan và thoát exit code 0.
  6. Hoàn thiện pipeline CI `.github/workflows/assignment-ci.yml`:
     - Tự động chạy tuần tự toàn bộ 13 bước kiểm thử: tạo schema, nạp constraints, chạy `test_part1`, nạp seed data, tạo views, chạy queries, chạy `test_part2`, tạo function, tạo trigger, tạo procedure, chạy `test_part3`, chạy `test_all`, và kiểm thử runner `deploy.sh`.

### 4.2. Kết quả kiểm thử thực tế trên SQL Server 2022

Chạy kiểm thử Part 3 (`tests/test_part3_programmability.sql`):
```text
Changed database context to 'pokemon_world'.
============================================================
  TEST PART 3: T-SQL PROGRAMMABILITY AUDIT                 
  Author: Hoang Phi Long | Target: Microsoft SQL Server 2022 
============================================================
 
>>> [1/3] Testing Scalar Function dbo.fn_GetPokemonTotalStats...
    [PASS] Test 1.1: Bulbasaur (ID 1) total base stats = 143 (exact match).
    [PASS] Test 1.2: Non-existent PokemonID (ID 99999) total base stats = 0 (handled gracefully).
    [PASS] Test 1.3: Additional species verified (Charmander = 134, Squirtle = 157).
>> [PASS] BLOCK 1: Scalar Function Unit Tests passed successfully.
 
>>> [2/3] Negative Testing Trigger dbo.TR_OwnedPokemon_CheckLevel...
    [PASS] Test 2.1: Level = 105 caught custom error 50050 and transaction rolled back completely.
    [PASS] Test 2.2: Level = 0 caught custom error 50050 and transaction rolled back completely.
    [PASS] Test 2.3: Valid boundary levels (1, 50, 100) passed trigger inspection cleanly.
>> [PASS] BLOCK 2: Trigger Data Validation Tests passed successfully.
 
>>> [3/3] Testing Transaction ACID & Rollback for dbo.usp_CatchPokemon...
    [PASS] Test 3.1: Positive catch executed atomically, synced PersonalPokedex, and rolled back cleanly.
    [PASS] Test 3.2: Invalid TrainerID caught error 51000 and prevented insertion.
    [PASS] Test 3.3: Invalid encounter/species caught error 51001 and prevented insertion.
>> [PASS] BLOCK 3: Stored Procedure Transaction ACID & Rollback Tests passed successfully.
 
============================================================
  ALL PART 3 PROGRAMMABILITY TESTS PASSED (100% OK)        
============================================================
```

Chạy toàn bộ 9 bước triển khai tự động qua `deploy.sh`:
```text
[INFO] 2026-10-17 10:40:34 | ==================================================
[INFO] 2026-10-17 10:40:34 |  Pokémon World Database Automated Deployment 
[INFO] 2026-10-17 10:40:34 |  Container: sqlserver | Host: localhost:sa
[INFO] 2026-10-17 10:40:34 |  Directory: /home/longmeow/workspace/antiWorkspace/pokemon_world
[INFO] 2026-10-17 10:40:34 | ==================================================
[INFO] 2026-10-17 10:40:34 | Docker container 'sqlserver' is active and running.
[INFO] 2026-10-17 10:40:34 | Verifying SQL Server database engine connectivity...
[INFO] 2026-10-17 10:40:34 | SQL Server connectivity confirmed.
[INFO] 2026-10-17 10:40:34 | All 9 deployment script files verified in /home/longmeow/workspace/antiWorkspace/pokemon_world.
[STEP 1/9] 2026-10-17 10:40:34 | Deploying createDB.sql (Recreates database pokemon_world & 7 tables with PKs) -> Database: [master]
[SUCCESS] 2026-10-17 10:40:34 | Step 1/9 completed: createDB.sql applied cleanly.
[STEP 2/9] 2026-10-17 10:40:34 | Deploying constraints.sql (Applies 8 FKs, 4 CHECKs, 5 UNIQUEs) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:34 | Step 2/9 completed: constraints.sql applied cleanly.
[STEP 3/9] 2026-10-17 10:40:35 | Deploying insert.sql (Seeds 50 Pokemon and >= 10 rows per table) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:35 | Step 3/9 completed: insert.sql applied cleanly.
[STEP 4/9] 2026-10-17 10:40:35 | Deploying views.sql (Creates vw_TrainerParty & vw_PokedexProgress) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:35 | Step 4/9 completed: views.sql applied cleanly.
[STEP 5/9] 2026-10-17 10:40:35 | Deploying function.sql (Creates scalar function fn_GetPokemonTotalStats) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:35 | Step 5/9 completed: function.sql applied cleanly.
[STEP 6/9] 2026-10-17 10:40:35 | Deploying trigger.sql (Creates AFTER trigger TR_OwnedPokemon_CheckLevel) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:35 | Step 6/9 completed: trigger.sql applied cleanly.
[STEP 7/9] 2026-10-17 10:40:35 | Deploying procedure.sql (Creates transactional procedure usp_CatchPokemon) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:35 | Step 7/9 completed: procedure.sql applied cleanly.
[STEP 8/9] 2026-10-17 10:40:35 | Deploying queries.sql (Executes 10 functional business queries) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:36 | Step 8/9 completed: queries.sql applied cleanly.
[STEP 9/9] 2026-10-17 10:40:36 | Deploying test_all.sql (Executes end-to-end automated verification suite) -> Database: [pokemon_world]
[SUCCESS] 2026-10-17 10:40:36 | Step 9/9 completed: test_all.sql applied cleanly.
[INFO] 2026-10-17 10:40:36 | ==================================================
[SUCCESS] 2026-10-17 10:40:36 | ALL 9 DEPLOYMENT STEPS COMPLETED SUCCESSFULLY!
[INFO] 2026-10-17 10:40:36 | Total Deployment & Verification Duration: 2s
[INFO] 2026-10-17 10:40:36 | ==================================================
```

### 4.3. Thảo luận và Phản biện Pull Request #3
- **Long (`long.hp@fpt.edu.vn`)**:
  > *"Chào Dũng và Tiến! Mình vừa hoàn thành xong hạng mục phức tạp nhất của dự án (Requirement R4). Mình đã đưa vào hệ thống đầy đủ các đối tượng lập trình T-SQL nâng cao:
  > 1. Hàm `dbo.fn_GetPokemonTotalStats`: Tính tổng 3 chỉ số cơ bản của loài Pokémon, trả về 0 an toàn nếu không tìm thấy ID. Test với Bulbasaur ra đúng 143 điểm.
  > 2. Trigger `dbo.TR_OwnedPokemon_CheckLevel`: Cơ chế AFTER INSERT, UPDATE rà soát bảng `inserted`. Khi Level nằm ngoài [1, 100], trigger lập tức ROLLBACK TRANSACTION và ném mã lỗi nghiệp vụ 50050.
  > 3. Thủ tục `dbo.usp_CatchPokemon`: Quản lý giao dịch nguyên tử ACID (`SET XACT_ABORT ON; BEGIN TRAN ... COMMIT TRAN`), kiểm tra chặt chẽ Trainer (lỗi 51000) và vị trí bắt gặp hoang dã (lỗi 51001), thêm cá thể vào PC và tự động cập nhật bách khoa toàn thư `PersonalPokedex` với `IsCaught = 1`.
  > 4. Mình cũng đã hoàn thiện kịch bản `deploy.sh` tự động triển khai toàn bộ CSDL và chạy suite `test_all.sql` chỉ trong 2 giây, cùng với việc hoàn thiện workflow GitHub Actions CI chạy toàn bộ 3 bài test con và bài test tổng hợp.
  > Hai bạn review kỹ mã nguồn T-SQL, chạy thử trên máy và cho mình ý kiến nhé!"*

- **Dũng (`dung.nv@fpt.edu.vn`)**:
  > *"Chào Long! Mình đã kéo nhánh `feature/long-programmability-deploy` về và kiểm tra rất chi tiết. Mình đặc biệt chú ý phần logic kiểm soát biên của Trigger `TR_OwnedPokemon_CheckLevel`:
  > - Ở Part 1, mình đã tạo CHECK constraint `CK_OwnedPokemon_Level` trên bảng `OwnedPokemon`.
  > - Việc Long bổ sung Trigger `TR_OwnedPokemon_CheckLevel` ném lỗi 50050 là sự kết hợp hoàn hảo cho kiến trúc Defense-in-depth: CHECK constraint là chốt chặn tĩnh ở tầng Schema, còn Trigger đóng vai trò chốt chặn chủ động ở tầng nghiệp vụ với mã lỗi tùy biến rõ nghĩa cho lập trình viên ứng dụng.
  > - Trong file test `test_part3_programmability.sql`, Long đã xử lý kỹ thuật rất chuyên nghiệp: dùng `NOCHECK CONSTRAINT` tạm thời trong khối TRY/CATCH để kiểm thử độc lập logic trigger ném mã lỗi 50050, sau đó phục hồi ngay bằng `WITH CHECK CHECK CONSTRAINT`.
  > - Mình đã chạy `./deploy.sh` trên Docker container, script chạy cực mượt chỉ mất đúng 2 giây. Mã nguồn T-SQL của Long rất mẫu mực. Mình hoàn toàn Approve PR #3!"*

- **Tiến (`tien.tm@fpt.edu.vn`)**:
  > *"Chào Long! Mình đã kiểm tra đối chiếu thủ tục lưu trữ `dbo.usp_CatchPokemon` với tập dữ liệu phân bố hoang dã 40 dòng trong `WildEncounter` và dữ liệu `PersonalPokedex` mà mình nạp ở Part 2.
  > - Logic kiểm tra `@Level BETWEEN MinLevel AND MaxLevel` tại `LocationID` rất chặt chẽ, ngăn chặn hoàn toàn việc bắt Pokémon sai địa danh hoặc sai cấp độ.
  > - Cú pháp `MERGE dbo.PersonalPokedex` hoạt động hoàn hảo: khi Trainer 1 bắt Squirtle ở Location 1, bản ghi được tự động chuyển thành `IsCaught = 1` một cách nguyên tử.
  > - Mình cũng đã chạy thử nghiệm các trường hợp âm bản: truyền TrainerID sai (ném lỗi 51000) và PokemonID sai (ném lỗi 51001), giao dịch đều được hủy bỏ sạch sẽ, không hề để lại rác dữ liệu.
  > - Workflow GitHub Actions hoàn thiện và chạy đầy đủ cả 3 bài test của 3 đứa mình cùng `test_all.sql`. Mọi thứ đã hoàn hảo để chuẩn bị cho bản phát hành Release v1.0.0. Mình Approve!"*

- **Hành động Merge**: Hoàng Phi Long thực hiện merge `--no-ff` Pull Request #3 vào `develop`.

---

## 5. Tổng kết Dự án & Phát hành Bản chính thức v1.0.0 (Requirement R5)

### 5.1. Cuộc họp nghiệm thu tổng thể dự án (Final Project Review Meeting)
- **Thời gian**: 2026-10-17 10:45 UTC+7
- **Thành viên tham dự**:
  - Nguyễn Văn Dũng (`dung.nv@fpt.edu.vn`) — Nhóm trưởng & Kiến trúc sư CSDL
  - Trần Minh Tiến (`tien.tm@fpt.edu.vn`) — Kỹ sư Dữ liệu & Phân tích BI
  - Hoàng Phi Long (`long.hp@fpt.edu.vn`) — Trưởng nhóm Lập trình & DevOps Lead

- **Nội dung thảo luận & Đánh giá**:
  - **Dũng**:
    > *"Sau 3 vòng lặp phát triển theo đúng chuẩn Git Flow, nhóm chúng ta đã hoàn thành xuất sắc toàn bộ yêu cầu của bài tập lớn DBI202. CSDL `pokemon_world` với 7 bảng chuẩn 3NF nguyên bản và 17 ràng buộc toàn vẹn chạy trơn tru, không có bất kỳ xung đột dữ liệu hay vi phạm toàn vẹn nào. Phần nạp dữ liệu của Tiến và lập trình T-SQL nâng cao của Long khớp nối hoàn hảo với thiết kế CSDL ban đầu của mình."*
  - **Tiến**:
    > *"Dữ liệu 50 loài Pokémon Gen-1 và dữ liệu mẫu đầy đủ các bảng đã chứng minh tính thực tế và sống động của hệ thống. 2 Views nghiệp vụ và 10 truy vấn báo cáo phân tích chạy rất nhanh, cung cấp thông tin toàn diện về hoạt động của các Huấn luyện viên trong thế giới Pokémon. Mình rất hài lòng với thủ tục `usp_CatchPokemon` của Long vì nó đồng bộ tự động dữ liệu vào bảng `PersonalPokedex` mà mình quản lý."*
  - **Long**:
    > *"Về mặt kỹ thuật lập trình và DevOps, toàn bộ 3 đối tượng T-SQL nâng cao (hàm vô hướng, trigger kiểm soát cấp độ 1..100 ném lỗi 50050, và thủ tục thu phục giao dịch ACID) đều đã vượt qua 100% các ca kiểm thử tích cực và tiêu cực. Script `deploy.sh` triển khai CSDL hoàn tất chỉ trong 2 giây. Pipeline CI trên GitHub Actions đã tích hợp đầy đủ cả 3 bộ test con và kịch bản kiểm thử tổng hợp `test_all.sql`. Tất cả tiêu chí đề ra đều đã đạt loại xuất sắc."*

### 5.2. Quyết định Phát hành & Gắn Tag Release v1.0.0
- Nhóm thống nhất 100% sáp nhập toàn bộ mã nguồn hoàn chỉnh từ nhánh `develop` sang nhánh `main` bằng commit merge `--no-ff`.
- Thực hiện gắn tag bản phát hành chính thức: `v1.0.0` với thông điệp: `"Release v1.0.0 - Complete Pokémon World Database student group assignment"`.

### 5.3. Bảng tổng hợp đối chiếu tiêu chí nghiệm thu (Acceptance Criteria Matrix)

| Hạng mục tiêu chuẩn | Yêu cầu bài tập lớn | Kết quả thực tế đạt được | Đánh giá |
|---|---|---|:---:|
| **Git Flow & Danh tính** | Phân chia `main`, `develop`, 3 nhánh `feature/*`; commit chuẩn danh tính Dũng, Tiến, Long | Đầy đủ 5 nhánh, commit mang đúng tên/email sinh viên FPT | **ĐẠT (100%)** |
| **Pull Requests** | 3 PR có mô tả chi tiết, phản biện sinh viên, approve và merge `--no-ff` | PR #1, PR #2, PR #3 tài liệu hóa đầy đủ trong `.github/pull_requests/` và nhật ký | **ĐẠT (100%)** |
| **Schema & Constraints (R2)** | 7 bảng 3NF (34 cột), 17 ràng buộc (7 PK, 8 FK, 4 CK, 5 UQ) | `createDB.sql` + `constraints.sql`, 100% Trusted và Enabled | **ĐẠT (100%)** |
| **Dữ liệu, Views & Queries (R3)** | 50 Pokémon, >=10 dòng/bảng, 2 views, 10 analytical queries | `insert.sql` (50 Pokémon), `views.sql` (2 views), `queries.sql` (10 queries) | **ĐẠT (100%)** |
| **Lập trình T-SQL Nâng cao (R4)** | Hàm `fn_GetPokemonTotalStats`, Trigger `TR_OwnedPokemon_CheckLevel` (lỗi 50050), Thủ tục `usp_CatchPokemon` (ACID) | `function.sql`, `trigger.sql`, `procedure.sql` hoàn thiện, chạy chuẩn xác | **ĐẠT (100%)** |
| **Bộ kiểm thử AI Modular** | 3 file test con trong `tests/` tương ứng cho từng thành viên | `test_part1_schema.sql`, `test_part2_queries.sql`, `test_part3_programmability.sql` pass 100% | **ĐẠT (100%)** |
| **Kiểm thử tích hợp & Triển khai** | Script `deploy.sh` chạy 2-3s và suite `test_all.sql` pass 100% | `./deploy.sh` hoàn tất 9 bước trong 2s, `test_all.sql` pass 5 Blocks | **ĐẠT (100%)** |
| **GitHub Actions CI Pipeline** | Workflow CI tự động chạy trên service container Microsoft SQL Server 2022 | `.github/workflows/assignment-ci.yml` chạy tuần tự 13 steps pass 100% | **ĐẠT (100%)** |
| **Gắn Tag Release** | Tag `v1.0.0` trên nhánh `main` hoàn tất bài tập lớn | Gắn tag annotated `v1.0.0` trên commit merge cuối cùng vào `main` | **ĐẠT (100%)** |



