/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       tests/test_part3_programmability.sql
   Purpose:    AI-Generated Modular Unit Test Suite for Part 3:
               - Block 1: Scalar Function Unit Test (dbo.fn_GetPokemonTotalStats)
               - Block 2: Data Integrity Trigger Negative Testing (dbo.TR_OwnedPokemon_CheckLevel)
               - Block 3: Stored Procedure Transaction ACID & Error Testing (dbo.usp_CatchPokemon)
   Target:     Microsoft SQL Server 2022+
   Author:     AI Testing Specialist & Hoang Phi Long (worker_m4)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

PRINT '============================================================';
PRINT '  TEST PART 3: T-SQL PROGRAMMABILITY AUDIT                 ';
PRINT '  Author: Hoang Phi Long | Target: Microsoft SQL Server 2022 ';
PRINT '============================================================';
PRINT '';

-- =============================================================================
-- BLOCK 1: SCALAR FUNCTION UNIT TESTS (dbo.fn_GetPokemonTotalStats)
-- Requirements:
--   * dbo.fn_GetPokemonTotalStats(1) = 143 (Bulbasaur: 45 HP + 49 Atk + 49 Def)
--   * Non-existent PokemonID (e.g. 99999) returns 0
--   * Additional validation on other known species
-- Error Codes: 53001 - 53005
-- =============================================================================
PRINT '>>> [1/3] Testing Scalar Function dbo.fn_GetPokemonTotalStats...';

-- 1.1 Test Bulbasaur (PokemonID = 1): 45 + 49 + 49 = 143
DECLARE @BulbaStats INT = dbo.fn_GetPokemonTotalStats(1);
IF @BulbaStats <> 143
BEGIN
    DECLARE @ErrBulba NVARCHAR(200) = FORMATMESSAGE('TEST 1.1 FAILED: Bulbasaur total stats returned %d (expected 143: 45+49+49).', @BulbaStats);
    THROW 53001, @ErrBulba, 1;
END;
PRINT '    [PASS] Test 1.1: Bulbasaur (ID 1) total base stats = 143 (exact match).';

-- 1.2 Test Non-existent PokemonID (99999): must return 0
DECLARE @NonExistentStats INT = dbo.fn_GetPokemonTotalStats(99999);
IF @NonExistentStats <> 0
BEGIN
    DECLARE @ErrNonExistent NVARCHAR(200) = FORMATMESSAGE('TEST 1.2 FAILED: Non-existent PokemonID returned %d (expected 0).', @NonExistentStats);
    THROW 53002, @ErrNonExistent, 1;
END;
PRINT '    [PASS] Test 1.2: Non-existent PokemonID (ID 99999) total base stats = 0 (handled gracefully).';

-- 1.3 Test Additional Known Species (Charmander ID 4: 39 + 52 + 43 = 134, Squirtle ID 7: 44 + 48 + 65 = 157)
DECLARE @CharmanderStats INT = dbo.fn_GetPokemonTotalStats(4);
IF @CharmanderStats <> 134
BEGIN
    DECLARE @ErrChar NVARCHAR(200) = FORMATMESSAGE('TEST 1.3 FAILED: Charmander total stats returned %d (expected 134).', @CharmanderStats);
    THROW 53003, @ErrChar, 1;
END;

DECLARE @SquirtleStats INT = dbo.fn_GetPokemonTotalStats(7);
IF @SquirtleStats <> 157
BEGIN
    DECLARE @ErrSquirtle NVARCHAR(200) = FORMATMESSAGE('TEST 1.3 FAILED: Squirtle total stats returned %d (expected 157).', @SquirtleStats);
    THROW 53004, @ErrSquirtle, 1;
END;
PRINT '    [PASS] Test 1.3: Additional species verified (Charmander = 134, Squirtle = 157).';

