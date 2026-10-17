/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       test_all.sql
   Purpose:    End-to-end automated verification test suite for the 34-column
               minimal schema. Validates schema counts, constraint trust, row
               thresholds, negative constraint & trigger tests, and programmability.
   Target:     Microsoft SQL Server 2022+
   Author:     Automated Verification & Deployment Specialist (Worker M3)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

PRINT '==================================================';
PRINT '  POKÉMON WORLD AUTOMATED VERIFICATION SUITE      ';
PRINT '  Database: pokemon_world | Standard 7-Table Edition ';
PRINT '==================================================';
PRINT '';

-- =============================================================================
-- BLOCK 1: SCHEMA TABLE & COLUMN AUDIT
-- Requirements:
--   * Exactly 7 user tables in sys.tables (schema dbo).
--   * Exactly 34 total columns across user tables.
--   * Throws error >= 52001 on failure.
-- =============================================================================
PRINT '>>> Starting BLOCK 1: Schema Table & Column Audit...';

DECLARE @TableCount INT;
SELECT @TableCount = COUNT(*) 
FROM sys.tables 
WHERE schema_id = SCHEMA_ID('dbo') AND is_ms_shipped = 0;

IF @TableCount <> 7
BEGIN
    DECLARE @ErrTableMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 1 FAILED: Expected exactly 7 user tables, but found %d.', @TableCount);
    THROW 52001, @ErrTableMsg, 1;
END;

DECLARE @ColumnCount INT;
SELECT @ColumnCount = COUNT(*)
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.schema_id = SCHEMA_ID('dbo') AND t.is_ms_shipped = 0;

IF @ColumnCount <> 34
BEGIN
    DECLARE @ErrColMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 1 FAILED: Expected exactly 34 columns across user tables, but found %d.', @ColumnCount);
    THROW 52001, @ErrColMsg, 1;
END;

PRINT '    [PASS] Exactly 7 user tables verified in dbo schema.';
PRINT '    [PASS] Exactly 34 columns verified across all user tables.';
PRINT '>> [PASS] BLOCK 1: Schema Table & Column Audit passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 2: CONSTRAINT INTEGRITY & TRUST AUDIT
-- Requirements:
--   * Exactly 7 Primary Keys (PKs).
--   * Exactly 8 Foreign Keys (FKs).
--   * Exactly 4 CHECK constraints (CKs).
--   * Exactly 5 Candidate Key UNIQUE constraints (UQs).
--   * 0 disabled or untrusted constraints (is_disabled = 0, is_not_trusted = 0).
--   * Throws error >= 52002 on failure.
-- =============================================================================
PRINT '>>> Starting BLOCK 2: Constraint Integrity & Trust Audit...';

DECLARE @PKCount INT;
SELECT @PKCount = COUNT(*) 
FROM sys.key_constraints 
WHERE [type] = 'PK' AND schema_id = SCHEMA_ID('dbo');

IF @PKCount <> 7
BEGIN
    DECLARE @ErrPKMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 2 FAILED: Expected exactly 7 Primary Keys, but found %d.', @PKCount);
    THROW 52002, @ErrPKMsg, 1;
END;

DECLARE @FKCount INT;
SELECT @FKCount = COUNT(*) 
FROM sys.foreign_keys 
WHERE schema_id = SCHEMA_ID('dbo');

IF @FKCount <> 8
BEGIN
    DECLARE @ErrFKMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 2 FAILED: Expected exactly 8 Foreign Keys, but found %d.', @FKCount);
    THROW 52003, @ErrFKMsg, 1;
END;

DECLARE @CKCount INT;
SELECT @CKCount = COUNT(*) 
FROM sys.check_constraints 
WHERE schema_id = SCHEMA_ID('dbo');

IF @CKCount <> 4
BEGIN
    DECLARE @ErrCKMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 2 FAILED: Expected exactly 4 CHECK constraints, but found %d.', @CKCount);
    THROW 52004, @ErrCKMsg, 1;
