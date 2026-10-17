/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       trigger.sql
   Purpose:    Creates the data validation trigger TR_OwnedPokemon_CheckLevel
               on table dbo.OwnedPokemon to strictly enforce valid Pokémon level
               boundaries (1 to 100) on INSERT and UPDATE operations.
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- TRIGGER: dbo.TR_OwnedPokemon_CheckLevel
-- Business Purpose:
--   Bảo vệ tính toàn vẹn nghiệp vụ của thế giới Pokémon: một cá thể Pokémon
--   thuộc sở hữu của Huấn luyện viên (dbo.OwnedPokemon) chỉ có thể đạt cấp độ
--   hợp lệ từ Level 1 đến Level 100.
-- Mechanism:
--   - Trigger kích hoạt theo cơ chế AFTER INSERT, UPDATE trên bảng dbo.OwnedPokemon.
--   - Kiểm tra dữ liệu mới đưa vào thông qua bảng ảo `inserted`.
--   - Nếu phát hiện bất kỳ dòng nào có Level < 1 hoặc Level > 100:
--       1. Hủy bỏ toàn bộ giao dịch bằng lệnh ROLLBACK TRANSACTION.
--       2. Ném mã lỗi tùy biến 50050 kèm thông điệp cảnh báo vi phạm nghiệp vụ.
-- Architectural Note:
--   Hệ thống áp dụng mô hình bảo mật nhiều lớp (Defense-in-depth):
--   Ràng buộc schema CK_OwnedPokemon_Level đóng vai trò là chốt chặn tĩnh,
--   trong khi Trigger TR_OwnedPokemon_CheckLevel là tầng xử lý logic chủ động
--   cung cấp mã lỗi nghiệp vụ 50050 và hủy bỏ giao dịch dở dang.
-- =============================================================================
CREATE OR ALTER TRIGGER dbo.TR_OwnedPokemon_CheckLevel
ON dbo.OwnedPokemon
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra nếu tồn tại bất kỳ dòng nào vi phạm giới hạn cấp độ [1, 100]
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE [Level] < 1 OR [Level] > 100
    )
    BEGIN
        -- Hủy bỏ giao dịch DML đang thực hiện
        ROLLBACK TRANSACTION;

        -- Ném mã lỗi 50050 với thông báo chi tiết
        THROW 50050, N'Ràng buộc nghiệp vụ vi phạm: Cấp độ Pokémon ([Level]) phải nằm trong khoảng từ 1 đến 100!', 1;
    END;
END;
GO
