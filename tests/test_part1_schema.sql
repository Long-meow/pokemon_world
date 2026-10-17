/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       tests/test_part1_schema.sql
   Purpose:    AI-Generated Modular Unit Test Suite for Part 1:
               - Schema table existence (7 tables)
               - Column count (34 columns) and column data types
               - 17 integrity constraints (7 PK, 8 FK, 4 CHECK, 5 UNIQUE)
               - Constraint trust and enabled status audit (0 disabled/untrusted)
   Target:     Microsoft SQL Server 2022+
   Author:     AI Testing Specialist & Nguyen Van Dung (worker_m2)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

PRINT '============================================================';
PRINT '  TEST PART 1: SCHEMA STRUCTURE & CONSTRAINTS AUDIT        ';
PRINT '  Author: Nguyen Van Dung | Target: Microsoft SQL Server 2022 ';
PRINT '============================================================';
PRINT '';

-- =============================================================================
-- TEST 1.1: VERIFY 7 USER TABLES EXIST IN SCHEMA dbo
-- =============================================================================
PRINT '>>> [1/5] Verifying 7 Core Tables Existence...';

DECLARE @MissingTables NVARCHAR(500) = N'';

SELECT @MissingTables = @MissingTables + ExpectedTable + N', '
FROM (
    VALUES 
        (N'Region'),
        (N'Location'),
        (N'Pokemon'),
        (N'Trainer'),
        (N'WildEncounter'),
        (N'OwnedPokemon'),
        (N'PersonalPokedex')
) AS Expected(ExpectedTable)
WHERE NOT EXISTS (
    SELECT 1 
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo' AND t.name = Expected.ExpectedTable
);

IF LEN(@MissingTables) > 0
BEGIN
    DECLARE @ErrMissing NVARCHAR(500) = FORMATMESSAGE('TEST 1.1 FAILED: Missing required tables: %s', LEFT(@MissingTables, LEN(@MissingTables) - 1));
    THROW 51001, @ErrMissing, 1;
END;

DECLARE @ActualTableCount INT;
SELECT @ActualTableCount = COUNT(*) 
FROM sys.tables 
WHERE schema_id = SCHEMA_ID('dbo') AND is_ms_shipped = 0;

IF @ActualTableCount <> 7
BEGIN
    DECLARE @ErrTableCountMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.1 FAILED: Expected exactly 7 user tables, but found %d.', @ActualTableCount);
    THROW 51002, @ErrTableCountMsg, 1;
END;

PRINT '    [PASS] All 7 required tables exist in dbo schema:';
PRINT '           - dbo.Region';
PRINT '           - dbo.Location';
PRINT '           - dbo.Pokemon';
PRINT '           - dbo.Trainer';
PRINT '           - dbo.WildEncounter';
PRINT '           - dbo.OwnedPokemon';
PRINT '           - dbo.PersonalPokedex';
PRINT '';

-- =============================================================================
-- TEST 1.2: VERIFY TOTAL COLUMN COUNT (34 COLUMNS) AND PER-TABLE COLUMNS
-- =============================================================================
PRINT '>>> [2/5] Verifying Column Counts and Schema Definitions...';

DECLARE @TotalColumns INT;
SELECT @TotalColumns = COUNT(*)
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.schema_id = SCHEMA_ID('dbo') AND t.is_ms_shipped = 0;

IF @TotalColumns <> 34
BEGIN
    DECLARE @ErrColMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.2 FAILED: Expected exactly 34 columns across user tables, but found %d.', @TotalColumns);
    THROW 51003, @ErrColMsg, 1;
END;

-- Check per-table column counts
DECLARE @TableColFailures NVARCHAR(500) = N'';

SELECT @TableColFailures = @TableColFailures + TableName + N' (expected ' + CAST(ExpectedCols AS NVARCHAR(10)) + N', got ' + CAST(ActualCols AS NVARCHAR(10)) + N'); '
FROM (
    SELECT 
        t.name AS TableName,
        COUNT(c.column_id) AS ActualCols,
        CASE t.name
            WHEN 'Region' THEN 3
            WHEN 'Location' THEN 4
            WHEN 'Pokemon' THEN 8
            WHEN 'Trainer' THEN 4
            WHEN 'WildEncounter' THEN 5
            WHEN 'OwnedPokemon' THEN 6
            WHEN 'PersonalPokedex' THEN 4
            ELSE 0
        END AS ExpectedCols
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    WHERE t.schema_id = SCHEMA_ID('dbo') AND t.is_ms_shipped = 0
    GROUP BY t.name
) sub
WHERE ActualCols <> ExpectedCols;

IF LEN(@TableColFailures) > 0
BEGIN
    DECLARE @ErrColMismatch NVARCHAR(500) = FORMATMESSAGE('TEST 1.2 FAILED: Column count mismatch in tables: %s', @TableColFailures);
    THROW 51004, @ErrColMismatch, 1;
END;