END;

DECLARE @UQCount INT;
SELECT @UQCount = COUNT(*) 
FROM sys.key_constraints 
WHERE [type] = 'UQ' AND schema_id = SCHEMA_ID('dbo');

IF @UQCount <> 5
BEGIN
    DECLARE @ErrUQMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 2 FAILED: Expected exactly 5 UNIQUE constraints, but found %d.', @UQCount);
    THROW 52005, @ErrUQMsg, 1;
END;

-- Check for any disabled or untrusted Foreign Keys
IF EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE schema_id = SCHEMA_ID('dbo') AND (is_disabled = 1 OR is_not_trusted = 1)
)
BEGIN
    THROW 52006, 'BLOCK 2 FAILED: One or more Foreign Key constraints are disabled or untrusted.', 1;
END;

-- Check for any disabled or untrusted CHECK constraints
IF EXISTS (
    SELECT 1 
    FROM sys.check_constraints 
    WHERE schema_id = SCHEMA_ID('dbo') AND (is_disabled = 1 OR is_not_trusted = 1)
)
BEGIN
    THROW 52007, 'BLOCK 2 FAILED: One or more CHECK constraints are disabled or untrusted.', 1;
END;

PRINT '    [PASS] Constraint counts verified: 7 PKs, 8 FKs, 4 CKs, 5 UQs.';
PRINT '    [PASS] Trust audit verified: 0 disabled or untrusted constraints.';
PRINT '>> [PASS] BLOCK 2: Constraint Integrity & Trust Audit passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 3: ROW COUNT THRESHOLD VERIFICATION
-- Requirements:
--   * Pokemon >= 50 rows.
--   * Region >= 10 rows.
--   * Location >= 10 rows.
--   * Trainer >= 10 rows.
--   * WildEncounter >= 10 rows.
--   * OwnedPokemon >= 10 rows.
--   * PersonalPokedex >= 10 rows.
--   * Throws error >= 52010 on failure.
-- =============================================================================
PRINT '>>> Starting BLOCK 3: Row Count Threshold Verification...';

DECLARE @CountPokemon INT = (SELECT COUNT(*) FROM dbo.Pokemon);
IF @CountPokemon < 50
    THROW 52010, 'BLOCK 3 FAILED: Table dbo.Pokemon has fewer than 50 rows.', 1;

DECLARE @CountRegion INT = (SELECT COUNT(*) FROM dbo.Region);
IF @CountRegion < 10
    THROW 52011, 'BLOCK 3 FAILED: Table dbo.Region has fewer than 10 rows.', 1;

DECLARE @CountLocation INT = (SELECT COUNT(*) FROM dbo.Location);
IF @CountLocation < 10
    THROW 52012, 'BLOCK 3 FAILED: Table dbo.Location has fewer than 10 rows.', 1;

DECLARE @CountTrainer INT = (SELECT COUNT(*) FROM dbo.Trainer);
IF @CountTrainer < 10
    THROW 52013, 'BLOCK 3 FAILED: Table dbo.Trainer has fewer than 10 rows.', 1;

DECLARE @CountWildEncounter INT = (SELECT COUNT(*) FROM dbo.WildEncounter);
IF @CountWildEncounter < 10
    THROW 52014, 'BLOCK 3 FAILED: Table dbo.WildEncounter has fewer than 10 rows.', 1;

DECLARE @CountOwnedPokemon INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
IF @CountOwnedPokemon < 10
    THROW 52015, 'BLOCK 3 FAILED: Table dbo.OwnedPokemon has fewer than 10 rows.', 1;

DECLARE @CountPersonalPokedex INT = (SELECT COUNT(*) FROM dbo.PersonalPokedex);
IF @CountPersonalPokedex < 10
    THROW 52016, 'BLOCK 3 FAILED: Table dbo.PersonalPokedex has fewer than 10 rows.', 1;

