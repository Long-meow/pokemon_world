/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       queries.sql
   Purpose:    Contains 10 functional business queries covering all assignment
               requirements: 2 INNER JOIN, 2 OUTER JOIN, 2 Subquery in WHERE,
               2 Subquery in FROM (Derived Tables), 2 GROUP BY with HAVING.
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- 1. INNER JOIN QUERY 1
-- Business Question (Câu hỏi nghiệp vụ):
--   Liệt kê danh sách các điểm phân bố Pokémon hoang dã trên toàn thế giới,
--   bao gồm: Tên vùng đất (Region), Tên địa danh (Location), Loại địa danh
--   (LocationType), Số hiệu Pokédex, Tên loài Pokémon, Hệ nguyên tố chính,
--   và khoảng Cấp độ xuất hiện (MinLevel - MaxLevel).
-- Technical Logic:
--   Kết hợp (INNER JOIN) 4 bảng dữ liệu: WildEncounter -> Location -> Region -> Pokemon
--   để truy xuất đầy đủ thông tin địa lý và sinh thái của từng điểm xuất hiện hoang dã.
-- =============================================================================
SELECT 
    r.Name AS RegionName,
    l.Name AS LocationName,
    l.LocationType,
    p.NationalDexNumber,
    p.Name AS PokemonName,
    p.PrimaryType,
    we.MinLevel,
    we.MaxLevel
FROM dbo.WildEncounter we
INNER JOIN dbo.Location l ON we.LocationID = l.LocationID
INNER JOIN dbo.Region r ON l.RegionID = r.RegionID
INNER JOIN dbo.Pokemon p ON we.PokemonID = p.PokemonID
ORDER BY r.RegionID, l.LocationID, we.MinLevel;
GO

-- =============================================================================
-- 2. INNER JOIN QUERY 2
-- Business Question (Câu hỏi nghiệp vụ):
--   Hiển thị danh sách đội hình thi đấu chính thức (các vị trí PartySlot từ 1 đến 6)
--   của tất cả các Nhà huấn luyện, kèm theo Tên huấn luyện viên, Vị trí đội hình,
--   Biệt danh hiển thị (DisplayName: ưu tiên Nickname, nếu NULL thì dùng tên loài),
--   Tên loài, Hệ nguyên tố (PrimaryType, SecondaryType), và Cấp độ hiện tại.
-- Technical Logic:
--   Kết hợp (INNER JOIN) 3 bảng: OwnedPokemon -> Trainer -> Pokemon với điều kiện lọc
--   WHERE op.PartySlot IS NOT NULL để lấy những cá thể đang tham gia đội hình chính.
-- =============================================================================
SELECT 
    t.Username,
    t.Email,
    op.PartySlot,
    COALESCE(op.Nickname, p.Name) AS DisplayName,
    p.Name AS SpeciesName,
    p.PrimaryType,
    COALESCE(p.SecondaryType, 'None') AS SecondaryType,
    op.[Level]
FROM dbo.OwnedPokemon op
INNER JOIN dbo.Trainer t ON op.TrainerID = t.TrainerID
INNER JOIN dbo.Pokemon p ON op.PokemonID = p.PokemonID
WHERE op.PartySlot IS NOT NULL
ORDER BY t.Username, op.PartySlot;
GO

-- =============================================================================
-- 3. OUTER JOIN QUERY 1 (LEFT OUTER JOIN)
-- Business Question (Câu hỏi nghiệp vụ):
--   Thống kê toàn bộ danh sách các địa danh trong thế giới Pokémon và số lượng
--   các điểm gặp thú hoang tại từng địa danh. Kể cả các địa danh hoang sơ hoặc
--   đô thị chưa ghi nhận Pokémon hoang dã nào sinh sống cũng phải hiển thị (số lượng = 0).
-- Technical Logic:
--   Sử dụng LEFT OUTER JOIN giữa bảng Location và WildEncounter (kết hợp INNER JOIN
--   với Region) kèm hàm tổng hợp COUNT(we.EncounterID) để không bỏ sót địa danh nào.
-- =============================================================================
SELECT 
    l.LocationID,
    l.Name AS LocationName,
    l.LocationType,
    r.Name AS RegionName,
    COUNT(we.EncounterID) AS TotalWildEncounters,
    COALESCE(MIN(we.MinLevel), 0) AS MinWildLevel,
    COALESCE(MAX(we.MaxLevel), 0) AS MaxWildLevel
FROM dbo.Location l
INNER JOIN dbo.Region r ON l.RegionID = r.RegionID
LEFT OUTER JOIN dbo.WildEncounter we ON l.LocationID = we.LocationID
GROUP BY l.LocationID, l.Name, l.LocationType, r.Name
ORDER BY TotalWildEncounters DESC, l.LocationID;
GO

