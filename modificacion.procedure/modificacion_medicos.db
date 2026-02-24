USE Sistema_Medico;

-- MEDICOS 

-- 1. CREAR 

DROP PROCEDURE IF EXISTS sp_crear_medico;
DELIMITER //
CREATE PROCEDURE sp_crear_medico(
    IN p_id VARCHAR(10), 
    IN p_nombre VARCHAR(100), 
    IN p_esp VARCHAR(10), 
    IN p_fac VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_crear_medico', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    -- VALIDACIONES
    IF p_id = '' OR p_nombre = '' THEN
        SELECT 'VALIDACIÓN: El ID y el Nombre son obligatorios.' AS Mensaje;
    ELSEIF EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: Error, el ID del médico ya se encuentra registrado.' AS Mensaje;
    ELSEIF NOT EXISTS (SELECT 1 FROM especialidades WHERE ID_especialida = p_esp) THEN
        SELECT 'VALIDACIÓN: La especialidad ingresada no existe.' AS Mensaje;
    ELSE
        -- SENTENCIA PREPARADA
        SET @sql = 'INSERT INTO MEDICOSSS (Medico_ID, Nombre_Medico, Especialidades, Facultad_nombres) VALUES (?, ?, ?, ?)';
        SET @id = p_id, @nom = p_nombre, @esp = p_esp, @fac = p_fac;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id, @nom, @esp, @fac;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Médico registrado correctamente.' AS Mensaje;
    END IF;
END //

-- 2. LEER 

DROP PROCEDURE IF EXISTS sp_listar_medicos;
CREATE PROCEDURE sp_listar_medicos()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_listar_medicos', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    -- SENTENCIA PREPARADA
    SET @sql = 'SELECT Medico_ID, Nombre_Medico, Especialidades, Facultad_nombres FROM MEDICOSSS';
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- 3. ACTUALIZAR 

DROP PROCEDURE IF EXISTS sp_actualizar_medico;
CREATE PROCEDURE sp_actualizar_medico(
    IN p_id VARCHAR(10), 
    IN p_nuevo_nombre VARCHAR(100),
    IN p_nueva_esp VARCHAR(10),
    IN p_nueva_fac VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_actualizar_medico', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    IF NOT EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: Error, el médico con ese ID no existe.' AS Mensaje;
    ELSEIF p_nuevo_nombre = '' THEN
        SELECT 'VALIDACIÓN: El nombre no puede estar vacío.' AS Mensaje;
    ELSE
        -- SENTENCIA PREPARADA
        SET @sql = 'UPDATE MEDICOSSS SET Nombre_Medico = ?, Especialidades = ?, Facultad_nombres = ? WHERE Medico_ID = ?';
        SET @nom = p_nuevo_nombre, @esp = p_nueva_esp, @fac = p_nueva_fac, @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @nom, @esp, @fac, @id;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Médico actualizado correctamente.' AS Mensaje;
    END IF;
END //

-- 4. ELIMINAR 

DROP PROCEDURE IF EXISTS sp_eliminar_medico;
CREATE PROCEDURE sp_eliminar_medico(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_eliminar_medico', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo eliminar. Es probable que el médico tenga citas registradas.' AS Mensaje;
    END;

    IF NOT EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: El médico no existe.' AS Mensaje;
    ELSE
        -- SENTENCIA PREPARADA
        SET @sql = 'DELETE FROM MEDICOSSS WHERE Medico_ID = ?';
        SET @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Médico eliminado correctamente.' AS Mensaje;
    END IF;
END //

DELIMITER ;