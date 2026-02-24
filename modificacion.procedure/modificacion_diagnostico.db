USE Sistema_Medico;

-- DIAGNOSTICO

-- VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_diagnostico;
DELIMITER //
CREATE FUNCTION fn_validar_diagnostico(p_cita VARCHAR(10)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF NOT EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cita) THEN 
        RETURN 'Error: Cita no existe';
    ELSE 
        RETURN 'OK';
    END IF;
END //
DELIMITER ;


-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_diagnostico;
DELIMITER //
CREATE PROCEDURE sp_crear_diagnostico(IN p_cita VARCHAR(10), IN p_desc TEXT)
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Diagnosticos', 'sp_crear_diagnostico', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo guardar el diagnóstico' AS Mensaje;
    END;

    SET v_valida = fn_validar_diagnostico(p_cita);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;
            -- USO DE PREPARE Y EXECUTE
            SET @query = 'INSERT INTO Diagnosticos (cod_cita, descripcion) VALUES (?, ?)';
            SET @c = p_cita, @d = p_desc;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @c, @d;
            DEALLOCATE PREPARE stmt;
        COMMIT;
        SELECT 'ÉXITO: Diagnóstico guardado' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- LISTAR 
DROP PROCEDURE IF EXISTS sp_leer_diagnostico;
CREATE PROCEDURE sp_leer_diagnostico(IN p_cita VARCHAR(10))
BEGIN
    -- USO DE PREPARE Y EXECUTE
    SET @query = 'SELECT * FROM Diagnosticos WHERE cod_cita = ?';
    SET @c = p_cita;
    PREPARE stmt FROM @query;
    EXECUTE stmt USING @c;
    DEALLOCATE PREPARE stmt;
END //

-- ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_diagnostico;
CREATE PROCEDURE sp_actualizar_diagnostico(IN p_cita VARCHAR(10), IN p_nueva_desc TEXT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Diagnosticos', 'sp_actualizar_diagnostico', @errno, @msg);
        SELECT 'ERROR SISTEMA: Fallo al actualizar diagnóstico' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM Diagnosticos WHERE cod_cita = p_cita) THEN
            -- USO DE PREPARE Y EXECUTE
            SET @query = 'UPDATE Diagnosticos SET descripcion = ? WHERE cod_cita = ?';
            SET @d = p_nueva_desc, @c = p_cita;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @d, @c;
            DEALLOCATE PREPARE stmt;
            COMMIT;
            SELECT 'ÉXITO: Diagnóstico actualizado' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: No hay diagnóstico registrado para esta cita' AS Mensaje; 
        END IF;
END //

-- ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_diagnostico;
CREATE PROCEDURE sp_eliminar_diagnostico(IN p_cita VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: No se pudo eliminar el diagnóstico' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM Diagnosticos WHERE cod_cita = p_cita) THEN
            -- USO DE PREPARE Y EXECUTE
            SET @query = 'DELETE FROM Diagnosticos WHERE cod_cita = ?';
            SET @c = p_cita;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @c;
            DEALLOCATE PREPARE stmt;
            COMMIT;
            SELECT 'ÉXITO: Diagnóstico eliminado' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El diagnóstico no existe' AS Mensaje; 
        END IF;
END //
DELIMITER ;