USE Sistema_Medico;

-- 1. VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_facultad;
DELIMITER //
CREATE FUNCTION fn_validar_facultad(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' OR p_nombre = '' THEN RETURN 'Error: Datos incompletos';
    ELSEIF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN RETURN 'Error: Facultad ya existe';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- A. CREAR
DROP PROCEDURE IF EXISTS sp_crear_facultad;
DELIMITER //
CREATE PROCEDURE sp_crear_facultad(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultad_nombres', 'sp_crear_facultad', @errno, @msg);
        SELECT CONCAT('SISTEMA ERROR: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_facultad(p_id, p_nombre);
    
    IF v_valida = 'OK' THEN
        SET @sql = 'INSERT INTO facultad_nombres (id_facultad, nombre) VALUES (?, ?)';
        SET @id = p_id, @nom = p_nombre;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id, @nom;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Facultad registrada' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_facultades;
CREATE PROCEDURE sp_listar_facultades()
BEGIN
    SET @sql = 'SELECT id_facultad, nombre FROM facultad_nombres';
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- C. ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_facultad;
CREATE PROCEDURE sp_actualizar_facultad(IN p_id VARCHAR(10), IN p_nuevo_nom VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultad_nombres', 'sp_actualizar_facultad', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN
        SET @sql = 'UPDATE facultad_nombres SET nombre = ? WHERE id_facultad = ?';
        SET @nom = p_nuevo_nom, @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @nom, @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Facultad actualizada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; 
    END IF;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_facultad;
CREATE PROCEDURE sp_eliminar_facultad(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultad_nombres', 'sp_eliminar_facultad', @errno, @msg);
        SELECT 'ERROR: No se puede eliminar la facultad porque tiene médicos asignados.' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN
        SET @sql = 'DELETE FROM facultad_nombres WHERE id_facultad = ?';
        SET @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Facultad eliminada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: La facultad no existe.' AS Mensaje; 
    END IF;
END //

DELIMITER ;