PRINT '>> [PASS] BLOCK 1: Scalar Function Unit Tests passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 2: NEGATIVE TESTING TRIGGER (dbo.TR_OwnedPokemon_CheckLevel)
-- Requirements:
--   * Attempt INSERT with Level = 105 (violates upper bound 100) -> Catch error 50050.
--   * Verify transaction rollback: row was NOT inserted.
--   * Attempt INSERT with Level = 0 (violates lower bound 1) -> Catch error 50050.
--   * Verify transaction rollback: row was NOT inserted.
--   * Defense-in-depth: Temporarily disable CK_OwnedPokemon_Level during test
--     to verify Trigger layer active logic independently, then restore with WITH CHECK.
-- Error Codes: 53010 - 53015
-- =============================================================================
PRINT '>>> [2/3] Negative Testing Trigger dbo.TR_OwnedPokemon_CheckLevel...';

-- 2.1 Negative Trigger Test: Level = 105 (Upper Bound Violation)
DECLARE @InitialOwnedCount2_1 INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
DECLARE @CaughtErr105 INT = 0;
DECLARE @ErrMsg105 NVARCHAR(4000) = N'';

ALTER TABLE dbo.OwnedPokemon NOCHECK CONSTRAINT CK_OwnedPokemon_Level;
BEGIN TRY
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level]) 
    VALUES (1, 1, 105);
END TRY
BEGIN CATCH
    SET @CaughtErr105 = ERROR_NUMBER();
    SET @ErrMsg105 = ERROR_MESSAGE();
END CATCH;
ALTER TABLE dbo.OwnedPokemon WITH CHECK CHECK CONSTRAINT CK_OwnedPokemon_Level;

IF @CaughtErr105 <> 50050
BEGIN
    DECLARE @Err105Notice NVARCHAR(300) = FORMATMESSAGE('TEST 2.1 FAILED: Level = 105 raised error %d (expected 50050). Msg: %s', @CaughtErr105, @ErrMsg105);
    THROW 53010, @Err105Notice, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @InitialOwnedCount2_1
    THROW 53011, 'TEST 2.1 FAILED: Level = 105 row was persisted despite trigger violation.', 1;

PRINT '    [PASS] Test 2.1: Level = 105 caught custom error 50050 and transaction rolled back completely.';

-- 2.2 Negative Trigger Test: Level = 0 (Lower Bound Violation)
DECLARE @InitialOwnedCount2_2 INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
DECLARE @CaughtErr0 INT = 0;
DECLARE @ErrMsg0 NVARCHAR(4000) = N'';

ALTER TABLE dbo.OwnedPokemon NOCHECK CONSTRAINT CK_OwnedPokemon_Level;
BEGIN TRY
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level]) 
    VALUES (1, 1, 0);
END TRY
BEGIN CATCH
    SET @CaughtErr0 = ERROR_NUMBER();
    SET @ErrMsg0 = ERROR_MESSAGE();
END CATCH;
ALTER TABLE dbo.OwnedPokemon WITH CHECK CHECK CONSTRAINT CK_OwnedPokemon_Level;

IF @CaughtErr0 <> 50050
BEGIN
    DECLARE @Err0Notice NVARCHAR(300) = FORMATMESSAGE('TEST 2.2 FAILED: Level = 0 raised error %d (expected 50050). Msg: %s', @CaughtErr0, @ErrMsg0);
    THROW 53012, @Err0Notice, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @InitialOwnedCount2_2
    THROW 53013, 'TEST 2.2 FAILED: Level = 0 row was persisted despite trigger violation.', 1;

PRINT '    [PASS] Test 2.2: Level = 0 caught custom error 50050 and transaction rolled back completely.';

-- 2.3 Positive Boundary Trigger Test: Valid Levels (Level 1, Level 50, Level 100)
BEGIN TRAN;
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level], Nickname, PartySlot)
    VALUES (1, 1, 1, N'BoundaryMin', NULL);
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level], Nickname, PartySlot)
    VALUES (1, 1, 50, N'BoundaryMid', NULL);
    INSERT INTO dbo.OwnedPokemon (TrainerID, PokemonID, [Level], Nickname, PartySlot)
    VALUES (1, 1, 100, N'BoundaryMax', NULL);
