USE Sistema_Medico;

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_receta;
DELIMITER //
CREATE FUNCTION fn_validar_receta(p_cita VARCHAR(10), p_med VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF NOT EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cita) THEN RETURN 'Error: La cita no existe';
    ELSEIF p_med = '' THEN RETURN 'Error: Medicamento vacío';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;


-- A. CREAR
DROP PROCEDURE IF EXISTS sp_crear_receta;
DELIMITER //
CREATE PROCEDURE sp_crear_receta(IN p_cita VARCHAR(10), IN p_med VARCHAR(100), IN p_dosis VARCHAR(50))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('receta_cita', 'sp_crear_receta', @errno, @msg);
        SELECT 'ERROR SISTEMA: Fallo al registrar receta' AS Mensaje;
    END;

    SET v_valida = fn_validar_receta(p_cita, p_med);
    IF v_valida = 'OK' THEN
        -- SENTENCIA PREPARADA
        SET @sql = 'INSERT INTO receta_cita (cod_cita, medicamento, dosis) VALUES (?, ?, ?)';
        SET @c = p_cita, @m = p_med, @d = p_dosis;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @c, @m, @d;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Medicamento agregado' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER (LISTAR POR CITA)
DROP PROCEDURE IF EXISTS sp_listar_receta_cita;
CREATE PROCEDURE sp_listar_receta_cita(IN p_cita VARCHAR(10))
BEGIN
    -- SENTENCIA PREPARADA
    SET @sql = 'SELECT cod_cita, medicamento, dosis FROM receta_cita WHERE cod_cita = ?';
    SET @c = p_cita;
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING @c;
    DEALLOCATE PREPARE stmt;
END //

-- C. ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_receta;
CREATE PROCEDURE sp_actualizar_receta(
    IN p_cita VARCHAR(10), 
    IN p_med VARCHAR(100), 
    IN p_nueva_dosis VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('receta_cita', 'sp_actualizar_receta', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar la dosis' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM receta_cita WHERE cod_cita = p_cita AND medicamento = p_med) THEN
        -- SENTENCIA PREPARADA
        SET @sql = 'UPDATE receta_cita SET dosis = ? WHERE cod_cita = ? AND medicamento = ?';
        SET @d = p_nueva_dosis, @c = p_cita, @m = p_med;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @d, @c, @m;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Dosis actualizada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: El medicamento no existe en esta receta' AS Mensaje; 
    END IF;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_medicamento;
CREATE PROCEDURE sp_eliminar_medicamento(IN p_cita VARCHAR(10), IN p_med VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('receta_cita', 'sp_eliminar_medicamento', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo eliminar el medicamento' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM receta_cita WHERE cod_cita = p_cita AND medicamento = p_med) THEN
        -- SENTENCIA PREPARADA
        SET @sql = 'DELETE FROM receta_cita WHERE cod_cita = ? AND medicamento = ?';
        SET @c = p_cita, @m = p_med;
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING @c, @m;
        DEALLOCATE PREPARE stmt;
        
        SELECT 'ÉXITO: Medicamento removido' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: Registro no encontrado' AS Mensaje; 
    END IF;
END //

DELIMITER ;