/* =============================================================================
   Assignment: DBI202 - Assignment 2 (Pokémon World Database)
   File:       function.sql
   Purpose:    Creates the scalar user-defined function fn_GetPokemonTotalStats
               to calculate the aggregate core combat power (Base Stats Total).
   Target:     Microsoft SQL Server 2022+
   Author:     Student Team (Pokémon World Project)
   ============================================================================= */

USE pokemon_world;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- FUNCTION: dbo.fn_GetPokemonTotalStats
-- Business Purpose:
--   Tính toán và trả về tổng điểm chỉ số cơ bản của một loài Pokémon dựa trên
--   mã loài (@PokemonID): BaseHP + BaseAttack + BaseDefense.
-- Parameters:
--   @PokemonID INT: Mã định danh loài Pokémon trong bảng dbo.Pokemon.
-- Returns:
--   INT: Tổng số điểm (BaseHP + BaseAttack + BaseDefense).
--   Nếu không tìm thấy @PokemonID trong hệ thống, hàm trả về 0.
-- Example:
--   Bulbasaur (PokemonID = 1): 45 (HP) + 49 (Attack) + 49 (Defense) = 143.
--   SELECT dbo.fn_GetPokemonTotalStats(1); -- Returns 143
-- =============================================================================
CREATE OR ALTER FUNCTION dbo.fn_GetPokemonTotalStats (@PokemonID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalStats INT;

    SELECT @TotalStats = BaseHP + BaseAttack + BaseDefense
    FROM dbo.Pokemon
    WHERE PokemonID = @PokemonID;

    RETURN COALESCE(@TotalStats, 0);
END;
GO
