/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       procedure.sql
   Purpose:    Creates transactional stored procedure usp_CatchPokemon for 
               capturing wild Pokémon and synchronizing personal Pokédex.
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- STORED PROCEDURE: dbo.usp_CatchPokemon
-- Business Purpose:
--   Thực hiện nghiệp vụ bắt Pokémon hoang dã một cách an toàn và toàn vẹn (ACID):
--   1. Xác thực tài khoản Huấn luyện viên tồn tại trong hệ thống (TrainerID).
--   2. Xác thực loài Pokémon có phân bố tại địa danh đã chọn (LocationID)
--      ở cấp độ chỉ định (Level nằm trong khoảng MinLevel..MaxLevel của WildEncounter).
--   3. Tạo mới một bản ghi thú cưng trong bảng dbo.OwnedPokemon với PartySlot = NULL
--      (mặc định chuyển vào kho lưu trữ máy tính PC).
--   4. Tự động đồng bộ hóa bách khoa toàn thư cá nhân dbo.PersonalPokedex (Upsert):
--      đánh dấu trạng thái đã thu phục (IsCaught = 1) và lưu mốc thời gian khám phá.
--   5. Trả về mã số cá thể vừa thu phục (@NewOwnedPokemonID) thông qua cả tham số
--      OUTPUT và tập kết quả SELECT.
-- Parameters:
--   @TrainerID INT: Mã Huấn luyện viên thực hiện việc bắt.
--   @PokemonID INT: Mã loài Pokémon bắt được.
--   @LocationID INT: Mã địa danh nơi bắt gặp.
--   @Level INT: Cấp độ của cá thể Pokémon bắt được.
--   @Nickname NVARCHAR(50) = NULL: Biệt danh đặt cho thú cưng (tùy chọn).
--   @NewOwnedPokemonID INT = NULL OUTPUT: Mã cá thể mới được tạo ra (trả về qua OUTPUT).
-- Error Codes:
--   51000: Nhà huấn luyện không tồn tại.
--   51001: Không tìm thấy loài Pokémon này tại địa danh đã chọn ở cấp độ chỉ định.
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_CatchPokemon
    @TrainerID INT,
    @PokemonID INT,
    @LocationID INT,
    @Level INT,
    @Nickname NVARCHAR(50) = NULL,
    @NewOwnedPokemonID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- 1. Kiểm tra Nhà huấn luyện có tồn tại trong hệ thống hay không
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.Trainer 
        WHERE TrainerID = @TrainerID
    )
    BEGIN
        THROW 51000, N'Lỗi 51000: Nhà huấn luyện (Trainer) không tồn tại!', 1;
    END;

    -- 2. Kiểm tra loài Pokémon có xuất hiện tại địa danh ở cấp độ chỉ định hay không
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.WildEncounter 
        WHERE LocationID = @LocationID 
          AND PokemonID = @PokemonID 
          AND @Level BETWEEN MinLevel AND MaxLevel
    )
    BEGIN
        THROW 51001, N'Lỗi 51001: Không tìm thấy loài Pokémon này tại địa danh đã chọn ở cấp độ chỉ định!', 1;
    END;

    -- Bắt đầu giao dịch toàn vẹn dữ liệu (Atomic Transaction)
    BEGIN TRAN;

    -- 3. Thêm cá thể mới vào bảng Pokémon sở hữu (PartySlot = NULL: lưu trữ trong PC)
    INSERT INTO dbo.OwnedPokemon (
        TrainerID, 
        PokemonID, 
        Nickname, 
        [Level], 
        PartySlot
    )
    VALUES (
        @TrainerID, 
        @PokemonID, 
        @Nickname, 
        @Level, 
        NULL
    );

    -- Lấy mã ID của bản ghi vừa chèn
    SET @NewOwnedPokemonID = SCOPE_IDENTITY();

    -- 4. Đồng bộ hóa vào sổ tay PersonalPokedex (Upsert / MERGE)
    MERGE dbo.PersonalPokedex AS target
    USING (SELECT @TrainerID AS TrainerID, @PokemonID AS PokemonID) AS source
    ON target.TrainerID = source.TrainerID AND target.PokemonID = source.PokemonID
    WHEN MATCHED THEN
        UPDATE SET IsCaught = 1
    WHEN NOT MATCHED THEN
        INSERT (TrainerID, PokemonID, FirstSeenAt, IsCaught)
        VALUES (@TrainerID, @PokemonID, GETDATE(), 1);

    -- Xác nhận hoàn tất toàn bộ giao dịch
    COMMIT TRAN;

    -- Trả về NewOwnedPokemonID dưới dạng Result Set (hỗ trợ gọi từ client / ad-hoc queries)
    SELECT @NewOwnedPokemonID AS NewOwnedPokemonID;
END;
GO