-- =============================================================================
-- 4. OUTER JOIN QUERY 2 (LEFT OUTER JOIN)
-- Business Question (Câu hỏi nghiệp vụ):
--   Thống kê mức độ phổ biến của tất cả 50 loài Pokémon trong cơ sở dữ liệu:
--   cho biết mỗi loài đã được các Huấn luyện viên bắt giữ bao nhiêu lần trên toàn
--   mạng lưới, bao gồm cả những loài quý hiếm chưa từng được ai bắt (số lần bắt = 0).
-- Technical Logic:
--   Sử dụng LEFT OUTER JOIN từ bảng danh mục gốc Pokemon sang bảng thực thể OwnedPokemon
--   kèm hàm COUNT(op.OwnedPokemonID) và AVG cấp độ của các cá thể thuộc loài đó.
-- =============================================================================
SELECT 
    p.NationalDexNumber,
    p.Name AS PokemonName,
    p.PrimaryType,
    COALESCE(p.SecondaryType, 'None') AS SecondaryType,
    COUNT(op.OwnedPokemonID) AS TotalOwnedCount,
    COALESCE(AVG(CAST(op.[Level] AS DECIMAL(5,2))), 0.00) AS AvgOwnedLevel
FROM dbo.Pokemon p
LEFT OUTER JOIN dbo.OwnedPokemon op ON p.PokemonID = op.PokemonID
GROUP BY p.PokemonID, p.NationalDexNumber, p.Name, p.PrimaryType, p.SecondaryType
ORDER BY TotalOwnedCount DESC, p.NationalDexNumber;
GO

-- =============================================================================
-- 5. SUBQUERY IN WHERE QUERY 1
-- Business Question (Câu hỏi nghiệp vụ):
--   Tìm danh sách các Nhà huấn luyện sở hữu ít nhất một cá thể Pokémon đạt cấp độ
--   vượt trội (cấp độ lớn hơn hoặc bằng cấp độ trung bình của toàn bộ các cá thể
--   Pokémon thuộc quyền sở hữu trong cơ sở dữ liệu).
-- Technical Logic:
--   Sử dụng truy vấn con lồng trong mệnh đề WHERE (WHERE t.TrainerID IN (...)) kết hợp
--   truy vấn con vô hướng (Scalar Subquery) tính giá trị AVG(Level) trên bảng OwnedPokemon.
-- =============================================================================
SELECT 
    t.TrainerID,
    t.Username,
    t.Email,
    l.Name AS CurrentLocation
FROM dbo.Trainer t
INNER JOIN dbo.Location l ON t.LocationID = l.LocationID
WHERE t.TrainerID IN (
    SELECT DISTINCT op.TrainerID
    FROM dbo.OwnedPokemon op
    WHERE op.[Level] >= (
        SELECT AVG(CAST([Level] AS FLOAT))
        FROM dbo.OwnedPokemon
    )
)
ORDER BY t.TrainerID;
GO

-- =============================================================================
-- 6. SUBQUERY IN WHERE QUERY 2
-- Business Question (Câu hỏi nghiệp vụ):
--   Liệt kê danh sách các loài Pokémon có tổng bộ ba chỉ số cơ bản (Máu + Tấn công + Phòng thủ)
--   vượt trội hơn mức điểm cơ bản trung bình của toàn bộ 50 loài trong bách khoa toàn thư.
-- Technical Logic:
--   Sử dụng truy vấn con trong mệnh đề WHERE tính trung bình tổng 3 chỉ số
--   AVG(BaseHP + BaseAttack + BaseDefense) của toàn bộ bảng Pokemon.
-- =============================================================================
SELECT 
    p.NationalDexNumber,
    p.Name AS PokemonName,
    p.PrimaryType,
    p.BaseHP,
    p.BaseAttack,
    p.BaseDefense,
    (p.BaseHP + p.BaseAttack + p.BaseDefense) AS TotalBaseStats
FROM dbo.Pokemon p
WHERE (p.BaseHP + p.BaseAttack + p.BaseDefense) > (
    SELECT AVG(CAST(BaseHP + BaseAttack + BaseDefense AS FLOAT))
    FROM dbo.Pokemon
)
ORDER BY TotalBaseStats DESC, p.NationalDexNumber;
GO

-- =============================================================================
-- 7. SUBQUERY IN FROM (DERIVED TABLE) QUERY 1
-- Business Question (Câu hỏi nghiệp vụ):
--   Từ bảng thống kê phân tích số lượng Pokémon sở hữu và cấp độ cao nhất của mỗi
--   Nhà huấn luyện, lọc và xếp hạng những Huấn luyện viên có cá thể mạnh nhất
--   đạt cấp độ từ 25 trở lên.
-- Technical Logic:
--   Tạo bảng dẫn xuất (Derived Table tRank) tổng hợp COUNT, MAX, AVG level theo TrainerID,
--   sau đó truy vấn ngoài lọc điều kiện WHERE tRank.MaxLevel >= 25.
-- =============================================================================
SELECT 
    tRank.TrainerID,
    tRank.Username,
    tRank.TotalOwned,
    tRank.MaxLevel,
    tRank.AvgLevel
