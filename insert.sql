-- ============================================================================
-- POKÉMON WORLD DATABASE - DBI202 ASSIGNMENT 2 
-- Script 03: Seed Data (insert.sql)
-- Architecture: 7-Table Student-Friendly Minimal Relational Model (34 Columns)
-- Description:
--   - Completely clears existing data in reverse FK dependency order.
--   - Populates 10 official Regions.
--   - Populates 12 diverse Locations.
--   - Populates 50 official Gen-1 Pokémon with core stats (HP, Attack, Defense).
--   - Populates 12 active Trainers with current locations.
--   - Populates 40 Wild Encounters across locations and valid level ranges.
--   - Populates 20 Owned Pokémon instances with party slots (1-6) and storage.
--   - Populates 40 Personal Pokédex discovery and catch records.
--   - Strictly manages SET IDENTITY_INSERT ON/OFF per identity table.
-- ============================================================================

USE pokemon_world;
GO

SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ----------------------------------------------------------------------------
-- STEP 1: CLEANUP EXISTING DATA IN REVERSE FOREIGN KEY DEPENDENCY ORDER
-- ----------------------------------------------------------------------------
DELETE FROM dbo.PersonalPokedex;
DELETE FROM dbo.OwnedPokemon;
DELETE FROM dbo.WildEncounter;
DELETE FROM dbo.Trainer;
DELETE FROM dbo.Location;
DELETE FROM dbo.Region;
DELETE FROM dbo.Pokemon;
GO

BEGIN TRAN;

-- ----------------------------------------------------------------------------
-- STEP 2: SEED REGIONS (10 OFFICIAL REGIONS)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.Region ON;

INSERT INTO dbo.Region (RegionID, Name, Description) VALUES
(1, N'Vùng Đồng Bằng Kanto', N'Vùng đất khởi đầu huyền thoại của thế giới Pokémon, nơi giao thoa giữa thiên nhiên trù phú và các đô thị sầm uất.'),
(2, N'Miền Cố Đô Johto', N'Vùng đất cổ kính ngàn năm lưu giữ những câu chuyện thần thoại, đền đài linh thiêng và khu rừng huyền bí.'),
(3, N'Quần Đảo Nhiệt Đới Hoenn', N'Thiên đường nhiệt đới tráng lệ nơi biển cả bao la hòa quyện cùng núi lửa hùng vĩ.'),
(4, N'Vùng Băng Tuyết Sinnoh', N'Vùng đất thần thoại phương Bắc với ngọn núi Coronet sừng sững chia đôi hai bờ đông tây.'),
(5, N'Đô Thị Hiện Đại Unova', N'Miền đất của những tòa cao ốc chọc trời, cầu dây văng tráng lệ và sự hội tụ văn hóa đa sắc tộc.'),
(6, N'Miền Nghệ Thuật Kalos', N'Vùng đất hình ngôi sao nổi tiếng với vẻ đẹp lãng mạn, kiến trúc cổ điển, thời trang và Tháp Lăng Kính.'),
(7, N'Thiên Đường Nhiệt Đới Alola', N'Quần đảo nghỉ dưỡng bốn mùa ngập tràn ánh nắng, biển xanh cát trắng và văn hóa lễ hội độc đáo.'),
(8, N'Xứ Sở Công Nghiệp Galar', N'Vương quốc kết hợp hài hòa giữa làng quê thanh bình và các thành phố động cơ hơi nước công nghiệp hóa.'),
(9, N'Vùng Đất Mở Rộng Paldea', N'Vùng đất rộng lớn không biên giới nổi tiếng với Học viện kho tàng và hiện tượng Terastal kỳ ảo.'),
(10, N'Miền Cổ Xưa Hisui', N'Vùng đất hoang sơ thời kỳ sơ khai của Sinnoh, nơi con người và Pokémon mới bắt đầu học cách cùng chung sống.');

SET IDENTITY_INSERT dbo.Region OFF;

-- ----------------------------------------------------------------------------
-- STEP 3: SEED LOCATIONS (12 DIVERSE LOCATIONS)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.Location ON;

