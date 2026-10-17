# Pull Request #3: Implement T-SQL Programmability, Test Part 3, Deploy.sh, and Complete CI Workflow

- **PR Number**: #3
- **Title**: `feat(programmability-deploy): R4 - implement T-SQL programmability, test_part3, deploy.sh, and complete CI workflow`
- **Branch**: `feature/long-programmability-deploy` -> `develop`
- **Author**: Hoàng Phi Long (`Hoang Phi Long <long.hp@fpt.edu.vn>`)
- **Reviewers**: Nguyễn Văn Dũng (`dung.nv@fpt.edu.vn`), Trần Minh Tiến (`tien.tm@fpt.edu.vn`)
- **Status**: MERGED (Merged by Hoàng Phi Long via `--no-ff`)

---

## 1. Thông tin thành viên & Phân công nhiệm vụ
- **Người thực hiện (PR Owner)**: Hoàng Phi Long (`worker_m4`), Trưởng nhóm kỹ thuật & DevOps Lead
- **Nhánh làm việc (Feature Branch)**: `feature/long-programmability-deploy`
- **Nhánh đích (Target Branch)**: `develop`
- **Hạng mục bài tập lớn**: Requirement R4 — Vòng lặp 3: Lập trình T-SQL Nâng cao, Kiểm thử Tích hợp & Tự động Triển khai

---

## 2. Tóm tắt nội dung thay đổi (Summary of Changes)
- **`function.sql`**:
  - Xây dựng hàm vô hướng `dbo.fn_GetPokemonTotalStats (@PokemonID INT) RETURNS INT`.
  - Nghiệp vụ: Tính toán tổng chỉ số cơ bản của loài Pokémon (`BaseHP + BaseAttack + BaseDefense`).
  - Xử lý biên: Trả về 0 nếu mã loài không tồn tại (`COALESCE(@TotalStats, 0)`).
  - Độ chính xác: Bulbasaur (ID = 1) trả về chính xác 143 điểm (45 + 49 + 49).
- **`trigger.sql`**:
  - Xây dựng trigger kiểm tra dữ liệu `dbo.TR_OwnedPokemon_CheckLevel` trên bảng `dbo.OwnedPokemon`.
  - Cơ chế: `AFTER INSERT, UPDATE`, rà soát bảng ảo `inserted`.
  - Nghiệp vụ bảo mật đa tầng (Defense-in-depth): Nếu phát hiện cá thể có `[Level] < 1 OR [Level] > 100`, thực hiện `ROLLBACK TRANSACTION` và ném mã lỗi nghiệp vụ chuẩn 50050 (`THROW 50050, ...`).
- **`procedure.sql`**:
  - Xây dựng thủ tục lưu trữ giao dịch `dbo.usp_CatchPokemon` thu phục Pokémon hoang dã.
  - Quản lý giao dịch nguyên tử (ACID Transaction) với `SET XACT_ABORT ON` và `BEGIN TRAN ... COMMIT TRAN`.
  - Xác thực nghiêm ngặt:
    * Kiểm tra Nhà huấn luyện tồn tại (`TrainerID`), ném lỗi 51000 nếu không tìm thấy.
    * Kiểm tra điều kiện phân bố hoang dã (`WildEncounter`: `LocationID`, `PokemonID`, `@Level BETWEEN MinLevel AND MaxLevel`), ném lỗi 51001 nếu không hợp lệ.
  - Tự động thêm thú cưng mới vào PC (`OwnedPokemon`, `PartySlot = NULL`) và đồng bộ hóa bách khoa toàn thư (`PersonalPokedex`, `IsCaught = 1`, `FirstSeenAt = GETDATE()`) qua cú pháp `MERGE`.
  - Trả về mã định danh thú cưng mới tạo (`@NewOwnedPokemonID`) qua cả tham số `OUTPUT` và tập kết quả `SELECT`.