FROM (
    SELECT 
        t.TrainerID,
        t.Username,
        COUNT(op.OwnedPokemonID) AS TotalOwned,
        MAX(op.[Level]) AS MaxLevel,
        CAST(ROUND(AVG(CAST(op.[Level] AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgLevel
    FROM dbo.Trainer t
    INNER JOIN dbo.OwnedPokemon op ON t.TrainerID = op.TrainerID
    GROUP BY t.TrainerID, t.Username
) AS tRank
WHERE tRank.MaxLevel >= 25
ORDER BY tRank.MaxLevel DESC, tRank.TotalOwned DESC;
GO

-- =============================================================================
-- 8. SUBQUERY IN FROM (DERIVED TABLE) QUERY 2
-- Business Question (Câu hỏi nghiệp vụ):
--   Từ bảng dẫn xuất tính toán cấp độ hoang dã trung bình và số lượng loài tại từng
--   địa danh, hiển thị những địa danh có cấp độ hoang dã trung bình từ 5.0 trở lên
--   kèm tên vùng đất tương ứng.
-- Technical Logic:
--   Sử dụng bảng dẫn xuất (Derived Table locSummary) gom nhóm theo địa danh để tính
--   cấp độ trung bình của các điểm xuất hiện ((MinLevel + MaxLevel) / 2.0), sau đó
--   kết hợp với bảng Region để bổ sung tên vùng đất và áp dụng bộ lọc cấp độ.
-- =============================================================================
SELECT 
    locSummary.LocationID,
    locSummary.LocationName,
    r.Name AS RegionName,
    locSummary.EncounterCount,
    locSummary.AvgWildLevel
FROM (
    SELECT 
        we.LocationID,
        l.Name AS LocationName,
        l.RegionID,
        COUNT(we.EncounterID) AS EncounterCount,
        CAST(ROUND(AVG(CAST((we.MinLevel + we.MaxLevel) / 2.0 AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgWildLevel
    FROM dbo.WildEncounter we
    INNER JOIN dbo.Location l ON we.LocationID = l.LocationID
    GROUP BY we.LocationID, l.Name, l.RegionID
) AS locSummary
INNER JOIN dbo.Region r ON locSummary.RegionID = r.RegionID
WHERE locSummary.AvgWildLevel >= 5.0
ORDER BY locSummary.AvgWildLevel DESC;
GO

-- =============================================================================
-- 9. GROUP BY WITH AGGREGATE FUNCTIONS QUERY 1
-- Business Question (Câu hỏi nghiệp vụ):
--   Thống kê số lượng loài, lượng máu trung bình (BaseHP), chỉ số tấn công cao nhất
--   (BaseAttack), và chỉ số phòng thủ trung bình (BaseDefense) phân nhóm theo Hệ chính
--   (PrimaryType), chỉ lấy các hệ có từ 2 loài trở lên trong cơ sở dữ liệu.
-- Technical Logic:
--   Sử dụng GROUP BY PrimaryType kèm các hàm tổng hợp COUNT(*), AVG(BaseHP),
--   MAX(BaseAttack), AVG(BaseDefense) và lọc nhóm bằng HAVING COUNT(*) >= 2.
-- =============================================================================
SELECT 
    p.PrimaryType,
    COUNT(*) AS TotalSpecies,
    CAST(ROUND(AVG(CAST(p.BaseHP AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgBaseHP,
    MAX(p.BaseAttack) AS MaxBaseAttack,
    CAST(ROUND(AVG(CAST(p.BaseDefense AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgBaseDefense
FROM dbo.Pokemon p
GROUP BY p.PrimaryType
HAVING COUNT(*) >= 2
ORDER BY TotalSpecies DESC, AvgBaseHP DESC;
GO

-- =============================================================================
-- 10. GROUP BY WITH AGGREGATE FUNCTIONS QUERY 2
-- Business Question (Câu hỏi nghiệp vụ):
--   Đánh giá hiệu suất khám phá bách khoa toàn thư của các Nhà huấn luyện:
--   thống kê tổng số loài đã phát hiện trong sổ Pokédex, số lượng loài đã thu phục
--   thành công (IsCaught = 1), và mốc thời gian bắt đầu hành trình (FirstSeenAt sớm nhất).
--   Chỉ lọc ra những Huấn luyện viên đã ghi nhận từ 2 loài Pokémon trở lên.
-- Technical Logic:
--   Gom nhóm theo TrainerID và Username trên bảng PersonalPokedex kết hợp Trainer,
--   sử dụng COUNT, SUM(CASE WHEN IsCaught = 1 ...), MIN(FirstSeenAt) và lọc HAVING COUNT(pp.PokemonID) >= 2.
-- =============================================================================
SELECT 
    t.TrainerID,
    t.Username,
    COUNT(pp.PokemonID) AS TotalDiscovered,
    SUM(CASE WHEN pp.IsCaught = 1 THEN 1 ELSE 0 END) AS TotalCaught,
    MIN(pp.FirstSeenAt) AS JourneyStartedAt
FROM dbo.Trainer t
INNER JOIN dbo.PersonalPokedex pp ON t.TrainerID = pp.TrainerID
GROUP BY t.TrainerID, t.Username
HAVING COUNT(pp.PokemonID) >= 2
ORDER BY TotalCaught DESC, TotalDiscovered DESC;
GO