PRINT '    [PASS] Pokemon rows: ' + CAST(@CountPokemon AS VARCHAR(10)) + ' (>= 50)';
PRINT '    [PASS] Region rows: ' + CAST(@CountRegion AS VARCHAR(10)) + ' (>= 10)';
PRINT '    [PASS] Location rows: ' + CAST(@CountLocation AS VARCHAR(10)) + ' (>= 10)';
PRINT '    [PASS] Trainer rows: ' + CAST(@CountTrainer AS VARCHAR(10)) + ' (>= 10)';
PRINT '    [PASS] WildEncounter rows: ' + CAST(@CountWildEncounter AS VARCHAR(10)) + ' (>= 10)';
PRINT '    [PASS] OwnedPokemon rows: ' + CAST(@CountOwnedPokemon AS VARCHAR(10)) + ' (>= 10)';
PRINT '    [PASS] PersonalPokedex rows: ' + CAST(@CountPersonalPokedex AS VARCHAR(10)) + ' (>= 10)';
PRINT '>> [PASS] BLOCK 3: Row Count Threshold Verification passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 4: NEGATIVE CONSTRAINT & TRIGGER TESTING
-- Requirements:
--   * Negative trigger test: attempt inserting OwnedPokemon with Level = 105;
--     verify transaction rolls back and error 50050 is thrown (temporarily
--     disabling CK_OwnedPokemon_Level inside test block and restoring with
--     WITH CHECK CHECK CONSTRAINT).
--   * Negative trigger test: attempt inserting OwnedPokemon with Level = 0;
--     verify rollback and error 50050.
--   * Negative CHECK test: attempt inserting Pokemon with BaseHP = 0;
--     verify error 547.
--   * Negative UNIQUE test: attempt duplicate Pokemon NationalDexNumber;
--     verify error 2627.
-- =============================================================================
PRINT '>>> Starting BLOCK 4: Negative Constraint & Trigger Testing...';

-- 4.1 Negative Trigger Test: Level = 105
DECLARE @InitialOwnedCount4_1 INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
DECLARE @CaughtErr105 INT = 0;

ALTER TABLE dbo.OwnedPokemon NOCHECK CONSTRAINT CK_OwnedPokemon_Level;
BEGIN TRY
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level]) VALUES (1, 1, 105);
END TRY
BEGIN CATCH
    SET @CaughtErr105 = ERROR_NUMBER();
END CATCH;
ALTER TABLE dbo.OwnedPokemon WITH CHECK CHECK CONSTRAINT CK_OwnedPokemon_Level;

IF @CaughtErr105 <> 50050
BEGIN
    DECLARE @Err105Msg NVARCHAR(200) = FORMATMESSAGE('BLOCK 4 FAILED: Level = 105 trigger test raised error %d (expected 50050).', @CaughtErr105);
    THROW 52020, @Err105Msg, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @InitialOwnedCount4_1
    THROW 52021, 'BLOCK 4 FAILED: Level = 105 row was inserted despite trigger violation.', 1;

PRINT '    [PASS] 4.1 Negative Trigger Test (Level = 105): Caught error 50050 & rolled back cleanly.';

-- 4.2 Negative Trigger Test: Level = 0
DECLARE @InitialOwnedCount4_2 INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
DECLARE @CaughtErr0 INT = 0;

ALTER TABLE dbo.OwnedPokemon NOCHECK CONSTRAINT CK_OwnedPokemon_Level;
BEGIN TRY
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level]) VALUES (1, 1, 0);
END TRY
BEGIN CATCH
    SET @CaughtErr0 = ERROR_NUMBER();
END CATCH;
ALTER TABLE dbo.OwnedPokemon WITH CHECK CHECK CONSTRAINT CK_OwnedPokemon_Level;

