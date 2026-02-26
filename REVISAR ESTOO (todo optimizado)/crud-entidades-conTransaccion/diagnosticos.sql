USE sistema_medicos;

DELIMITER //

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_diagnostico //
CREATE FUNCTION fn_validar_diagnostico(p_id_cita INT, p_desc VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF NOT EXISTS(SELECT 1 FROM citas WHERE id_cita = p_id_cita) THEN 
        RETURN 'Error: La cita médica no existe';
    ELSEIF p_desc = '' THEN
        RETURN 'Error: La descripción no puede estar vacía';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR 
DROP PROCEDURE IF EXISTS sp_crear_diagnostico //
CREATE PROCEDURE sp_crear_diagnostico(IN p_id_cita INT, IN p_descripcion VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('diagnosticos', 'INSERT_DIAG', @errno, @msg);
        SELECT CONCAT('ERROR DE SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_diagnostico(p_id_cita, p_descripcion);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;

            SET @stmt_ins_diag = 'INSERT INTO diagnosticos (nombre, id_cita) VALUES (?, ?)';
            SET @d_txt = p_descripcion, @c_id = p_id_cita;
            
            PREPARE query_ins_diag FROM @stmt_ins_diag;
            EXECUTE query_ins_diag USING @d_txt, @c_id;
            DEALLOCATE PREPARE query_ins_diag;
        COMMIT;
        SELECT 'ÉXITO: Diagnóstico guardado' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_leer_diagnostico //
CREATE PROCEDURE sp_leer_diagnostico(IN p_id_cita INT)
BEGIN

    SELECT 
        d.id_diagnostico AS 'Folio Diag',
        d.nombre AS 'Diagnóstico',
        c.fecha_cita AS 'Fecha'
    FROM diagnosticos d
    INNER JOIN citas c ON d.id_cita = c.id_cita 
    WHERE c.id_cita = p_id_cita;
END //

DELIMITER ;

-- C. ACTUALIZAR
DELIMITER //

DROP PROCEDURE IF EXISTS sp_actualizar_diagnostico //
CREATE PROCEDURE sp_actualizar_diagnostico(
    IN p_id_diag INT, 
    IN p_nueva_desc VARCHAR(100)
)
BEGIN
    -- Manejador de errores con Rollback y registro en logs
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('diagnosticos', 'UPDATE_DIAG', @errno, @msg);
        SELECT 'ERROR: No se pudo actualizar el diagnóstico' AS Mensaje;
    END;

    START TRANSACTION;

        IF EXISTS(SELECT 1 FROM diagnosticos WHERE id_diagnostico = p_id_diag) THEN
            SET @stmt_upd_diag = 'UPDATE diagnosticos SET nombre = ? WHERE id_diagnostico = ?';
            SET @new_txt = p_nueva_desc, @target_id = p_id_diag;
            
            PREPARE query_upd_diag FROM @stmt_upd_diag;
            EXECUTE query_upd_diag USING @new_txt, @target_id;
            DEALLOCATE PREPARE query_upd_diag;
            
            COMMIT;
            SELECT 'ÉXITO: Diagnóstico actualizado correctamente' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El ID de diagnóstico no existe' AS Mensaje; 
        END IF;
END //

-- D.ELIMINAR

DROP PROCEDURE IF EXISTS sp_eliminar_diagnostico //
CREATE PROCEDURE sp_eliminar_diagnostico(IN p_id_diag INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('diagnosticos', 'DELETE_DIAG', @errno, @msg);
        SELECT 'ERROR: Fallo técnico al intentar eliminar el registro' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM diagnosticos WHERE id_diagnostico = p_id_diag) THEN
            SET @stmt_del_diag = 'DELETE FROM diagnosticos WHERE id_diagnostico = ?';
            SET @del_target = p_id_diag;
            
            PREPARE query_del_diag FROM @stmt_del_diag;
            EXECUTE query_del_diag USING @del_target;
            DEALLOCATE PREPARE query_del_diag;
            
            COMMIT;
            SELECT 'ÉXITO: Registro de diagnóstico eliminado' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El registro no existe' AS Mensaje; 
        END IF;
END //

DELIMITER ;