INSERT INTO dbo.Location (LocationID, RegionID, Name, LocationType) VALUES
(1, 1, N'Thị trấn Khởi Nguyên', 'Town'),
(2, 1, N'Rừng Rậm Thường Xanh', 'Forest'),
(3, 1, N'Hang Núi Mặt Trăng', 'Cave'),
(4, 1, N'Đường Mòn Số 1', 'Route'),
(5, 1, N'Vịnh Cảng Sóng Biếc', 'Water'),
(6, 1, N'Tháp Cổ Huyền Bí', 'Landmark'),
(7, 1, N'Thành phố Hoa Đỗ Quyên', 'City'),
(8, 2, N'Rừng Thiêng Cổ Kính', 'Forest'),
(9, 2, N'Tháp Chuông Hoàng Hôn', 'Landmark'),
(10, 2, N'Thành phố Cổ Hoàng Kim', 'City'),
(11, 3, N'Đỉnh Núi Lửa Tro Tàn', 'Landmark'),
(12, 3, N'Bãi Biển Cát Trắng', 'Water');

SET IDENTITY_INSERT dbo.Location OFF;

-- ----------------------------------------------------------------------------
-- STEP 4: SEED POKÉMON (50 OFFICIAL GEN-1 SPECIES WITH CORE STATS)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.Pokemon ON;

INSERT INTO dbo.Pokemon (
    PokemonID, NationalDexNumber, Name, PrimaryType, SecondaryType, 
    BaseHP, BaseAttack, BaseDefense
) VALUES
(1, 1, N'Bulbasaur', 'Grass', 'Poison', 45, 49, 49),
(2, 2, N'Ivysaur', 'Grass', 'Poison', 60, 62, 63),
(3, 3, N'Venusaur', 'Grass', 'Poison', 80, 82, 83),
(4, 4, N'Charmander', 'Fire', NULL, 39, 52, 43),
(5, 5, N'Charmeleon', 'Fire', NULL, 58, 64, 58),
(6, 6, N'Charizard', 'Fire', 'Flying', 78, 84, 78),
(7, 7, N'Squirtle', 'Water', NULL, 44, 48, 65),
(8, 8, N'Wartortle', 'Water', NULL, 59, 63, 80),
(9, 9, N'Blastoise', 'Water', NULL, 79, 83, 100),
(10, 10, N'Caterpie', 'Bug', NULL, 45, 30, 35),
(11, 11, N'Metapod', 'Bug', NULL, 50, 20, 55),
(12, 12, N'Butterfree', 'Bug', 'Flying', 60, 45, 50),
(13, 13, N'Weedle', 'Bug', 'Poison', 40, 35, 30),
(14, 14, N'Kakuna', 'Bug', 'Poison', 45, 25, 50),
(15, 15, N'Beedrill', 'Bug', 'Poison', 65, 90, 40),
(16, 16, N'Pidgey', 'Normal', 'Flying', 40, 45, 40),
(17, 17, N'Pidgeotto', 'Normal', 'Flying', 63, 60, 55),
(18, 18, N'Pidgeot', 'Normal', 'Flying', 83, 80, 75),
(19, 19, N'Rattata', 'Normal', NULL, 30, 56, 35),
(20, 20, N'Raticate', 'Normal', NULL, 55, 81, 60),
(21, 21, N'Spearow', 'Normal', 'Flying', 40, 60, 30),
(22, 22, N'Fearow', 'Normal', 'Flying', 65, 90, 65),
(23, 23, N'Ekans', 'Poison', NULL, 35, 60, 44),
(24, 24, N'Arbok', 'Poison', NULL, 60, 95, 69),
(25, 25, N'Pikachu', 'Electric', NULL, 35, 55, 40),
(26, 26, N'Raichu', 'Electric', NULL, 60, 90, 55),
(27, 27, N'Sandshrew', 'Ground', NULL, 50, 75, 85),
(28, 28, N'Sandslash', 'Ground', NULL, 75, 100, 110),
(29, 29, N'Nidoran F', 'Poison', NULL, 55, 47, 52),
(30, 30, N'Nidorina', 'Poison', NULL, 70, 62, 67),
(31, 31, N'Nidoqueen', 'Poison', 'Ground', 90, 92, 87),
(32, 32, N'Nidoran M', 'Poison', NULL, 46, 57, 40),
(33, 33, N'Nidorino', 'Poison', NULL, 61, 72, 57),
(34, 34, N'Nidoking', 'Poison', 'Ground', 81, 102, 77),
(35, 35, N'Clefairy', 'Fairy', NULL, 70, 45, 48),
(36, 36, N'Clefable', 'Fairy', NULL, 95, 70, 73),
(37, 37, N'Vulpix', 'Fire', NULL, 38, 41, 40),
(38, 38, N'Ninetales', 'Fire', NULL, 73, 76, 75),
(39, 39, N'Jigglypuff', 'Normal', 'Fairy', 115, 45, 20),
(40, 40, N'Wigglytuff', 'Normal', 'Fairy', 140, 70, 45),
(41, 41, N'Zubat', 'Poison', 'Flying', 40, 45, 35),
(42, 42, N'Golbat', 'Poison', 'Flying', 75, 80, 70),
(43, 43, N'Oddish', 'Grass', 'Poison', 45, 50, 55),
(44, 44, N'Gloom', 'Grass', 'Poison', 60, 65, 70),
(45, 45, N'Vileplume', 'Grass', 'Poison', 75, 80, 85),
(46, 46, N'Paras', 'Bug', 'Grass', 35, 70, 55),
(47, 47, N'Parasect', 'Bug', 'Grass', 60, 95, 80),
(48, 48, N'Venonat', 'Bug', 'Poison', 60, 55, 50),
(49, 49, N'Venomoth', 'Bug', 'Poison', 70, 65, 60),
(50, 50, N'Diglett', 'Ground', NULL, 10, 55, 25);