IF @CaughtErr0 <> 50050
BEGIN
    DECLARE @Err0Msg NVARCHAR(200) = FORMATMESSAGE('BLOCK 4 FAILED: Level = 0 trigger test raised error %d (expected 50050).', @CaughtErr0);
    THROW 52022, @Err0Msg, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @InitialOwnedCount4_2
    THROW 52023, 'BLOCK 4 FAILED: Level = 0 row was inserted despite trigger violation.', 1;

PRINT '    [PASS] 4.2 Negative Trigger Test (Level = 0): Caught error 50050 & rolled back cleanly.';

-- 4.3 Negative CHECK Test: BaseHP = 0
DECLARE @InitialPokemonCount4_3 INT = (SELECT COUNT(*) FROM dbo.Pokemon);
DECLARE @CaughtErrBaseHP INT = 0;

BEGIN TRY
    INSERT INTO dbo.Pokemon (NationalDexNumber, Name, PrimaryType, BaseHP, BaseAttack, BaseDefense)
    VALUES (9999, N'ZeroHP_TestMon', 'Normal', 0, 50, 50);
END TRY
BEGIN CATCH
    SET @CaughtErrBaseHP = ERROR_NUMBER();
END CATCH;

IF @CaughtErrBaseHP <> 547
BEGIN
    DECLARE @ErrBaseHPMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 4 FAILED: BaseHP = 0 CHECK test raised error %d (expected 547).', @CaughtErrBaseHP);
    THROW 52024, @ErrBaseHPMsg, 1;
END;

IF (SELECT COUNT(*) FROM dbo.Pokemon) <> @InitialPokemonCount4_3
    THROW 52025, 'BLOCK 4 FAILED: Pokemon with BaseHP = 0 was inserted despite CHECK constraint.', 1;

PRINT '    [PASS] 4.3 Negative CHECK Test (BaseHP = 0): Caught error 547 & blocked insert.';

-- 4.4 Negative UNIQUE Test: Duplicate NationalDexNumber
DECLARE @InitialPokemonCount4_4 INT = (SELECT COUNT(*) FROM dbo.Pokemon);
DECLARE @CaughtErrUnique INT = 0;

BEGIN TRY
    -- NationalDexNumber 1 already exists (Bulbasaur)
    INSERT INTO dbo.Pokemon (NationalDexNumber, Name, PrimaryType, BaseHP, BaseAttack, BaseDefense)
    VALUES (1, N'DuplicateBulba_Test', 'Grass', 45, 49, 49);
END TRY
BEGIN CATCH
    SET @CaughtErrUnique = ERROR_NUMBER();
END CATCH;

IF @CaughtErrUnique <> 2627
BEGIN
    DECLARE @ErrUniqueMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 4 FAILED: Duplicate NationalDexNumber UNIQUE test raised error %d (expected 2627).', @CaughtErrUnique);
    THROW 52026, @ErrUniqueMsg, 1;
END;

IF (SELECT COUNT(*) FROM dbo.Pokemon) <> @InitialPokemonCount4_4
    THROW 52027, 'BLOCK 4 FAILED: Duplicate NationalDexNumber was inserted despite UNIQUE constraint.', 1;

PRINT '    [PASS] 4.4 Negative UNIQUE Test (Duplicate Dex #1): Caught error 2627 & blocked insert.';
PRINT '>> [PASS] BLOCK 4: Negative Constraint & Trigger Testing passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 5: PROGRAMMABILITY FUNCTIONAL ASSERTIONS
-- Requirements:
--   * Function test: dbo.fn_GetPokemonTotalStats(1) returns 143.
--   * Views test:
--       SELECT COUNT(*) FROM dbo.vw_TrainerParty returns > 0;
--       SELECT COUNT(*) FROM dbo.vw_PokedexProgress returns > 0.
--   * Queries test: Execute all 10 queries from queries.sql inside a validation
--     block to confirm non-empty result sets without syntax or runtime error.
--   * Stored procedure catch test: execute dbo.usp_CatchPokemon inside a transaction,
--     confirm valid returned ID and PersonalPokedex.IsCaught = 1, then ROLLBACK TRAN.
-- =============================================================================
PRINT '>>> Starting BLOCK 5: Programmability Functional Assertions...';

