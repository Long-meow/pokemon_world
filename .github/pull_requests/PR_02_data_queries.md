# Pull Request #2: Seed 50 Pokémon Data, 2 Views, 10 Analytical Queries, Test Part 2, and CI Update

- **PR Number**: #2
- **Title**: `feat(data-queries): R3 - seed 50 Pokemon, 2 views, 10 analytical queries, test_part2_queries, and update CI`
- **Branch**: `feature/tien-data-queries` -> `develop`
- **Author**: Trần Minh Tiến (`Tran Minh Tien <tien.tm@fpt.edu.vn>`)
- **Reviewers**: Nguyễn Văn Dũng (`dung.nv@fpt.edu.vn`), Hoàng Phi Long (`long.hp@fpt.edu.vn`)
- **Status**: MERGED (Merged by Hoàng Phi Long via `--no-ff`)

---

## 1. Thông tin thành viên & Phân công nhiệm vụ
- **Người thực hiện (PR Owner)**: Trần Minh Tiến (`worker_m3`)
- **Nhánh làm việc (Feature Branch)**: `feature/tien-data-queries`
- **Nhánh đích (Target Branch)**: `develop`
- **Hạng mục bài tập lớn**: Requirement R3 — Vòng lặp 2: Dữ liệu 50 Pokémon, 2 Views & 10 Truy vấn nghiệp vụ

---

## 2. Tóm tắt nội dung thay đổi (Summary of Changes)
- **`insert.sql`**:
  - Nạp đầy đủ 50 loài Pokémon thuộc thế hệ 1 (Gen-1) với thông số chỉ số cơ bản (BaseHP, BaseAttack, BaseDefense), hệ nguyên tố chính và phụ chuẩn xác.
  - Nạp dữ liệu mẫu đảm bảo tất cả 7 bảng đều đạt ngưỡng tối thiểu từ 10 dòng trở lên:
    * `Region`: 10 vùng đất chuẩn (Kanto, Johto, Hoenn, Sinnoh, Unova, Kalos, Alola, Galar, Paldea, Hisui).
    * `Location`: 12 địa danh sinh thái đa dạng (Route, Forest, Cave, Mountain, City, Bay).
    * `Pokemon`: 50 loài Pokémon nguyên bản chuẩn hóa.
    * `Trainer`: 12 Nhà huấn luyện với thông tin tài khoản, email và địa bàn hoạt động.
    * `WildEncounter`: 40 điểm phân bố xuất hiện hoang dã với tỷ lệ và cấp độ hợp lý.
    * `OwnedPokemon`: 20 cá thể Pokémon thuộc sở hữu, có cấp độ và vị trí đội hình chiến đấu (PartySlot 1..6).
    * `PersonalPokedex`: 40 bản ghi nhật ký thám hiểm Pokédex cá nhân (đã bắt hoặc đã phát hiện).
  - Toàn bộ dữ liệu tuân thủ tuyệt đối 17 ràng buộc toàn vẹn của CSDL.
- **`views.sql`**:
  - `dbo.vw_TrainerParty`: View hiển thị danh sách đội hình thi đấu chính thức (các cá thể có `PartySlot IS NOT NULL`) của từng huấn luyện viên, tự động gán tên hiển thị ưu tiên biệt danh `Nickname` (nếu không có thì hiển thị tên loài `Species`).
  - `dbo.vw_PokedexProgress`: View thống kê tổng hợp tiến độ hoàn thành Pokédex cá nhân của từng huấn luyện viên: số loài đã thấy (`SeenCount`), số loài đã thu phục (`CaughtCount`), tổng số loài trong thế giới (`TotalPokemon`), và tỷ lệ hoàn thành (`CompletionPercentage`).
- **`queries.sql`**:
  - 10 câu truy vấn nghiệp vụ đa dạng, bao phủ đầy đủ các kỹ thuật SQL yêu cầu:
    1. *INNER JOIN 1*: Phân bố Pokémon hoang dã trên 4 bảng (`WildEncounter` -> `Location` -> `Region` -> `Pokemon`).
    2. *INNER JOIN 2*: Đội hình thi đấu chính thức của các huấn luyện viên trên 3 bảng (`OwnedPokemon` -> `Trainer` -> `Pokemon`).
    3. *OUTER JOIN 1*: Thống kê địa danh và số điểm gặp thú hoang bằng `LEFT OUTER JOIN` (`Location` -> `WildEncounter`), không bỏ sót địa danh chưa có thú hoang.
    4. *OUTER JOIN 2*: Thống kê mức độ phổ biến và số lần bắt của cả 50 loài Pokémon bằng `LEFT OUTER JOIN` (`Pokemon` -> `OwnedPokemon`).
    5. *Subquery in WHERE 1*: Tìm các huấn luyện viên sở hữu cá thể đạt cấp độ vượt trội hơn cấp độ trung bình toàn hệ thống.
    6. *Subquery in WHERE 2*: Liệt kê các loài Pokémon có tổng 3 chỉ số cơ bản cao hơn mức trung bình của toàn bộ 50 loài.
    7. *Subquery in FROM (Derived Table) 1*: Bảng dẫn xuất xếp hạng huấn luyện viên có cá thể mạnh nhất đạt cấp độ từ 25 trở lên.
    8. *Subquery in FROM (Derived Table) 2*: Bảng dẫn xuất tính cấp độ hoang dã trung bình theo địa danh và lọc các địa danh có cấp độ trung bình từ 5.0 trở lên.
    9. *GROUP BY with HAVING 1*: Thống kê số loài, máu trung bình, công lớn nhất, thủ trung bình theo hệ nguyên tố chính (`PrimaryType`) có từ 2 loài trở lên.
    10. *GROUP BY with HAVING 2*: Đánh giá tiến độ thu phục của các huấn luyện viên đã ghi nhận từ 2 loài trở lên trong sổ Pokédex.
