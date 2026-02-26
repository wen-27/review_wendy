USE Sistema_Medicos;

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_facultad;
DELIMITER //
CREATE FUNCTION fn_validar_facultad(p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_nombre = '' THEN 
        RETURN 'Error: El nombre de la facultad es obligatorio';
    ELSEIF EXISTS(SELECT 1 FROM facultades WHERE nombre_facultad = p_nombre) THEN 
        RETURN 'Error: Ya existe una facultad con ese nombre';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR (CREATE)
DROP PROCEDURE IF EXISTS sp_crear_facultad;
//
CREATE PROCEDURE sp_crear_facultad(IN p_nombre VARCHAR(100), IN p_decano VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultades', 'sp_crear_facultad', @errno, @msg);
        SELECT CONCAT('SISTEMA ERROR: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_facultad(p_nombre);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;
            -- Omitimos id_facultad por ser AUTO_INCREMENT
            SET @sql_ins_fac = 'INSERT INTO facultades (nombre_facultad, decano) VALUES (?, ?)';
            SET @f_nom = p_nombre, @f_dec = p_decano;
            PREPARE stmt_ins_fac FROM @sql_ins_fac;
            EXECUTE stmt_ins_fac USING @f_nom, @f_dec;
            DEALLOCATE PREPARE stmt_ins_fac;
        COMMIT;
        SELECT 'ÉXITO: Facultad registrada correctamente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER (READ)
DROP PROCEDURE IF EXISTS sp_listar_facultades;
//
CREATE PROCEDURE sp_listar_facultades()
BEGIN
    -- Selección directa para evitar desincronización
    SELECT 
        id_facultad AS 'ID', 
        nombre_facultad AS 'Facultad',
        decano AS 'Decano'
    FROM facultades 
    ORDER BY nombre_facultad ASC;
END //

-- C. ACTUALIZAR (UPDATE)
DROP PROCEDURE IF EXISTS sp_actualizar_facultad;
//
CREATE PROCEDURE sp_actualizar_facultad(IN p_id INT, IN p_nuevo_nom VARCHAR(100), IN p_nuevo_decano VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultades', 'sp_actualizar_facultad', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM facultades WHERE id_facultad = p_id) THEN
            SET @sql_upd_fac = 'UPDATE facultades SET nombre_facultad = ?, decano = ? WHERE id_facultad = ?';
            SET @unom_f = p_nuevo_nom, @udec_f = p_nuevo_decano, @uid_f = p_id;
            PREPARE stmt_upd_fac FROM @sql_upd_fac;
            EXECUTE stmt_upd_fac USING @unom_f, @udec_f, @uid_f;
            DEALLOCATE PREPARE stmt_upd_fac;
            COMMIT;
            SELECT 'ÉXITO: Facultad actualizada' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; 
        END IF;
END //

-- D. ELIMINAR (DELETE)
DROP PROCEDURE IF EXISTS sp_eliminar_facultad;
//
CREATE PROCEDURE sp_eliminar_facultad(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultades', 'sp_eliminar_facultad', @errno, @msg);
        SELECT 'ERROR: No se puede eliminar (posibles médicos vinculados)' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM facultades WHERE id_facultad = p_id) THEN
            SET @sql_del_fac = 'DELETE FROM facultades WHERE id_facultad = ?';
            SET @did_f = p_id;
            PREPARE stmt_del_fac FROM @sql_del_fac;
            EXECUTE stmt_del_fac USING @did_f;
            DEALLOCATE PREPARE stmt_del_fac;
            COMMIT;
            SELECT 'ÉXITO: Facultad eliminada' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: La facultad no existe.' AS Mensaje; 
        END IF;
END //

DELIMITER ;