-- 5.1 Scalar Function Test: fn_GetPokemonTotalStats
DECLARE @BulbaStats INT = dbo.fn_GetPokemonTotalStats(1);
IF @BulbaStats <> 143
BEGIN
    DECLARE @ErrFnMsg NVARCHAR(200) = FORMATMESSAGE('BLOCK 5 FAILED: fn_GetPokemonTotalStats(1) returned %d (expected 143: 45+49+49).', @BulbaStats);
    THROW 52030, @ErrFnMsg, 1;
END;

IF dbo.fn_GetPokemonTotalStats(99999) <> 0
    THROW 52031, 'BLOCK 5 FAILED: fn_GetPokemonTotalStats for non-existent ID did not return 0.', 1;

PRINT '    [PASS] 5.1 Function fn_GetPokemonTotalStats: Bulbasaur base stats total = 143 (exact match).';

-- 5.2 Views Row Count Test
DECLARE @ViewPartyCount INT;
DECLARE @ViewProgressCount INT;

SELECT @ViewPartyCount = COUNT(*) FROM dbo.vw_TrainerParty;
IF @ViewPartyCount <= 0
    THROW 52032, 'BLOCK 5 FAILED: View vw_TrainerParty returned 0 rows.', 1;

SELECT @ViewProgressCount = COUNT(*) FROM dbo.vw_PokedexProgress;
IF @ViewProgressCount <= 0
    THROW 52033, 'BLOCK 5 FAILED: View vw_PokedexProgress returned 0 rows.', 1;

PRINT '    [PASS] 5.2 Views non-empty: vw_TrainerParty (' + CAST(@ViewPartyCount AS VARCHAR(10)) + ' rows), vw_PokedexProgress (' + CAST(@ViewProgressCount AS VARCHAR(10)) + ' rows).';

-- 5.3 Queries Test: Execute all 10 queries from queries.sql
DECLARE @Q1Count INT, @Q2Count INT, @Q3Count INT, @Q4Count INT, @Q5Count INT;
DECLARE @Q6Count INT, @Q7Count INT, @Q8Count INT, @Q9Count INT, @Q10Count INT;

-- Query 1: INNER JOIN Wild Encounters
SELECT @Q1Count = COUNT(*) 
FROM dbo.WildEncounter we
INNER JOIN dbo.Location l ON we.LocationID = l.LocationID
INNER JOIN dbo.Region r ON l.RegionID = r.RegionID
INNER JOIN dbo.Pokemon p ON we.PokemonID = p.PokemonID;

-- Query 2: INNER JOIN Active Party Lineup
SELECT @Q2Count = COUNT(*) 
FROM dbo.OwnedPokemon op
INNER JOIN dbo.Trainer t ON op.TrainerID = t.TrainerID
INNER JOIN dbo.Pokemon p ON op.PokemonID = p.PokemonID
WHERE op.PartySlot IS NOT NULL;

-- Query 3: OUTER JOIN Location Encounters
SELECT @Q3Count = COUNT(*) 
FROM (
    SELECT l.LocationID
    FROM dbo.Location l
    INNER JOIN dbo.Region r ON l.RegionID = r.RegionID
    LEFT OUTER JOIN dbo.WildEncounter we ON l.LocationID = we.LocationID
    GROUP BY l.LocationID, l.Name, l.LocationType, r.Name
) q3;