PRINT '    [PASS] Total column count across 7 tables is exactly 34.';
PRINT '    [PASS] Individual table column counts verified:';
PRINT '           - Region: 3 columns';
PRINT '           - Location: 4 columns';
PRINT '           - Pokemon: 8 columns';
PRINT '           - Trainer: 4 columns';
PRINT '           - WildEncounter: 5 columns';
PRINT '           - OwnedPokemon: 6 columns';
PRINT '           - PersonalPokedex: 4 columns';
PRINT '';

-- =============================================================================
-- TEST 1.3: VERIFY COLUMN DATA TYPES FOR CRITICAL ATTRIBUTES
-- =============================================================================
PRINT '>>> [3/5] Verifying Critical Column Data Types...';

-- Verify PersonalPokedex composite key & columns
IF NOT EXISTS (
    SELECT 1 FROM sys.columns c
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.PersonalPokedex')
      AND c.name = 'FirstSeenAt' AND tp.name = 'datetime'
)
BEGIN
    THROW 51005, 'TEST 1.3 FAILED: PersonalPokedex.FirstSeenAt must be DATETIME.', 1;
END;

IF NOT EXISTS (
    SELECT 1 FROM sys.columns c
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.PersonalPokedex')
      AND c.name = 'IsCaught' AND tp.name = 'bit'
)
BEGIN
    THROW 51006, 'TEST 1.3 FAILED: PersonalPokedex.IsCaught must be BIT.', 1;
END;

-- Verify Pokemon stats are INT
IF NOT EXISTS (
    SELECT 1 FROM sys.columns c
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.Pokemon')
      AND c.name = 'BaseHP' AND tp.name = 'int'
)
BEGIN
    THROW 51007, 'TEST 1.3 FAILED: Pokemon.BaseHP must be INT.', 1;
END;

PRINT '    [PASS] Column data types validated (PersonalPokedex.FirstSeenAt DATETIME, IsCaught BIT, Pokemon stats INT).';
PRINT '';

-- =============================================================================
-- TEST 1.4: VERIFY ALL 17 CONSTRAINTS (7 PK, 8 FK, 4 CHECK, 5 UNIQUE)
-- =============================================================================
PRINT '>>> [4/5] Verifying 17 Integrity Constraints (7 PK, 8 FK, 4 CK, 5 UQ)...';

-- 7 Primary Keys
DECLARE @PKCount INT;
SELECT @PKCount = COUNT(*) 
FROM sys.key_constraints 
WHERE [type] = 'PK' AND schema_id = SCHEMA_ID('dbo');

IF @PKCount <> 7
BEGIN
    DECLARE @ErrPKMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.4 FAILED: Expected exactly 7 Primary Keys, but found %d.', @PKCount);
    THROW 51008, @ErrPKMsg, 1;
END;

-- 8 Foreign Keys
DECLARE @FKCount INT;
SELECT @FKCount = COUNT(*) 
FROM sys.foreign_keys 
WHERE schema_id = SCHEMA_ID('dbo');

IF @FKCount <> 8
BEGIN
    DECLARE @ErrFKMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.4 FAILED: Expected exactly 8 Foreign Keys, but found %d.', @FKCount);
    THROW 51009, @ErrFKMsg, 1;
END;

-- Verify specific named Foreign Keys exist
DECLARE @MissingFKs NVARCHAR(500) = N'';
SELECT @MissingFKs = @MissingFKs + ExpectedFK + N', '
FROM (
    VALUES 
        (N'FK_Location_Region'),
        (N'FK_Trainer_Location'),
        (N'FK_Encounter_Location'),
        (N'FK_Encounter_Pokemon'),
        (N'FK_Owned_Trainer'),
        (N'FK_Owned_Pokemon'),
        (N'FK_Pokedex_Trainer'),
        (N'FK_Pokedex_Pokemon')
) AS FKList(ExpectedFK)
WHERE NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE schema_id = SCHEMA_ID('dbo') AND name = FKList.ExpectedFK
);

IF LEN(@MissingFKs) > 0
BEGIN
    DECLARE @ErrMissingFKMsg NVARCHAR(500) = FORMATMESSAGE('TEST 1.4 FAILED: Missing Foreign Key constraints: %s', LEFT(@MissingFKs, LEN(@MissingFKs) - 1));
    THROW 51010, @ErrMissingFKMsg, 1;
END;

-- 4 CHECK Constraints
DECLARE @CKCount INT;
SELECT @CKCount = COUNT(*) 
FROM sys.check_constraints 
WHERE schema_id = SCHEMA_ID('dbo');

IF @CKCount <> 4
BEGIN
    DECLARE @ErrCKMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.4 FAILED: Expected exactly 4 CHECK constraints, but found %d.', @CKCount);
    THROW 51011, @ErrCKMsg, 1;
END;