SET IDENTITY_INSERT dbo.Pokemon OFF;

-- ----------------------------------------------------------------------------
-- STEP 5: SEED TRAINERS (12 ACTIVE TRAINERS WITH CURRENT LOCATIONS)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.Trainer ON;

INSERT INTO dbo.Trainer (TrainerID, Username, Email, LocationID) VALUES
(1, N'hoang_long', 'hoanglong@pokemon.vn', 1),
(2, N'minh_anh', 'minhanh@pokemon.vn', 7),
(3, N'tuan_kiet', 'tuankiet@pokemon.vn', 2),
(4, N'bao_ngoc', 'baongoc@pokemon.vn', 5),
(5, N'viet_dung', 'vietdung@pokemon.vn', 3),
(6, N'thu_ha', 'thuha@pokemon.vn', 6),
(7, N'quang_huy', 'quanghuy@pokemon.vn', 4),
(8, N'khanh_linh', 'khanhlinh@pokemon.vn', 8),
(9, N'duc_thanh', 'ducthanh@pokemon.vn', 10),
(10, N'phuong_thao', 'phuongthao@pokemon.vn', 11),
(11, N'tien_dat', 'tiendat@pokemon.vn', 9),
(12, N'mai_huong', 'maihuong@pokemon.vn', 12);

SET IDENTITY_INSERT dbo.Trainer OFF;

-- ----------------------------------------------------------------------------
-- STEP 6: SEED WILD ENCOUNTERS (40 ENCOUNTERS ACROSS LOCATIONS & LEVEL RANGES)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.WildEncounter ON;