ROLLBACK TRAN;
PRINT '    [PASS] Test 2.3: Valid boundary levels (1, 50, 100) passed trigger inspection cleanly.';

PRINT '>> [PASS] BLOCK 2: Trigger Data Validation Tests passed successfully.';
PRINT '';

-- =============================================================================
-- BLOCK 3: STORED PROCEDURE TRANSACTION ACID & ROLLBACK (dbo.usp_CatchPokemon)
-- Requirements:
--   * Execute usp_CatchPokemon for Trainer 1 catching an uncaught Pokémon
--     (e.g., Squirtle ID 7 at Location 1 with Level 5).
--   * Verify atomic insert in OwnedPokemon and updated PersonalPokedex(IsCaught = 1).
--   * Verify output @NewOwnedPokemonID is populated.
--   * Negative test: Invalid TrainerID (e.g. 99999) raises error 51000 and rolls back.
--   * Negative test: Invalid PokemonID or encounter condition raises error 51001 and rolls back.
-- Error Codes: 53020 - 53026
-- =============================================================================
PRINT '>>> [3/3] Testing Transaction ACID & Rollback for dbo.usp_CatchPokemon...';

-- 3.1 Positive Catch Test inside Isolated Transaction
-- Trainer 1 catches Squirtle (PokemonID = 7) at Location 1 (Level 5)
DECLARE @TestNewOwnedID INT;
DECLARE @ProcOutput TABLE (ReturnedID INT);
DECLARE @InitialOwnedCount3_1 INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);
DECLARE @InitialPokedexCaught3_1 INT = (
    SELECT COUNT(*) 
    FROM dbo.PersonalPokedex 
    WHERE TrainerID = 1 AND PokemonID = 7 AND IsCaught = 1
);

IF @InitialPokedexCaught3_1 > 0
BEGIN
    PRINT '    [INFO] Trainer 1 already has caught record for Squirtle; testing idempotency.';
END;

BEGIN TRAN;

INSERT INTO @ProcOutput
EXEC dbo.usp_CatchPokemon 
    @TrainerID = 1,
    @PokemonID = 7,
    @LocationID = 1,
    @Level = 5,
    @Nickname = N'UnitTestSquirtle',
    @NewOwnedPokemonID = @TestNewOwnedID OUTPUT;

-- Check return value from Result Set
SELECT @TestNewOwnedID = ReturnedID FROM @ProcOutput;

IF @TestNewOwnedID IS NULL OR @TestNewOwnedID <= 0
BEGIN
    ROLLBACK TRAN;
    THROW 53020, 'TEST 3.1 FAILED: usp_CatchPokemon did not return a valid positive NewOwnedPokemonID.', 1;
END;

-- Verify atomic record in dbo.OwnedPokemon
IF NOT EXISTS (
    SELECT 1 
    FROM dbo.OwnedPokemon 
    WHERE OwnedPokemonID = @TestNewOwnedID 
      AND TrainerID = 1 
      AND PokemonID = 7 
      AND [Level] = 5 
      AND Nickname = N'UnitTestSquirtle' 
      AND PartySlot IS NULL
)
BEGIN
    ROLLBACK TRAN;
    THROW 53021, 'TEST 3.1 FAILED: OwnedPokemon row was not inserted atomically with correct values.', 1;
END;

-- Verify synchronization into dbo.PersonalPokedex (IsCaught = 1)
IF NOT EXISTS (
    SELECT 1 
    FROM dbo.PersonalPokedex 
    WHERE TrainerID = 1 
      AND PokemonID = 7 
      AND IsCaught = 1
)
BEGIN
    ROLLBACK TRAN;
    THROW 53022, 'TEST 3.1 FAILED: PersonalPokedex was not synchronized with IsCaught = 1.', 1;
