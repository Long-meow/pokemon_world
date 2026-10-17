/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       views.sql
   Purpose:    Creates standard business views for active battle party lineup
               and personal Pokédex completion progress.
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- VIEW 1: dbo.vw_TrainerParty
-- Business Purpose:
--   Hiển thị danh sách đội hình thi đấu chính thức (các cá thể Pokémon đang
--   được xếp vào PartySlot từ 1 đến 6) của từng Huấn luyện viên.
--   Nếu cá thể có biệt danh (Nickname) thì hiển thị biệt danh, nếu không có
--   thì tự động dùng tên loài (Species/p.Name).
-- Output Columns:
--   TrainerID, Username, PartySlot, OwnedPokemonID, DisplayName, Species, Level
-- =============================================================================
CREATE OR ALTER VIEW dbo.vw_TrainerParty
AS
SELECT 
    op.TrainerID,
    t.Username,
    op.PartySlot,
    op.OwnedPokemonID,
    COALESCE(op.Nickname, p.Name) AS DisplayName,
    p.Name AS Species,
    op.[Level]
FROM dbo.OwnedPokemon op
INNER JOIN dbo.Trainer t ON op.TrainerID = t.TrainerID
INNER JOIN dbo.Pokemon p ON op.PokemonID = p.PokemonID
WHERE op.PartySlot IS NOT NULL;
GO

-- =============================================================================
-- VIEW 2: dbo.vw_PokedexProgress
-- Business Purpose:
--   Thống kê tiến độ hoàn thành bách khoa toàn thư cá nhân (Personal Pokédex)
--   của từng Huấn luyện viên: tổng số loài đã gặp (SeenCount), tổng số loài
--   đã thu phục thành công (CaughtCount), tổng số loài hiện có trong thế giới
--   (TotalPokemon), và tỷ lệ phần trăm hoàn thành (CompletionPercentage).
-- Output Columns:
--   TrainerID, Username, SeenCount, CaughtCount, TotalPokemon, CompletionPercentage
-- =============================================================================
CREATE OR ALTER VIEW dbo.vw_PokedexProgress
AS
SELECT 
    t.TrainerID,
    t.Username,
    COUNT(pp.PokemonID) AS SeenCount,
    COALESCE(SUM(CASE WHEN pp.IsCaught = 1 THEN 1 ELSE 0 END), 0) AS CaughtCount,
    (SELECT COUNT(*) FROM dbo.Pokemon) AS TotalPokemon,
    CAST(ROUND(COALESCE(SUM(CASE WHEN pp.IsCaught = 1 THEN 1.0 ELSE 0.0 END), 0.0) * 100.0 / 
         NULLIF((SELECT COUNT(*) FROM dbo.Pokemon), 0), 2) AS DECIMAL(5,2)) AS CompletionPercentage
FROM dbo.Trainer t
LEFT JOIN dbo.PersonalPokedex pp ON t.TrainerID = pp.TrainerID
GROUP BY t.TrainerID, t.Username;
GO