INSERT INTO dbo.WildEncounter (EncounterID, LocationID, PokemonID, MinLevel, MaxLevel) VALUES
-- Location 1: Thị trấn Khởi Nguyên (Pallet Town)
(1, 1, 1, 3, 6),
(2, 1, 4, 3, 6),
(3, 1, 7, 3, 6),
(4, 1, 16, 2, 5),
(5, 1, 19, 2, 5),
-- Location 2: Rừng Rậm Thường Xanh (Viridian Forest)
(6, 2, 1, 3, 7),
(7, 2, 10, 3, 7),
(8, 2, 11, 4, 8),
(9, 2, 12, 10, 14),
(10, 2, 13, 3, 7),
(11, 2, 14, 4, 8),
(12, 2, 15, 10, 14),
(13, 2, 25, 4, 9),
(14, 2, 21, 3, 8),
-- Location 3: Hang Núi Mặt Trăng (Mt. Moon)
(15, 3, 41, 6, 12),
(16, 3, 42, 18, 24),
(17, 3, 35, 8, 14),
(18, 3, 46, 7, 12),
(19, 3, 27, 6, 12),
(20, 3, 50, 8, 15),
-- Location 4: Đường Mòn Số 1 (Route 1)
(21, 4, 16, 2, 6),
(22, 4, 19, 2, 6),
(23, 4, 29, 3, 8),
(24, 4, 32, 3, 8),
(25, 4, 43, 4, 9),
-- Location 5: Vịnh Cảng Sóng Biếc (Cerulean / Vermilion Coast)
(26, 5, 7, 5, 10),
(27, 5, 8, 16, 22),
(28, 5, 23, 8, 14),
(29, 5, 39, 6, 12),
-- Location 6: Tháp Cổ Huyền Bí (Lavender Tower)
(30, 6, 41, 10, 16),
(31, 6, 23, 12, 18),
(32, 6, 24, 22, 28),
-- Location 7: Thành phố Hoa Đỗ Quyên (Celadon City)
(33, 7, 43, 8, 14),
(34, 7, 44, 16, 22),
(35, 7, 37, 10, 16),
(36, 7, 48, 8, 14),
-- Location 8: Rừng Thiêng Cổ Kính (Ilex Forest - Johto)
(37, 8, 43, 10, 16),
(38, 8, 48, 10, 16),
(39, 8, 49, 25, 32),
-- Location 9: Tháp Chuông Hoàng Hôn (Bell Tower - Johto)
(40, 9, 21, 12, 18);

SET IDENTITY_INSERT dbo.WildEncounter OFF;

-- ----------------------------------------------------------------------------
-- STEP 7: SEED OWNED POKÉMON (20 OWNED INSTANCES WITH PARTY SLOTS & STORAGE)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.OwnedPokemon ON;

INSERT INTO dbo.OwnedPokemon (
    OwnedPokemonID, TrainerID, PokemonID, Nickname, [Level], PartySlot
) VALUES
-- Trainer 1: hoang_long (Party 1-3, 1 Storage)
(1, 1, 6, N'Đại Ca Rồng', 36, 1),
(2, 1, 25, N'Chuột Sấm Sét', 25, 2),
(3, 1, 1, N'Búp Mầm Nhỏ', 15, 3),
(4, 1, 18, N'Chim Thần Tốc', 36, NULL),
-- Trainer 2: minh_anh (Party 1-3)
(5, 2, 9, N'Rùa Pháo Đài', 36, 1),
(6, 2, 38, N'Cửu Vĩ Hồ Ly', 32, 2),
(7, 2, 12, N'Bướm Ánh Trăng', 22, 3),
-- Trainer 3: tuan_kiet (Party 1-3)
(8, 3, 3, N'Vua Hoa Rừng', 34, 1),
(9, 3, 28, N'Tê Tê Gai Thép', 26, 2),
(10, 3, 15, N'Chiến Binh Ong', 20, 3),
-- Trainer 4: bao_ngoc (Party 1-2)
(11, 4, 36, N'Tiên Mặt Trăng', 28, 1),
(12, 4, 39, N'Bóng Ca Hát', 18, 2),
-- Trainer 5: viet_dung (Party 1-2)
(13, 5, 24, N'Chúa Trăn Độc', 26, 1),
(14, 5, 42, N'Dơi Hút Máu', 24, 2),
-- Trainer 6: thu_ha (Party 1-2)
(15, 6, 45, N'Hoa Độc Ngát Hương', 27, 1),
(16, 6, 17, N'Ưng Lửa Đồng Bằng', 22, 2),
-- Trainer 7: quang_huy (Party 1)
(17, 7, 4, N'Thằn Lằn Lửa Đỏ', 16, 1),
-- Trainer 8: khanh_linh (Party 1)
(18, 8, 7, N'Rùa Nước Nhỏ', 14, 1),
-- Trainer 9: duc_thanh (Party 1)
(19, 9, 27, N'Chuột Đào Đất', 18, 1),
-- Trainer 10: phuong_thao (Party 1)
(20, 10, 43, N'Củ Cải Xanh', 15, 1);