- **`tests/test_part2_queries.sql`**:
  - Bộ kiểm thử AI tự động cho Part 2:
    * Kiểm tra ngưỡng dữ liệu trên cả 7 bảng (`Pokemon >= 50`, `Region >= 10`, `Location >= 10`, `Trainer >= 10`, `WildEncounter >= 10`, `OwnedPokemon >= 10`, `PersonalPokedex >= 10`).
    * Kiểm tra tồn tại, biên dịch và trả về dữ liệu của 2 views `vw_TrainerParty` và `vw_PokedexProgress`.
    * Kiểm tra thực thi và tính đúng đắn của toàn bộ 10 câu truy vấn nghiệp vụ.
    * Ném mã lỗi chuẩn 52001-52015 khi có lỗi assertion; trả về exit code 0 khi thành công 100%.
- **`.github/workflows/assignment-ci.yml`**:
  - Bổ sung tuần tự các bước: nạp `insert.sql`, tạo `views.sql`, chạy `queries.sql`, và chạy kiểm thử `tests/test_part2_queries.sql` trên container SQL Server 2022.

---

## 3. Danh sách kiểm tra thay đổi (Checklist)
- [x] Đã nạp đủ 50 Pokémon với đầy đủ thông số chỉ số cơ bản.
- [x] Mỗi bảng trong 7 bảng đều chứa từ 10 dòng dữ liệu hợp lệ trở lên.
- [x] Dữ liệu mẫu vượt qua 100% 17 ràng buộc toàn vẹn (8 FK, 4 CK, 5 UQ).
- [x] Cả 2 views đều biên dịch hợp lệ và trả về dữ liệu chính xác.
- [x] Đủ 10 câu truy vấn nghiệp vụ theo đúng yêu cầu (INNER, OUTER, Subquery WHERE, Subquery FROM, GROUP BY HAVING).
- [x] Đã bổ sung bộ kiểm thử `tests/test_part2_queries.sql` (bắt lỗi trong khoảng 52001-52015).
- [x] Cập nhật GitHub Actions CI workflow thực thi đầy đủ Part 1 và Part 2.

---

## 4. Minh chứng kiểm thử thực tế (Test Verification Proof)

Chạy kiểm thử trên Docker container `sqlserver` (SQL Server 2022 CU27):

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

---

## 5. Ý kiến phản biện & Đánh giá của các thành viên (Peer Review Comments)

### Tác giả: Trần Minh Tiến (`tien.tm@fpt.edu.vn`)
- **Mô tả**:
  > *"Chào Dũng và Long, mình đã hoàn thành trọn vẹn phần việc của Vòng lặp 2 (R3). Mình đã nạp đủ 50 loài Pokémon chuẩn với đầy đủ chỉ số, và mỗi bảng trong CSDL đều có từ 10 dòng trở lên. Mình cũng đã thiết kế 2 Views nghiệp vụ và 10 câu truy vấn đa dạng (2 INNER, 2 OUTER, 2 Subquery WHERE, 2 Subquery FROM, 2 GROUP BY HAVING). Mình đã viết bộ test `test_part2_queries.sql` và cập nhật CI workflow. Mọi người review và cho ý kiến giúp mình nhé!"*

### Reviewer 1: Nguyễn Văn Dũng (`dung.nv@fpt.edu.vn`)
- **Ý kiến**:
  > *"Mình đã pull branch `feature/tien-data-queries` về và kiểm tra đối chiếu dữ liệu nạp trong `insert.sql` với 17 ràng buộc toàn vẹn mà mình đã thiết lập ở Part 1. Kết quả rất ấn tượng: toàn bộ 50 Pokémon đều thỏa mãn BaseHP > 0 và UNIQUE DexNumber/Name; 20 cá thể trong `OwnedPokemon` đều có Level nằm trong khoảng [1, 100] và PartySlot chuẩn; các khóa ngoại tham chiếu bảng `Location`, `Region`, `Trainer`, `Pokemon` đều khớp 100%, không hề có lỗi cô lập khóa ngoại nào. Dữ liệu nạp rất thực tế và chỉn chu. Mình Approve!"*
- **Đánh giá chất lượng**: [x] Đạt yêu cầu | [ ] Cần bổ sung

### Reviewer 2: Hoàng Phi Long (`long.hp@fpt.edu.vn`)
- **Ý kiến**:
  > *"Mình đã chạy toàn bộ pipeline từ `createDB.sql` -> `constraints.sql` -> `test_part1_schema.sql` -> `insert.sql` -> `views.sql` -> `queries.sql` -> `test_part2_queries.sql` trên container SQL Server 2022. Thời gian thực thi cực nhanh, toàn bộ 10 query phân tích chạy rất mượt và trả về kết quả chính xác. File test `test_part2_queries.sql` xử lý bắt lỗi bằng `THROW` chuẩn trong dải 52001-52015. Cấu hình CI GitHub Actions được cập nhật tuần tự, logic rõ ràng. Phần dữ liệu và view này đã sẵn sàng để mình bước sang Vòng lặp 3 làm phần Lập trình nâng cao (Function, Trigger, Procedure). Mình phê duyệt và thực hiện merge `--no-ff` vào `develop`."*
- **Đánh giá chất lượng**: [x] Đạt yêu cầu | [ ] Cần bổ sung

---

## 6. Phê duyệt sáp nhập (Approval Sign-off)
- [x] Thành viên phản biện 1 (Nguyễn Văn Dũng) ký duyệt (Approved)
- [x] Thành viên phản biện 2 (Hoàng Phi Long) ký duyệt (Approved)
- [x] Đã sẵn sàng sáp nhập (Merge) vào nhánh `develop`