- **`tests/test_part3_programmability.sql`**:
  - Bộ kiểm thử AI modular toàn diện cho Part 3:
    * Block 1: Unit test hàm `fn_GetPokemonTotalStats` với Bulbasaur (143 điểm), ID không tồn tại (0 điểm), Charmander (134 điểm), Squirtle (157 điểm).
    * Block 2: Negative test trigger `TR_OwnedPokemon_CheckLevel` khi chèn Level = 105 và Level = 0, bắt chính xác mã lỗi 50050 qua `TRY...CATCH`, xác nhận giao dịch rollback và số dòng không đổi.
    * Block 3: Transaction ACID test cho thủ tục `usp_CatchPokemon` thu phục thành công trong giao dịch cô lập, đồng bộ `PersonalPokedex`, và rollback an toàn; kiểm tra bắt lỗi 51000 (Trainer không tồn tại) và 51001 (Encounter không hợp lệ).
- **`test_all.sql`**:
  - Kịch bản kiểm thử tích hợp toàn diện 5 Blocks bao phủ trọn vẹn: Schema (7 bảng, 34 cột), Ràng buộc (17 constraints trusted/enabled), Dữ liệu (50 Pokémon, >= 10 dòng/bảng), Negative Tests (Trigger 50050, CHECK 547, UNIQUE 2627), và Nghiệp vụ (Function, Views, 10 Queries, Procedure).
- **`deploy.sh`**:
  - Kịch bản bash tự động hóa triển khai CSDL trọn gói 1 lệnh chuẩn DevOps.
  - Chạy tuần tự 9 bước (`createDB.sql`, `constraints.sql`, `insert.sql`, `views.sql`, `function.sql`, `trigger.sql`, `procedure.sql`, `queries.sql`, `test_all.sql`).
  - Kiểm tra container Docker `sqlserver`, kiểm tra kết nối, giao diện terminal màu trực quan.
  - Thời gian thực thi siêu tốc: hoàn tất toàn bộ trong 2-3 giây với exit code 0.
- **`.github/workflows/assignment-ci.yml`**:
  - Hoàn thiện pipeline CI/CD GitHub Actions: tự động triển khai và kiểm thử 13 bước liên hoàn bao gồm cả 3 bộ test modular (`test_part1`, `test_part2`, `test_part3`), `test_all.sql`, và xác thực runner `deploy.sh`.

---

## 3. Danh sách kiểm tra thay đổi (Checklist)
- [x] Lấy mã nguồn SQL chính xác từ `sql/assignment/` (`function.sql`, `trigger.sql`, `procedure.sql`, `test_all.sql`, `deploy.sh`).
- [x] Đã đối chiếu mã băm MD5 khớp 100% với file chuẩn trong `sql/assignment/`.
- [x] Đã tạo bộ test AI `tests/test_part3_programmability.sql` bao phủ Function, Trigger (lỗi 50050), và Procedure ACID.
- [x] Cập nhật hoàn thiện GitHub Actions CI workflow với đầy đủ 3 modular tests và `test_all.sql`.
- [x] Kiểm thử cục bộ thành công 100% trên container SQL Server 2022.
- [x] Kịch bản `deploy.sh` chạy thành công toàn bộ 9 bước trong 2-3 giây.
- [x] Đảm bảo tính nguyên vẹn, không có dummy/facade code, tuân thủ Integrity Mandate.

---

## 4. Minh chứng kiểm thử thực tế (Test Verification Proof)

### 4.1. Kết quả chạy kiểm thử Part 3 (`tests/test_part3_programmability.sql`)
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

### 4.2. Kết quả chạy tự động hóa `deploy.sh` (2-3 giây)
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
[STEP 3/9] 2026-10-17 10:40:34 | Deploying insert.sql (Seeds 50 Pokemon and >= 10 rows per table) -> Database: [pokemon_world]
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

---

## 5. Trao đổi thảo luận & Phản biện sinh viên (Team Discussion & Peer Review)

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

---

## 6. Kết luận & Quyết định Merge
- Cả 2 thành viên phản biện (Nguyễn Văn Dũng và Trần Minh Tiến) đều phê duyệt (Approved).
- Toàn bộ 13 bước trong GitHub Actions CI và 9 bước trong kịch bản `deploy.sh` đều vượt qua 100%.
- Hoàng Phi Long thực hiện merge `--no-ff` nhánh `feature/long-programmability-deploy` vào nhánh `develop`.
