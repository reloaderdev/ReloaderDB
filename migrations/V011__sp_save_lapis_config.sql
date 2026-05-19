-- V011: SP para guardar configuracion de lapis en sockets de equipo
-- Endpoint: POST /webresources/characters/lapis-config
-- Recibe XML con lista de (CharacterEquipmentId, SocketNumber, LapisId)
-- LapisId vacio o 0 = quitar lapis del socket

CREATE OR ALTER PROCEDURE equipment.sp_SaveCharacterLapisConfig
    @CharacterId    bigint,
    @ConfigXml      nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML = CAST(@ConfigXml AS XML);

    CREATE TABLE #SocketChanges (
        CharacterEquipmentId bigint      NOT NULL,
        SocketNumber         int         NOT NULL,
        LapisId              bigint      NULL
    );

    INSERT INTO #SocketChanges (CharacterEquipmentId, SocketNumber, LapisId)
    SELECT
        s.value('(CharacterEquipmentId)[1]', 'bigint'),
        s.value('(SocketNumber)[1]',         'int'),
        NULLIF(s.value('(LapisId)[1]', 'nvarchar(20)'), '')
    FROM @xml.nodes('/config/socket') AS t(s);

    -- Validar que todos los CharacterEquipmentId pertenecen al personaje
    IF EXISTS (
        SELECT 1
        FROM #SocketChanges SC
        LEFT JOIN equipment.CharacterEquipment CE
            ON CE.CharacterEquipmentId = SC.CharacterEquipmentId
           AND CE.CharacterId          = @CharacterId
        WHERE CE.CharacterEquipmentId IS NULL
    )
    BEGIN
        DROP TABLE #SocketChanges;
        RAISERROR('CharacterEquipmentId no pertenece al personaje indicado.', 16, 1);
        RETURN;
    END

    -- Quitar lapis donde LapisId es NULL o 0
    DELETE EIL
    FROM equipment.EquippedItemLapis EIL
    INNER JOIN equipment.EquippedItemSocket EIS
        ON EIS.EquippedItemSocketId = EIL.EquippedItemSocketId
    INNER JOIN #SocketChanges SC
        ON SC.CharacterEquipmentId = EIS.CharacterEquipmentId
       AND SC.SocketNumber         = EIS.SocketNumber
    WHERE SC.LapisId IS NULL OR SC.LapisId = 0;

    -- Upsert donde LapisId > 0
    MERGE equipment.EquippedItemLapis AS target
    USING (
        SELECT
            EIS.EquippedItemSocketId,
            EIS.CharacterEquipmentId,
            CE.ItemTypeId,
            SC.LapisId
        FROM #SocketChanges SC
        INNER JOIN equipment.EquippedItemSocket EIS
            ON EIS.CharacterEquipmentId = SC.CharacterEquipmentId
           AND EIS.SocketNumber         = SC.SocketNumber
        INNER JOIN equipment.CharacterEquipment CE
            ON CE.CharacterEquipmentId  = EIS.CharacterEquipmentId
        WHERE SC.LapisId IS NOT NULL AND SC.LapisId > 0
    ) AS source
    ON target.EquippedItemSocketId = source.EquippedItemSocketId
    WHEN MATCHED THEN
        UPDATE SET target.LapisId = source.LapisId
    WHEN NOT MATCHED THEN
        INSERT (EquippedItemSocketId, CharacterEquipmentId, ItemTypeId, LapisId)
        VALUES (source.EquippedItemSocketId, source.CharacterEquipmentId, source.ItemTypeId, source.LapisId);

    DROP TABLE #SocketChanges;

    SELECT 1 AS Saved;
END
GO
