/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       createDB.sql
   Purpose:    Recreates database 'pokemon_world' and creates the 7 core tables
               with Primary Keys and Identity properties only (34 columns total).
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

-- 1. DATABASE CREATION & CONTEXT INITIALIZATION
USE master;
GO

IF DB_ID(N'pokemon_world') IS NOT NULL
BEGIN
    ALTER DATABASE pokemon_world SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE pokemon_world;
END
GO

CREATE DATABASE pokemon_world COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- 2. CORE TABLE DEFINITIONS (PRIMARY KEYS & IDENTITY ONLY - 34 COLUMNS)
-- =============================================================================

-- Table 1: Region (3 columns)
CREATE TABLE dbo.Region (
    RegionID     INT IDENTITY(1,1) NOT NULL,
    Name         NVARCHAR(50) NOT NULL,
    Description  NVARCHAR(255) NULL,
    CONSTRAINT PK_Region PRIMARY KEY (RegionID)
);
GO

-- Table 2: Location (4 columns)
CREATE TABLE dbo.Location (
    LocationID    INT IDENTITY(1,1) NOT NULL,
    RegionID      INT NOT NULL,
    Name          NVARCHAR(100) NOT NULL,
    LocationType  VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Location PRIMARY KEY (LocationID)
);
GO

-- Table 3: Pokemon (8 columns)
CREATE TABLE dbo.Pokemon (
    PokemonID          INT IDENTITY(1,1) NOT NULL,
    NationalDexNumber  INT NOT NULL,
    Name               NVARCHAR(50) NOT NULL,
    PrimaryType        VARCHAR(20) NOT NULL,
    SecondaryType      VARCHAR(20) NULL,
    BaseHP             INT NOT NULL,
    BaseAttack         INT NOT NULL,
    BaseDefense        INT NOT NULL,
    CONSTRAINT PK_Pokemon PRIMARY KEY (PokemonID)
);
GO

-- Table 4: Trainer (4 columns)
CREATE TABLE dbo.Trainer (
    TrainerID    INT IDENTITY(1,1) NOT NULL,
    Username     NVARCHAR(50) NOT NULL,
    Email        VARCHAR(100) NOT NULL,
    LocationID   INT NOT NULL,
    CONSTRAINT PK_Trainer PRIMARY KEY (TrainerID)
);
GO

-- Table 5: WildEncounter (5 columns)
CREATE TABLE dbo.WildEncounter (
    EncounterID    INT IDENTITY(1,1) NOT NULL,
    LocationID     INT NOT NULL,
    PokemonID      INT NOT NULL,
    MinLevel       INT NOT NULL,
    MaxLevel       INT NOT NULL,
    CONSTRAINT PK_WildEncounter PRIMARY KEY (EncounterID)
);
GO

-- Table 6: OwnedPokemon (6 columns)
CREATE TABLE dbo.OwnedPokemon (
    OwnedPokemonID    INT IDENTITY(1,1) NOT NULL,
    TrainerID         INT NOT NULL,
    PokemonID         INT NOT NULL,
    Nickname          NVARCHAR(50) NULL,
    [Level]           INT NOT NULL CONSTRAINT DF_OwnedPokemon_Level DEFAULT 5,
    PartySlot         INT NULL,
    CONSTRAINT PK_OwnedPokemon PRIMARY KEY (OwnedPokemonID)
);
GO

-- Table 7: PersonalPokedex (4 columns)
CREATE TABLE dbo.PersonalPokedex (
    TrainerID      INT NOT NULL,
    PokemonID      INT NOT NULL,
    FirstSeenAt    DATETIME NOT NULL CONSTRAINT DF_PersonalPokedex_Seen DEFAULT GETDATE(),
    IsCaught       BIT NOT NULL CONSTRAINT DF_PersonalPokedex_Caught DEFAULT 0,
    CONSTRAINT PK_PersonalPokedex PRIMARY KEY (TrainerID, PokemonID)
);
GO