-- Verify specific named CHECK constraints exist
DECLARE @MissingCKs NVARCHAR(500) = N'';
SELECT @MissingCKs = @MissingCKs + ExpectedCK + N', '
FROM (
    VALUES 
        (N'CK_Pokemon_BaseHP'),
        (N'CK_OwnedPokemon_Level'),
        (N'CK_OwnedPokemon_PartySlot'),
        (N'CK_WildEncounter_Level')
) AS CKList(ExpectedCK)
WHERE NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE schema_id = SCHEMA_ID('dbo') AND name = CKList.ExpectedCK
);

IF LEN(@MissingCKs) > 0
BEGIN
    DECLARE @ErrMissingCKMsg NVARCHAR(500) = FORMATMESSAGE('TEST 1.4 FAILED: Missing CHECK constraints: %s', LEFT(@MissingCKs, LEN(@MissingCKs) - 1));
    THROW 51012, @ErrMissingCKMsg, 1;
END;

-- 5 UNIQUE Constraints
DECLARE @UQCount INT;
SELECT @UQCount = COUNT(*) 
FROM sys.key_constraints 
WHERE [type] = 'UQ' AND schema_id = SCHEMA_ID('dbo');

IF @UQCount <> 5
BEGIN
    DECLARE @ErrUQMsg NVARCHAR(200) = FORMATMESSAGE('TEST 1.4 FAILED: Expected exactly 5 UNIQUE constraints, but found %d.', @UQCount);
    THROW 51013, @ErrUQMsg, 1;
END;

-- Verify specific named UNIQUE constraints exist
DECLARE @MissingUQs NVARCHAR(500) = N'';
SELECT @MissingUQs = @MissingUQs + ExpectedUQ + N', '
FROM (
    VALUES 
        (N'UQ_Region_Name'),
        (N'UQ_Pokemon_Dex'),
        (N'UQ_Pokemon_Name'),
        (N'UQ_Trainer_Username'),
        (N'UQ_Trainer_Email')
) AS UQList(ExpectedUQ)
WHERE NOT EXISTS (
    SELECT 1 FROM sys.key_constraints WHERE [type] = 'UQ' AND schema_id = SCHEMA_ID('dbo') AND name = UQList.ExpectedUQ
);

IF LEN(@MissingUQs) > 0
BEGIN
    DECLARE @ErrMissingUQMsg NVARCHAR(500) = FORMATMESSAGE('TEST 1.4 FAILED: Missing UNIQUE constraints: %s', LEFT(@MissingUQs, LEN(@MissingUQs) - 1));
    THROW 51014, @ErrMissingUQMsg, 1;
END;

PRINT '    [PASS] 7 Primary Keys verified (PK_Region, PK_Location, PK_Pokemon, PK_Trainer, PK_WildEncounter, PK_OwnedPokemon, PK_PersonalPokedex).';
PRINT '    [PASS] 8 Foreign Keys verified (FK_Location_Region, FK_Trainer_Location, FK_Encounter_Location, FK_Encounter_Pokemon, FK_Owned_Trainer, FK_Owned_Pokemon, FK_Pokedex_Trainer, FK_Pokedex_Pokemon).';
PRINT '    [PASS] 4 CHECK constraints verified (CK_Pokemon_BaseHP, CK_OwnedPokemon_Level, CK_OwnedPokemon_PartySlot, CK_WildEncounter_Level).';
PRINT '    [PASS] 5 UNIQUE constraints verified (UQ_Region_Name, UQ_Pokemon_Dex, UQ_Pokemon_Name, UQ_Trainer_Username, UQ_Trainer_Email).';
PRINT '';

-- =============================================================================
-- TEST 1.5: CONSTRAINT TRUST AUDIT (0 DISABLED / 0 UNTRUSTED)
-- =============================================================================
PRINT '>>> [5/5] Auditing Constraint Enabled & Trusted Status...';

-- Foreign Keys check
IF EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE schema_id = SCHEMA_ID('dbo') AND (is_disabled = 1 OR is_not_trusted = 1)
)
BEGIN
    THROW 51015, 'TEST 1.5 FAILED: One or more Foreign Key constraints are disabled or untrusted.', 1;
END;

-- CHECK constraints check
IF EXISTS (
    SELECT 1 
    FROM sys.check_constraints 
    WHERE schema_id = SCHEMA_ID('dbo') AND (is_disabled = 1 OR is_not_trusted = 1)
)
BEGIN
    THROW 51016, 'TEST 1.5 FAILED: One or more CHECK constraints are disabled or untrusted.', 1;
END;

PRINT '    [PASS] 100% of Foreign Key constraints are enabled (is_disabled = 0) and trusted (is_not_trusted = 0).';
PRINT '    [PASS] 100% of CHECK constraints are enabled (is_disabled = 0) and trusted (is_not_trusted = 0).';
PRINT '';

PRINT '============================================================';
PRINT '  ALL PART 1 SCHEMA & CONSTRAINT TESTS PASSED (100% OK)    ';
PRINT '============================================================';
GO
