/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       tests/test_part2_queries.sql
   Purpose:    AI-Generated Modular Unit Test Suite for Part 2:
               - Row count threshold audit across all 7 core tables:
                 * Pokemon >= 50
                 * Region >= 10
                 * Location >= 10
                 * Trainer >= 10
                 * WildEncounter >= 10
                 * OwnedPokemon >= 10
                 * PersonalPokedex >= 10
               - Existence, compilation, and non-empty dataset validation for:
                 * dbo.vw_TrainerParty
                 * dbo.vw_PokedexProgress
               - Execution validation and non-empty result sets for all 10 business queries:
                 * Query 1: INNER JOIN (Wild Encounters across 4 tables)
                 * Query 2: INNER JOIN (Active Party Lineup across 3 tables)
                 * Query 3: OUTER JOIN (Location Wild Encounters)
                 * Query 4: OUTER JOIN (Species Global Capture Count)
                 * Query 5: Subquery WHERE (Elite Trainers above avg level)
                 * Query 6: Subquery WHERE (Pokemon above avg base stats)
                 * Query 7: Subquery FROM (Trainer High-Level Ranking Derived Table)
                 * Query 8: Subquery FROM (Regional Wild Level Derived Table)
                 * Query 9: GROUP BY HAVING (Primary Type Stats >= 2 species)
                 * Query 10: GROUP BY HAVING (Trainer Collection Progress >= 2 species)
   Target:     Microsoft SQL Server 2022+
   Author:     AI Testing Specialist & Tran Minh Tien (worker_m3)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

PRINT '============================================================';
PRINT '  TEST PART 2: DATA VOLUME, VIEWS & QUERIES AUDIT          ';
PRINT '  Author: Tran Minh Tien | Target: Microsoft SQL Server 2022 ';
PRINT '============================================================';
PRINT '';

-- =============================================================================
-- TEST 2.1: ROW COUNT THRESHOLD VERIFICATION ACROSS ALL 7 CORE TABLES
-- Requirements:
--   * Pokemon >= 50
--   * Region >= 10
--   * Location >= 10
--   * Trainer >= 10
--   * WildEncounter >= 10
--   * OwnedPokemon >= 10
--   * PersonalPokedex >= 10
-- Error Codes: 52001 - 52007
-- =============================================================================
PRINT '>>> [1/3] Verifying Row Count Thresholds Across 7 Core Tables...';

-- 1.1 Table Pokemon >= 50
DECLARE @CountPokemon INT = (SELECT COUNT(*) FROM dbo.Pokemon);
IF @CountPokemon < 50
BEGIN
    DECLARE @ErrPokemonMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.Pokemon has %d rows (expected >= 50).', @CountPokemon);
    THROW 52001, @ErrPokemonMsg, 1;
END;
PRINT '    [PASS] Table dbo.Pokemon: ' + CAST(@CountPokemon AS NVARCHAR(10)) + ' rows (>= 50 threshold met).';

-- 1.2 Table Region >= 10
DECLARE @CountRegion INT = (SELECT COUNT(*) FROM dbo.Region);
IF @CountRegion < 10
BEGIN
    DECLARE @ErrRegionMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.Region has %d rows (expected >= 10).', @CountRegion);
    THROW 52002, @ErrRegionMsg, 1;
