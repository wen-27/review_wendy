USE Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_especialidad;
DELIMITER //
CREATE FUNCTION fn_validar_especialidad(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' OR p_nombre = '' THEN RETURN 'Error: Campos vacíos';
    ELSEIF EXISTS(SELECT 1 FROM especialidades WHERE ID_especialida = p_id) THEN RETURN 'Error: ID duplicado';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- A. CREAR
DROP PROCEDURE IF EXISTS sp_crear_especialidad;
DELIMITER //
CREATE PROCEDURE sp_crear_especialidad(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_crear_especialidad', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_especialidad(p_id, p_nombre);
    
    IF v_valida = 'OK' THEN
        SET @sql = 'INSERT INTO especialidades (ID_especialida, Nombre_especialidad) VALUES (?, ?)';
        SET @id = p_id, @nom = p_nombre;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id, @nom;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Especialidad registrada' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER (
DROP PROCEDURE IF EXISTS sp_listar_especialidades;
CREATE PROCEDURE sp_listar_especialidades()
BEGIN
    SET @sql = 'SELECT ID_especialida, Nombre_especialidad FROM especialidades';
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- C. ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_especialidad;
CREATE PROCEDURE sp_actualizar_especialidad(IN p_id VARCHAR(10), IN p_nuevo_nom VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_actualizar_especialidad', @errno, @msg);
        SELECT 'ERROR SISTEMA: Fallo al actualizar' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM especialidades WHERE ID_especialida = p_id) THEN
        SET @sql = 'UPDATE especialidades SET Nombre_especialidad = ? WHERE ID_especialida = ?';
        SET @nom = p_nuevo_nom, @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @nom, @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Especialidad actualizada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; 
    END IF;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_especialidad;
CREATE PROCEDURE sp_eliminar_especialidad(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_eliminar_especialidad', @errno, @msg);
        SELECT 'ERROR: No se puede eliminar (posibles datos vinculados)' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM especialidades WHERE ID_especialida = p_id) THEN
        SET @sql = 'DELETE FROM especialidades WHERE ID_especialida = ?';
        SET @id = p_id;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @id;
        DEALLOCATE PREPARE stmt;
        SELECT 'ÉXITO: Especialidad eliminada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; 
    END IF;
END //

DELIMITER ;