-- Query 4: OUTER JOIN Species Capture Count
SELECT @Q4Count = COUNT(*) 
FROM (
    SELECT p.PokemonID
    FROM dbo.Pokemon p
    LEFT OUTER JOIN dbo.OwnedPokemon op ON p.PokemonID = op.PokemonID
    GROUP BY p.PokemonID, p.NationalDexNumber, p.Name, p.PrimaryType, p.SecondaryType
) q4;

-- Query 5: Subquery WHERE Elite Trainers
SELECT @Q5Count = COUNT(*) 
FROM dbo.Trainer t
INNER JOIN dbo.Location l ON t.LocationID = l.LocationID
WHERE t.TrainerID IN (
    SELECT DISTINCT op.TrainerID 
    FROM dbo.OwnedPokemon op
    WHERE op.[Level] >= (SELECT AVG(CAST([Level] AS FLOAT)) FROM dbo.OwnedPokemon)
);

-- Query 6: Subquery WHERE Above Average Stats
SELECT @Q6Count = COUNT(*) 
FROM dbo.Pokemon p
WHERE (p.BaseHP + p.BaseAttack + p.BaseDefense) > (
    SELECT AVG(CAST(BaseHP + BaseAttack + BaseDefense AS FLOAT)) 
    FROM dbo.Pokemon
);

-- Query 7: Subquery FROM Trainer Level Ranking
SELECT @Q7Count = COUNT(*) 
FROM (
    SELECT tRank.TrainerID 
    FROM (
        SELECT t.TrainerID, COUNT(op.OwnedPokemonID) AS TotalOwned, MAX(op.[Level]) AS MaxLevel
        FROM dbo.Trainer t 
        INNER JOIN dbo.OwnedPokemon op ON t.TrainerID = op.TrainerID
        GROUP BY t.TrainerID, t.Username
    ) AS tRank 
    WHERE tRank.MaxLevel >= 25
) q7;

-- Query 8: Subquery FROM Regional Wild Level Summary
SELECT @Q8Count = COUNT(*) 
FROM (
    SELECT locSummary.LocationID 
    FROM (
        SELECT we.LocationID, l.RegionID,
               CAST(ROUND(AVG(CAST((we.MinLevel + we.MaxLevel) / 2.0 AS DECIMAL(5,2))), 2) AS DECIMAL(5,2)) AS AvgWildLevel
        FROM dbo.WildEncounter we 
        INNER JOIN dbo.Location l ON we.LocationID = l.LocationID
        GROUP BY we.LocationID, l.Name, l.RegionID
    ) AS locSummary 
    INNER JOIN dbo.Region r ON locSummary.RegionID = r.RegionID
    WHERE locSummary.AvgWildLevel >= 5.0
) q8;

-- Query 9: GROUP BY Primary Type Stats with HAVING
SELECT @Q9Count = COUNT(*) 
FROM (
    SELECT p.PrimaryType 
    FROM dbo.Pokemon p 
    GROUP BY p.PrimaryType 
    HAVING COUNT(*) >= 2
) q9;

-- Query 10: GROUP BY Trainer Collection Progress with HAVING
SELECT @Q10Count = COUNT(*) 
FROM (
    SELECT t.TrainerID 
    FROM dbo.Trainer t 
    INNER JOIN dbo.PersonalPokedex pp ON t.TrainerID = pp.TrainerID
    GROUP BY t.TrainerID, t.Username 
    HAVING COUNT(pp.PokemonID) >= 2
) q10;