END;

-- Clean rollback to preserve baseline seed data
ROLLBACK TRAN;

-- Confirm database returned to pre-test baseline
IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @InitialOwnedCount3_1
    THROW 53023, 'TEST 3.1 FAILED: Baseline OwnedPokemon count mismatch after transaction rollback.', 1;

PRINT '    [PASS] Test 3.1: Positive catch executed atomically, synced PersonalPokedex, and rolled back cleanly.';

-- 3.2 Negative Test: Invalid TrainerID (99999) -> Expect Error 51000
DECLARE @CaughtErrTrainer INT = 0;
DECLARE @ErrMsgTrainer NVARCHAR(4000) = N'';
DECLARE @OwnedCountBeforeTrainerTest INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);

BEGIN TRY
    EXEC dbo.usp_CatchPokemon 
        @TrainerID = 99999, 
        @PokemonID = 7, 
        @LocationID = 1, 
        @Level = 5, 
        @Nickname = N'InvalidTrainerMon';
END TRY
BEGIN CATCH
    SET @CaughtErrTrainer = ERROR_NUMBER();
    SET @ErrMsgTrainer = ERROR_MESSAGE();
END CATCH;

IF @CaughtErrTrainer <> 51000
BEGIN
    DECLARE @ErrTrainerNotice NVARCHAR(300) = FORMATMESSAGE('TEST 3.2 FAILED: Non-existent TrainerID raised error %d (expected 51000). Msg: %s', @CaughtErrTrainer, @ErrMsgTrainer);
    THROW 53024, @ErrTrainerNotice, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @OwnedCountBeforeTrainerTest
    THROW 53025, 'TEST 3.2 FAILED: Row was inserted despite non-existent TrainerID.', 1;

PRINT '    [PASS] Test 3.2: Invalid TrainerID caught error 51000 and prevented insertion.';

-- 3.3 Negative Test: Invalid Encounter / PokemonID (99999) -> Expect Error 51001
DECLARE @CaughtErrEncounter INT = 0;
DECLARE @ErrMsgEncounter NVARCHAR(4000) = N'';
DECLARE @OwnedCountBeforeEncounterTest INT = (SELECT COUNT(*) FROM dbo.OwnedPokemon);

BEGIN TRY
    EXEC dbo.usp_CatchPokemon 
        @TrainerID = 1, 
        @PokemonID = 99999, 
        @LocationID = 1, 
        @Level = 5, 
        @Nickname = N'InvalidPokemonMon';
END TRY
BEGIN CATCH
    SET @CaughtErrEncounter = ERROR_NUMBER();
    SET @ErrMsgEncounter = ERROR_MESSAGE();
END CATCH;

IF @CaughtErrEncounter <> 51001
BEGIN
    DECLARE @ErrEncounterNotice NVARCHAR(300) = FORMATMESSAGE('TEST 3.3 FAILED: Invalid encounter condition raised error %d (expected 51001). Msg: %s', @CaughtErrEncounter, @ErrMsgEncounter);
    THROW 53026, @ErrEncounterNotice, 1;
END;

IF (SELECT COUNT(*) FROM dbo.OwnedPokemon) <> @OwnedCountBeforeEncounterTest
    THROW 53027, 'TEST 3.3 FAILED: Row was inserted despite invalid encounter condition.', 1;

PRINT '    [PASS] Test 3.3: Invalid encounter/species caught error 51001 and prevented insertion.';

PRINT '>> [PASS] BLOCK 3: Stored Procedure Transaction ACID & Rollback Tests passed successfully.';
PRINT '';

-- =============================================================================
-- FINAL SUCCESS BANNER
-- =============================================================================
PRINT '============================================================';
PRINT '  ALL PART 3 PROGRAMMABILITY TESTS PASSED (100% OK)        ';
PRINT '============================================================';
GO
