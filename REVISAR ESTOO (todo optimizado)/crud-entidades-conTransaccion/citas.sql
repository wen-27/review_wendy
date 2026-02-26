USE sistema_medicos;

DELIMITER //

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_cita //
CREATE FUNCTION fn_validar_cita(p_id_cita INT, p_id_medico INT) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF EXISTS(SELECT 1 FROM citas WHERE id_cita = p_id_cita) THEN 
        RETURN 'Error: El código de cita ya está registrado';
    ELSEIF NOT EXISTS(SELECT 1 FROM medicos WHERE id_medico = p_id_medico) THEN 
        RETURN 'Error: El médico seleccionado no existe';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR
DROP PROCEDURE IF EXISTS sp_crear_cita //
CREATE PROCEDURE sp_crear_cita(
    IN p_id INT, 
    IN p_pac INT, 
    IN p_med INT, 
    IN p_fec DATETIME, 
    IN p_diag INT, 
    IN p_sed INT
)
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('citas', 'INSERT', @errno, @msg);
        SELECT CONCAT('ERROR CRÍTICO: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_cita(p_id, p_med);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;

            SET @stmt_ins = 'INSERT INTO citas (id_cita, id_paciente, id_medico, fecha_cita, id_diagnostico, id_sede) VALUES (?, ?, ?, ?, ?, ?)';
            SET @p1=p_id, @p2=p_pac, @p3=p_med, @p4=p_fec, @p5=p_diag, @p6=p_sed;
            PREPARE query_ins FROM @stmt_ins;
            EXECUTE query_ins USING @p1, @p2, @p3, @p4, @p5, @p6;
            DEALLOCATE PREPARE query_ins;
        COMMIT;
        SELECT 'ÉXITO: Cita registrada en su partición correspondiente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_citas //
CREATE PROCEDURE sp_listar_citas()
BEGIN

    SELECT id_cita, fecha_cita, id_paciente, id_medico, id_sede 
    FROM citas 
    ORDER BY fecha_cita DESC;
END //

-- C. ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_cita //
CREATE PROCEDURE sp_actualizar_cita(
    IN p_id INT, 
    IN p_fec_actual DATETIME, 
    IN p_nueva_fec DATETIME, 
    IN p_nuevo_med INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('citas', 'UPDATE', @errno, @msg);
        SELECT 'ERROR: No se pudo actualizar el registro' AS Mensaje;
    END;

    START TRANSACTION;

        SET @stmt_upd = 'UPDATE citas SET fecha_cita = ?, id_medico = ? WHERE id_cita = ? AND fecha_cita = ?';
        SET @uf1=p_nueva_fec, @um1=p_nuevo_med, @uid1=p_id, @uf_act=p_fec_actual;
        
        PREPARE query_upd FROM @stmt_upd;
        EXECUTE query_upd USING @uf1, @um1, @uid1, @uf_act;
        
        IF ROW_COUNT() > 0 THEN
            COMMIT;
            SELECT 'ÉXITO: Cita reprogramada correctamente' AS Mensaje;
        ELSE
            ROLLBACK;
            SELECT 'VALIDACIÓN: No se encontró la cita con esos datos' AS Mensaje;
        END IF;
        DEALLOCATE PREPARE query_upd;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_cita //
CREATE PROCEDURE sp_eliminar_cita(IN p_id INT, IN p_fec DATETIME)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('citas', 'DELETE', @errno, @msg);
        SELECT 'ERROR: Fallo de integridad al eliminar' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM citas WHERE id_cita = p_id AND fecha_cita = p_fec) THEN

            DELETE FROM recetas WHERE id_cita = p_id;

            SET @stmt_del = 'DELETE FROM citas WHERE id_cita = ? AND fecha_cita = ?';
            SET @did = p_id, @df = p_fec;
            PREPARE query_del FROM @stmt_del;
            EXECUTE query_del USING @did, @df;
            DEALLOCATE PREPARE query_del;
            
            COMMIT;
            SELECT 'ÉXITO: Cita y sus recetas han sido eliminadas' AS Mensaje;
        ELSE
            ROLLBACK;
            SELECT 'VALIDACIÓN: El registro no existe en la partición indicada' AS Mensaje;
        END IF;
END //

-- E. MANTENIMIENTO 
DROP PROCEDURE IF EXISTS sp_mantenimiento_citas //
CREATE PROCEDURE sp_mantenimiento_citas()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('citas', 'MAINTENANCE', @errno, @msg);
        SELECT 'ERROR' AS Resultado, @msg AS Mensaje;
    END;
    
    -- Organiza los datos físicamente para mejorar el rendimiento de búsqueda
    OPTIMIZE TABLE citas;
    SELECT 'EXITO' AS Resultado, 'Particiones de citas optimizadas' AS Mensaje;
END //

-- F. EJECUTOR SEGURO 
DROP PROCEDURE IF EXISTS sp_execute_dinamico //
CREATE PROCEDURE sp_execute_dinamico(IN p_consulta TEXT)
BEGIN

    IF p_consulta LIKE '%DROP%' OR p_consulta LIKE '%TRUNCATE%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operación DDL no permitida por seguridad.';
    END IF;

    SET @sql_custom = p_consulta;
    PREPARE stmt_dyn FROM @sql_custom;
    EXECUTE stmt_dyn;
    DEALLOCATE PREPARE stmt_dyn;
END //

DELIMITER ;