IF @Q1Count <= 0 THROW 52034, 'BLOCK 5 FAILED: Query 1 (INNER JOIN) returned 0 rows.', 1;
IF @Q2Count <= 0 THROW 52035, 'BLOCK 5 FAILED: Query 2 (INNER JOIN) returned 0 rows.', 1;
IF @Q3Count <= 0 THROW 52036, 'BLOCK 5 FAILED: Query 3 (OUTER JOIN) returned 0 rows.', 1;
IF @Q4Count <= 0 THROW 52037, 'BLOCK 5 FAILED: Query 4 (OUTER JOIN) returned 0 rows.', 1;
IF @Q5Count <= 0 THROW 52038, 'BLOCK 5 FAILED: Query 5 (Subquery WHERE) returned 0 rows.', 1;
IF @Q6Count <= 0 THROW 52039, 'BLOCK 5 FAILED: Query 6 (Subquery WHERE) returned 0 rows.', 1;
IF @Q7Count <= 0 THROW 52040, 'BLOCK 5 FAILED: Query 7 (Subquery FROM) returned 0 rows.', 1;
IF @Q8Count <= 0 THROW 52041, 'BLOCK 5 FAILED: Query 8 (Subquery FROM) returned 0 rows.', 1;
IF @Q9Count <= 0 THROW 52042, 'BLOCK 5 FAILED: Query 9 (GROUP BY HAVING) returned 0 rows.', 1;
IF @Q10Count <= 0 THROW 52043, 'BLOCK 5 FAILED: Query 10 (GROUP BY HAVING) returned 0 rows.', 1;

PRINT '    [PASS] 5.3 All 10 queries executed cleanly with non-empty results:';
PRINT '           Q1=' + CAST(@Q1Count AS VARCHAR(5)) + ' rows, Q2=' + CAST(@Q2Count AS VARCHAR(5)) + 
      ' rows, Q3=' + CAST(@Q3Count AS VARCHAR(5)) + ' rows, Q4=' + CAST(@Q4Count AS VARCHAR(5)) + 
      ' rows, Q5=' + CAST(@Q5Count AS VARCHAR(5)) + ' rows,';
PRINT '           Q6=' + CAST(@Q6Count AS VARCHAR(5)) + ' rows, Q7=' + CAST(@Q7Count AS VARCHAR(5)) + 
      ' rows, Q8=' + CAST(@Q8Count AS VARCHAR(5)) + ' rows, Q9=' + CAST(@Q9Count AS VARCHAR(5)) + 
      ' rows, Q10=' + CAST(@Q10Count AS VARCHAR(5)) + ' rows.';

-- 5.4 Stored Procedure Test: usp_CatchPokemon inside isolated rollback transaction
DECLARE @CatchOutputNewID INT;
DECLARE @ProcOutputTable TABLE (ReturnedID INT);

BEGIN TRAN;

INSERT INTO @ProcOutputTable
EXEC dbo.usp_CatchPokemon 
    @TrainerID = 1, 
    @PokemonID = 1, 
    @LocationID = 1, 
    @Level = 5, 
    @Nickname = N'AuditTestBulba',
    @NewOwnedPokemonID = @CatchOutputNewID OUTPUT;

SELECT @CatchOutputNewID = ReturnedID FROM @ProcOutputTable;

IF @CatchOutputNewID IS NULL OR @CatchOutputNewID <= 0
BEGIN
    ROLLBACK TRAN;
    THROW 52044, 'BLOCK 5 FAILED: usp_CatchPokemon failed to return a valid OwnedPokemonID.', 1;
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.PersonalPokedex 
    WHERE TrainerID = 1 AND PokemonID = 1 AND IsCaught = 1
)
BEGIN
    ROLLBACK TRAN;
    THROW 52045, 'BLOCK 5 FAILED: usp_CatchPokemon failed to synchronize PersonalPokedex (IsCaught = 1).', 1;
END;

ROLLBACK TRAN;

PRINT '    [PASS] 5.4 Stored Procedure usp_CatchPokemon: Captured ID generated and PersonalPokedex synced (cleanly rolled back).';
PRINT '>> [PASS] BLOCK 5: Programmability Functional Assertions passed successfully.';
PRINT '';

-- =============================================================================
-- FINAL SUCCESS BANNER
-- =============================================================================
PRINT '==================================================';
PRINT '  ALL POKEMON WORLD VERIFICATION TESTS PASSED!    ';
PRINT '==================================================';
GO