SET IDENTITY_INSERT dbo.OwnedPokemon OFF;

-- ----------------------------------------------------------------------------
-- STEP 8: SEED PERSONAL POKÉDEX (40 DISCOVERY & CATCH RECORDS)
-- Note: PersonalPokedex has a composite PK (TrainerID, PokemonID) and NO identity column.
-- ----------------------------------------------------------------------------
INSERT INTO dbo.PersonalPokedex (
    TrainerID, PokemonID, FirstSeenAt, IsCaught
) VALUES
-- Trainer 1: hoang_long (7 records)
(1, 4, '2026-01-01T08:00:00', 1),
(1, 5, '2026-01-10T09:00:00', 1),
(1, 6, '2026-01-25T14:00:00', 1),
(1, 25, '2026-01-05T10:00:00', 1),
(1, 1, '2026-01-02T11:00:00', 1),
(1, 16, '2026-01-01T08:15:00', 1),
(1, 18, '2026-01-20T16:00:00', 1),
-- Trainer 2: minh_anh (7 records)
(2, 7, '2026-01-02T09:30:00', 1),
(2, 8, '2026-01-12T10:00:00', 1),
(2, 9, '2026-01-28T09:00:00', 1),
(2, 37, '2026-01-08T11:00:00', 1),
(2, 38, '2026-01-22T15:30:00', 1),
(2, 10, '2026-01-03T14:00:00', 1),
(2, 12, '2026-01-15T18:00:00', 1),
-- Trainer 3: tuan_kiet (7 records)
(3, 1, '2026-01-01T10:00:00', 1),
(3, 2, '2026-01-11T11:00:00', 1),
(3, 3, '2026-01-26T12:00:00', 1),
(3, 27, '2026-01-06T13:00:00', 1),
(3, 28, '2026-01-18T14:30:00', 1),
(3, 13, '2026-01-02T15:00:00', 1),
(3, 15, '2026-01-14T10:00:00', 1),
-- Trainer 4: bao_ngoc (3 records)
(4, 35, '2026-01-05T12:00:00', 1),
(4, 36, '2026-01-20T17:00:00', 1),
(4, 39, '2026-01-07T11:30:00', 1),
-- Trainer 5: viet_dung (4 records)
(5, 23, '2026-01-04T13:00:00', 1),
(5, 24, '2026-01-19T13:00:00', 1),
(5, 41, '2026-01-03T16:00:00', 1),
(5, 42, '2026-01-16T21:00:00', 1),
-- Trainer 6: thu_ha (5 records)
(6, 43, '2026-01-05T14:00:00', 1),
(6, 44, '2026-01-15T15:00:00', 1),
(6, 45, '2026-01-27T16:00:00', 1),
(6, 16, '2026-01-02T09:00:00', 1),
(6, 17, '2026-01-13T09:30:00', 1),
-- Trainer 7: quang_huy (2 records)
(7, 4, '2026-01-08T10:00:00', 1),
(7, 16, '2026-01-08T10:30:00', 1),
-- Trainer 8: khanh_linh (2 records, including seen-only test)
(8, 7, '2026-01-09T14:00:00', 1),
(8, 43, '2026-01-10T15:00:00', 0),
-- Trainer 9: duc_thanh (2 records, including seen-only test)
(9, 27, '2026-01-10T11:00:00', 1),
(9, 41, '2026-01-11T12:00:00', 0),
-- Trainer 10: phuong_thao (1 record)
(10, 43, '2026-01-11T12:00:00', 1);

COMMIT TRAN;
GO

PRINT '==================================================';
PRINT '  POKEMON WORLD SEED DATA SUCCESSFULLY LOADED!   ';
PRINT '  - Region:         10 rows                       ';
PRINT '  - Location:       12 rows                       ';
PRINT '  - Pokemon:        50 rows                       ';
PRINT '  - Trainer:        12 rows                       ';
PRINT '  - WildEncounter:  40 rows                       ';
PRINT '  - OwnedPokemon:   20 rows                       ';
PRINT '  - PersonalPokedex:40 rows                       ';
PRINT '==================================================';
GO
