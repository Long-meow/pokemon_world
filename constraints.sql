/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       constraints.sql
   Purpose:    Applies all Foreign Keys (8), CHECK constraints (4), and
               Candidate Key UNIQUE constraints (5) to the 7 core tables.
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- 1. FOREIGN KEY CONSTRAINTS (8 KEYS)
-- =============================================================================

-- 1.1 Location -> Region
ALTER TABLE dbo.Location ADD CONSTRAINT FK_Location_Region 
    FOREIGN KEY (RegionID) REFERENCES dbo.Region(RegionID);

-- 1.2 Trainer -> Location (Current Location)
ALTER TABLE dbo.Trainer ADD CONSTRAINT FK_Trainer_Location 
    FOREIGN KEY (LocationID) REFERENCES dbo.Location(LocationID);

-- 1.3 WildEncounter -> Location
ALTER TABLE dbo.WildEncounter ADD CONSTRAINT FK_Encounter_Location 
    FOREIGN KEY (LocationID) REFERENCES dbo.Location(LocationID);

-- 1.4 WildEncounter -> Pokemon
ALTER TABLE dbo.WildEncounter ADD CONSTRAINT FK_Encounter_Pokemon 
    FOREIGN KEY (PokemonID) REFERENCES dbo.Pokemon(PokemonID);

-- 1.5 OwnedPokemon -> Trainer
ALTER TABLE dbo.OwnedPokemon ADD CONSTRAINT FK_Owned_Trainer 
    FOREIGN KEY (TrainerID) REFERENCES dbo.Trainer(TrainerID);

-- 1.6 OwnedPokemon -> Pokemon
ALTER TABLE dbo.OwnedPokemon ADD CONSTRAINT FK_Owned_Pokemon 
    FOREIGN KEY (PokemonID) REFERENCES dbo.Pokemon(PokemonID);

-- 1.7 PersonalPokedex -> Trainer
ALTER TABLE dbo.PersonalPokedex ADD CONSTRAINT FK_Pokedex_Trainer 
    FOREIGN KEY (TrainerID) REFERENCES dbo.Trainer(TrainerID);

-- 1.8 PersonalPokedex -> Pokemon
ALTER TABLE dbo.PersonalPokedex ADD CONSTRAINT FK_Pokedex_Pokemon 
    FOREIGN KEY (PokemonID) REFERENCES dbo.Pokemon(PokemonID);
GO

-- =============================================================================
-- 2. CHECK CONSTRAINTS (4 CHECKS)
-- =============================================================================

-- 2.1 Pokemon: Base HP must be strictly positive
ALTER TABLE dbo.Pokemon ADD CONSTRAINT CK_Pokemon_BaseHP 
    CHECK (BaseHP > 0);

-- 2.2 OwnedPokemon: Level must be between 1 and 100
ALTER TABLE dbo.OwnedPokemon ADD CONSTRAINT CK_OwnedPokemon_Level 
    CHECK ([Level] BETWEEN 1 AND 100);

-- 2.3 OwnedPokemon: PartySlot must be NULL (box storage) or between 1 and 6 (active party)
ALTER TABLE dbo.OwnedPokemon ADD CONSTRAINT CK_OwnedPokemon_PartySlot 
    CHECK (PartySlot IS NULL OR PartySlot BETWEEN 1 AND 6);

-- 2.4 WildEncounter: MinLevel must be positive and <= MaxLevel <= 100
ALTER TABLE dbo.WildEncounter ADD CONSTRAINT CK_WildEncounter_Level 
    CHECK (MinLevel > 0 AND MinLevel <= MaxLevel AND MaxLevel <= 100);
GO

-- =============================================================================
-- 3. UNIQUE CONSTRAINTS (5 CANDIDATE KEYS)
-- =============================================================================

-- 3.1 Region: Region Name is unique
ALTER TABLE dbo.Region ADD CONSTRAINT UQ_Region_Name 
    UNIQUE (Name);

-- 3.2 Pokemon: National Dex Number is unique
ALTER TABLE dbo.Pokemon ADD CONSTRAINT UQ_Pokemon_Dex 
    UNIQUE (NationalDexNumber);

-- 3.3 Pokemon: Species Name is unique
ALTER TABLE dbo.Pokemon ADD CONSTRAINT UQ_Pokemon_Name 
    UNIQUE (Name);

-- 3.4 Trainer: Username is unique
ALTER TABLE dbo.Trainer ADD CONSTRAINT UQ_Trainer_Username 
    UNIQUE (Username);

-- 3.5 Trainer: Email is unique
ALTER TABLE dbo.Trainer ADD CONSTRAINT UQ_Trainer_Email 
    UNIQUE (Email);
GO