END;
PRINT '    [PASS] Table dbo.Region: ' + CAST(@CountRegion AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';

-- 1.3 Table Location >= 10
DECLARE @CountLocation INT = (SELECT COUNT(*) FROM dbo.Location);
IF @CountLocation < 10
BEGIN
    DECLARE @ErrLocationMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.Location has %d rows (expected >= 10).', @CountLocation);
    THROW 52003, @ErrLocationMsg, 1;
END;
PRINT '    [PASS] Table dbo.Location: ' + CAST(@CountLocation AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';

-- 1.4 Table Trainer >= 10
DECLARE @CountTrainer INT = (SELECT COUNT(*) FROM dbo.Trainer);
IF @CountTrainer < 10
BEGIN
    DECLARE @ErrTrainerMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.Trainer has %d rows (expected >= 10).', @CountTrainer);
    THROW 52004, @ErrTrainerMsg, 1;
END;
PRINT '    [PASS] Table dbo.Trainer: ' + CAST(@CountTrainer AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';

-- 1.5 Table WildEncounter >= 10
DECLARE @CountWildEncounter INT = (SELECT COUNT(*) FROM dbo.WildEncounter);
IF @CountWildEncounter < 10
BEGIN
    DECLARE @ErrEncounterMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.WildEncounter has %d rows (expected >= 10).', @CountWildEncounter);
    THROW 52005, @ErrEncounterMsg, 1;
END;
PRINT '    [PASS] Table dbo.WildEncounter: ' + CAST(@CountWildEncounter AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';

-- 1.6 Table OwnedPokemon >= 10
DECLARE @CountOwnedPokemon INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
IF @CountOwnedPokemon < 10
BEGIN
    DECLARE @ErrOwnedMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.OwnedPokemon has %d rows (expected >= 10).', @CountOwnedPokemon);
    THROW 52006, @ErrOwnedMsg, 1;
END;
PRINT '    [PASS] Table dbo.OwnedPokemon: ' + CAST(@CountOwnedPokemon AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';

-- 1.7 Table PersonalPokedex >= 10
DECLARE @CountPersonalPokedex INT = (SELECT COUNT(*) FROM dbo.PersonalPokedex);
IF @CountPersonalPokedex < 10
BEGIN
    DECLARE @ErrPokedexMsg NVARCHAR(200) = FORMATMESSAGE('TEST 2.1 FAILED: Table dbo.PersonalPokedex has %d rows (expected >= 10).', @CountPersonalPokedex);
    THROW 52007, @ErrPokedexMsg, 1;
END;
PRINT '    [PASS] Table dbo.PersonalPokedex: ' + CAST(@CountPersonalPokedex AS NVARCHAR(10)) + ' rows (>= 10 threshold met).';
PRINT '';

-- =============================================================================
-- TEST 2.2: VERIFY BUSINESS VIEWS EXISTENCE, COMPILATION & DATASET INTEGRITY
-- Requirements:
--   * dbo.vw_TrainerParty exists, compiles and returns non-empty dataset
--   * dbo.vw_PokedexProgress exists, compiles and returns non-empty dataset
-- Error Codes: 52008, 52009
-- =============================================================================
PRINT '>>> [2/3] Verifying Business Views Existence, Compilation & Non-Empty Output...';

-- 2.1 View dbo.vw_TrainerParty
IF NOT EXISTS (
    SELECT 1 
    FROM sys.views v
    INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
    WHERE s.name = 'dbo' AND v.name = 'vw_TrainerParty'
)
BEGIN
    THROW 52008, 'TEST 2.2 FAILED: View dbo.vw_TrainerParty does not exist in sys.views.', 1;
END;

DECLARE @PartyRowCount INT = 0;
BEGIN TRY
    SELECT @PartyRowCount = COUNT(*) FROM dbo.vw_TrainerParty;
END TRY
BEGIN CATCH
    DECLARE @ErrPartyCompile NVARCHAR(300) = FORMATMESSAGE('TEST 2.2 FAILED: Failed to query dbo.vw_TrainerParty: %s', ERROR_MESSAGE());
    THROW 52008, @ErrPartyCompile, 1;
END CATCH;

IF @PartyRowCount <= 0
BEGIN
    THROW 52008, 'TEST 2.2 FAILED: View dbo.vw_TrainerParty returned 0 rows.', 1;
END;
PRINT '    [PASS] View dbo.vw_TrainerParty: compiled successfully and returned ' + CAST(@PartyRowCount AS NVARCHAR(10)) + ' active party records.';

-- 2.2 View dbo.vw_PokedexProgress
IF NOT EXISTS (
    SELECT 1 
    FROM sys.views v
    INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
    WHERE s.name = 'dbo' AND v.name = 'vw_PokedexProgress'
)
BEGIN
    THROW 52009, 'TEST 2.2 FAILED: View dbo.vw_PokedexProgress does not exist in sys.views.', 1;
END;

DECLARE @ProgressRowCount INT = 0;
BEGIN TRY
    SELECT @ProgressRowCount = COUNT(*) FROM dbo.vw_PokedexProgress;
END TRY
BEGIN CATCH
    DECLARE @ErrProgressCompile NVARCHAR(300) = FORMATMESSAGE('TEST 2.2 FAILED: Failed to query dbo.vw_PokedexProgress: %s', ERROR_MESSAGE());
    THROW 52009, @ErrProgressCompile, 1;
END CATCH;

IF @ProgressRowCount <= 0
BEGIN
    THROW 52009, 'TEST 2.2 FAILED: View dbo.vw_PokedexProgress returned 0 rows.', 1;
END;
PRINT '    [PASS] View dbo.vw_PokedexProgress: compiled successfully and returned ' + CAST(@ProgressRowCount AS NVARCHAR(10)) + ' trainer progress summaries.';
PRINT '';

-- =============================================================================
-- TEST 2.3: EXECUTION VALIDATION & NON-EMPTY ASSERTIONS FOR 10 BUSINESS QUERIES
-- Requirements:
--   * Execute all 10 analytical queries from queries.sql
--   * Validate that each query executes cleanly and yields non-empty output
-- Error Codes: 52010 - 52015
-- =============================================================================
PRINT '>>> [3/3] Validating Execution & Data Output of 10 Business Queries...';

-- 3.1 Query 1: INNER JOIN (Wild Encounters across 4 tables)
DECLARE @Q1RowCount INT = 0;
BEGIN TRY
    SELECT @Q1RowCount = COUNT(*) 
    FROM dbo.WildEncounter we
    INNER JOIN dbo.Location l ON we.LocationID = l.LocationID
    INNER JOIN dbo.Region r ON l.RegionID = r.RegionID
    INNER JOIN dbo.Pokemon p ON we.PokemonID = p.PokemonID;
END TRY
BEGIN CATCH
    DECLARE @ErrQ1 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 1 (INNER JOIN) execution error: %s', ERROR_MESSAGE());
    THROW 52010, @ErrQ1, 1;
END CATCH;

IF @Q1RowCount <= 0
    THROW 52010, 'TEST 2.3 FAILED: Query 1 (INNER JOIN Wild Encounters) returned 0 rows.', 1;
PRINT '    [PASS] Query 1 (INNER JOIN 4 Tables): ' + CAST(@Q1RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.2 Query 2: INNER JOIN (Active Party Lineup across 3 tables)
DECLARE @Q2RowCount INT = 0;
BEGIN TRY
    SELECT @Q2RowCount = COUNT(*) 
    FROM dbo.OwnedPokemon op
    INNER JOIN dbo.Trainer t ON op.TrainerID = t.TrainerID
    INNER JOIN dbo.Pokemon p ON op.PokemonID = p.PokemonID
    WHERE op.PartySlot IS NOT NULL;
END TRY
BEGIN CATCH
    DECLARE @ErrQ2 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 2 (INNER JOIN) execution error: %s', ERROR_MESSAGE());
    THROW 52011, @ErrQ2, 1;
END CATCH;

IF @Q2RowCount <= 0
    THROW 52011, 'TEST 2.3 FAILED: Query 2 (INNER JOIN Active Lineup) returned 0 rows.', 1;
PRINT '    [PASS] Query 2 (INNER JOIN 3 Tables): ' + CAST(@Q2RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.3 Query 3: OUTER JOIN (Location Wild Encounters Summary)
DECLARE @Q3RowCount INT = 0;
BEGIN TRY
    SELECT @Q3RowCount = COUNT(*) 
    FROM (
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
    ) AS q3;
END TRY
BEGIN CATCH
    DECLARE @ErrQ3 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 3 (OUTER JOIN) execution error: %s', ERROR_MESSAGE());
    THROW 52012, @ErrQ3, 1;
END CATCH;

IF @Q3RowCount <= 0
    THROW 52012, 'TEST 2.3 FAILED: Query 3 (OUTER JOIN Location Encounters) returned 0 rows.', 1;
PRINT '    [PASS] Query 3 (OUTER JOIN Locations): ' + CAST(@Q3RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.4 Query 4: OUTER JOIN (Global Species Capture Count)
DECLARE @Q4RowCount INT = 0;
BEGIN TRY
    SELECT @Q4RowCount = COUNT(*) 
    FROM (
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
    ) AS q4;
END TRY
BEGIN CATCH
    DECLARE @ErrQ4 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 4 (OUTER JOIN) execution error: %s', ERROR_MESSAGE());
    THROW 52013, @ErrQ4, 1;
END CATCH;

IF @Q4RowCount <= 0
    THROW 52013, 'TEST 2.3 FAILED: Query 4 (OUTER JOIN Species Captures) returned 0 rows.', 1;
PRINT '    [PASS] Query 4 (OUTER JOIN 50 Species): ' + CAST(@Q4RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.5 Query 5: Subquery in WHERE (Elite Trainers above Average Level)
DECLARE @Q5RowCount INT = 0;
BEGIN TRY
    SELECT @Q5RowCount = COUNT(*) 
    FROM dbo.Trainer t
    INNER JOIN dbo.Location l ON t.LocationID = l.LocationID
    WHERE t.TrainerID IN (
        SELECT DISTINCT op.TrainerID
        FROM dbo.OwnedPokemon op
        WHERE op.[Level] >= (
            SELECT AVG(CAST([Level] AS FLOAT))
            FROM dbo.OwnedPokemon
        )
    );
END TRY
BEGIN CATCH
    DECLARE @ErrQ5 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 5 (Subquery WHERE) execution error: %s', ERROR_MESSAGE());
    THROW 52014, @ErrQ5, 1;
END CATCH;

IF @Q5RowCount <= 0
    THROW 52014, 'TEST 2.3 FAILED: Query 5 (Subquery WHERE Elite Trainers) returned 0 rows.', 1;
PRINT '    [PASS] Query 5 (Subquery WHERE Elite Trainers): ' + CAST(@Q5RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.6 Query 6: Subquery in WHERE (Pokémon with Above Average Base Stats)
DECLARE @Q6RowCount INT = 0;
BEGIN TRY
    SELECT @Q6RowCount = COUNT(*) 
    FROM dbo.Pokemon p
    WHERE (p.BaseHP + p.BaseAttack + p.BaseDefense) > (
        SELECT AVG(CAST(BaseHP + BaseAttack + BaseDefense AS FLOAT))
        FROM dbo.Pokemon
    );
END TRY
BEGIN CATCH
    DECLARE @ErrQ6 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 6 (Subquery WHERE) execution error: %s', ERROR_MESSAGE());
    THROW 52014, @ErrQ6, 1;
END CATCH;

IF @Q6RowCount <= 0
    THROW 52014, 'TEST 2.3 FAILED: Query 6 (Subquery WHERE High Stats) returned 0 rows.', 1;
PRINT '    [PASS] Query 6 (Subquery WHERE High Stats): ' + CAST(@Q6RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.7 Query 7: Subquery in FROM (Derived Table - Trainer High-Level Ranking)
DECLARE @Q7RowCount INT = 0;
BEGIN TRY
    SELECT @Q7RowCount = COUNT(*) 
    FROM (
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
    ) AS q7;
END TRY
BEGIN CATCH
    DECLARE @ErrQ7 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 7 (Derived Table) execution error: %s', ERROR_MESSAGE());
    THROW 52015, @ErrQ7, 1;
END CATCH;

IF @Q7RowCount <= 0
    THROW 52015, 'TEST 2.3 FAILED: Query 7 (Derived Table Trainer Ranking) returned 0 rows.', 1;
PRINT '    [PASS] Query 7 (Derived Table Trainer Ranking): ' + CAST(@Q7RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.8 Query 8: Subquery in FROM (Derived Table - Regional Wild Level Summary)
DECLARE @Q8RowCount INT = 0;
BEGIN TRY
    SELECT @Q8RowCount = COUNT(*) 
    FROM (
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
    ) AS q8;
END TRY
BEGIN CATCH
    DECLARE @ErrQ8 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 8 (Derived Table) execution error: %s', ERROR_MESSAGE());
    THROW 52015, @ErrQ8, 1;
END CATCH;

IF @Q8RowCount <= 0
    THROW 52015, 'TEST 2.3 FAILED: Query 8 (Derived Table Wild Level) returned 0 rows.', 1;
PRINT '    [PASS] Query 8 (Derived Table Wild Level): ' + CAST(@Q8RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.9 Query 9: GROUP BY with HAVING (Primary Type Stats >= 2 Species)
DECLARE @Q9RowCount INT = 0;
BEGIN TRY
    SELECT @Q9RowCount = COUNT(*) 
    FROM (
        SELECT 
            p.PrimaryType,
            COUNT(*) AS TotalSpecies,
            CAST(ROUND(AVG(CAST(p.BaseHP AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgBaseHP,
            MAX(p.BaseAttack) AS MaxBaseAttack,
            CAST(ROUND(AVG(CAST(p.BaseDefense AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgBaseDefense
        FROM dbo.Pokemon p
        GROUP BY p.PrimaryType
        HAVING COUNT(*) >= 2
    ) AS q9;
END TRY
BEGIN CATCH
    DECLARE @ErrQ9 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 9 (GROUP BY HAVING) execution error: %s', ERROR_MESSAGE());
    THROW 52015, @ErrQ9, 1;
END CATCH;

IF @Q9RowCount <= 0
    THROW 52015, 'TEST 2.3 FAILED: Query 9 (GROUP BY HAVING Primary Types) returned 0 rows.', 1;
PRINT '    [PASS] Query 9 (GROUP BY HAVING Primary Types): ' + CAST(@Q9RowCount AS NVARCHAR(10)) + ' rows returned.';

-- 3.10 Query 10: GROUP BY with HAVING (Trainer Collection Progress >= 2 Species)
DECLARE @Q10RowCount INT = 0;
BEGIN TRY
    SELECT @Q10RowCount = COUNT(*) 
    FROM (
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
    ) AS q10;
END TRY
BEGIN CATCH
    DECLARE @ErrQ10 NVARCHAR(300) = FORMATMESSAGE('TEST 2.3 FAILED: Query 10 (GROUP BY HAVING) execution error: %s', ERROR_MESSAGE());
    THROW 52015, @ErrQ10, 1;
END CATCH;

IF @Q10RowCount <= 0
    THROW 52015, 'TEST 2.3 FAILED: Query 10 (GROUP BY HAVING Trainers) returned 0 rows.', 1;
PRINT '    [PASS] Query 10 (GROUP BY HAVING Trainers): ' + CAST(@Q10RowCount AS NVARCHAR(10)) + ' rows returned.';
PRINT '';

-- =============================================================================
-- FINAL TEST SUMMARY
-- =============================================================================
PRINT '============================================================';
PRINT '  ALL PART 2 DATA, VIEW & QUERY TESTS PASSED (100% OK)     ';
PRINT '============================================================';
GO
