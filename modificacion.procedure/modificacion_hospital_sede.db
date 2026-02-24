USE Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_sede;
DELIMITER //
CREATE FUNCTION fn_validar_sede(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' THEN RETURN 'Error: ID requerido';
    ELSEIF EXISTS(SELECT 1 FROM Hospital_Sede WHERE id_hospital = p_id) THEN RETURN 'Error: ID duplicado';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- A. CREAR
DROP PROCEDURE IF EXISTS sp_crear_sede;
DELIMITER //
CREATE PROCEDURE sp_crear_sede(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Hospital_Sede', 'sp_crear_sede', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_sede(p_id, p_nombre);
    
    IF v_valida = 'OK' THEN
        SET @sql = 'INSERT INTO Hospital_Sede (id_hospital, nombre) VALUES (?, ?)';
        SET @id = p_id, @nom = p_nombre;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id, @nom;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Sede guardada' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_sedes;
CREATE PROCEDURE sp_listar_sedes()
BEGIN
    SET @sql = 'SELECT id_hospital, nombre FROM Hospital_Sede';
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- C. ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_sede;
CREATE PROCEDURE sp_actualizar_sede(IN p_id VARCHAR(10), IN p_nuevo_nom VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Hospital_Sede', 'sp_actualizar_sede', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar la sede' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM Hospital_Sede WHERE id_hospital = p_id) THEN
        SET @sql = 'UPDATE Hospital_Sede SET nombre = ? WHERE id_hospital = ?';
        SET @nom = p_nuevo_nom, @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @nom, @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Sede actualizada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: ID de sede no existe' AS Mensaje; 
    END IF;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_sede;
CREATE PROCEDURE sp_eliminar_sede(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Hospital_Sede', 'sp_eliminar_sede', @errno, @msg);
        SELECT 'ERROR: No se puede borrar, la sede tiene registros vinculados' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM Hospital_Sede WHERE id_hospital = p_id) THEN
        SET @sql = 'DELETE FROM Hospital_Sede WHERE id_hospital = ?';
        SET @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Sede eliminada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: La sede no existe' AS Mensaje; 
    END IF;
END //

DELIMITER ;