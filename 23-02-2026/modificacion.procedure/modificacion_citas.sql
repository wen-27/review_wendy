USE Sistema_Medico;

-- 1. VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_cita;
DELIMITER //
CREATE FUNCTION fn_validar_cita(p_cod VARCHAR(10), p_medico VARCHAR(10)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cod) THEN 
        RETURN 'Error: Cita ya existe';
    ELSEIF NOT EXISTS(SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_medico) THEN 
        RETURN 'Error: Médico no existe';
    ELSE 
        RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- A. CREAR (CREATE)
DROP PROCEDURE IF EXISTS sp_crear_cita;
DELIMITER //
CREATE PROCEDURE sp_crear_cita(
    IN p_cod VARCHAR(10), IN p_fec DATE, IN p_pac VARCHAR(10), 
    IN p_med VARCHAR(10), IN p_sed VARCHAR(10)
)
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_crear_cita', @errno, @msg);
        SELECT CONCAT('ERROR CRÍTICO: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_cita(p_cod, p_med);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;
            SET @query = 'INSERT INTO cita (Cod_Cita, Fecha, Cod_paciente, Cod_medico, Hospital_Sede) VALUES (?, ?, ?, ?, ?)';
            SET @p1 = p_cod, @p2 = p_fec, @p3 = p_pac, @p4 = p_med, @p5 = p_sed;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @p1, @p2, @p3, @p4, @p5;
            DEALLOCATE PREPARE stmt;
        COMMIT;
        SELECT 'ÉXITO: Cita registrada satisfactoriamente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_citas;
CREATE PROCEDURE sp_listar_citas()
BEGIN
    SET @sql = 'SELECT Cod_Cita, Fecha, Cod_paciente, Cod_medico, Hospital_Sede FROM cita';
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- C. ACTUALIZAR (UPDATE)
DROP PROCEDURE IF EXISTS sp_actualizar_cita;
CREATE PROCEDURE sp_actualizar_cita(
    IN p_cod VARCHAR(10), IN p_nueva_fecha DATE, 
    IN p_nuevo_medico VARCHAR(10), IN p_nueva_sede VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_actualizar_cita', @errno, @msg);
        SELECT 'ERROR: No se pudo actualizar la cita' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cod) THEN
            SET @query = 'UPDATE cita SET Fecha = ?, Cod_medico = ?, Hospital_Sede = ? WHERE Cod_Cita = ?';
            SET @f = p_nueva_fecha, @m = p_nuevo_medico, @s = p_nueva_sede, @c = p_cod;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @f, @m, @s, @c;
            DEALLOCATE PREPARE stmt;
            COMMIT;
            SELECT 'ÉXITO: Cita actualizada' AS Mensaje;
        ELSE
            ROLLBACK;
            SELECT 'VALIDACIÓN: La cita no existe' AS Mensaje;
        END IF;
END //

-- D. ELIMINAR 
DROP PROCEDURE IF EXISTS sp_eliminar_cita;
CREATE PROCEDURE sp_eliminar_cita(IN p_cod VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: Error de integridad al eliminar' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cod) THEN
            SET @query = 'DELETE FROM cita WHERE Cod_Cita = ?';
            SET @c = p_cod;
            PREPARE stmt FROM @query;
            EXECUTE stmt USING @c;
            DEALLOCATE PREPARE stmt;
            COMMIT;
            SELECT 'ÉXITO: Cita eliminada' AS Mensaje;
        ELSE
            ROLLBACK;
            SELECT 'VALIDACIÓN: Cita no encontrada' AS Mensaje;
        END IF;
END //
DELIMITER ;

-- ===============================================
-- MÉTODO REPAIR: Reparar tabla de citas
-- ===============================================

CREATE TABLE IF NOT EXISTS tbl_repair_log (
    id_repair INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tabla VARCHAR(100),
    tipo_operacion VARCHAR(20),
    resultado VARCHAR(50),
    mensaje TEXT,
    usuario_ejecuto VARCHAR(50),
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS sp_repair_cita;
DELIMITER //
CREATE PROCEDURE sp_repair_cita(IN p_usuario VARCHAR(50))
BEGIN
    DECLARE v_errno INT DEFAULT 0;
    DECLARE v_msg TEXT DEFAULT '';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_repair_cita', v_errno, v_msg);
        INSERT INTO tbl_repair_log (nombre_tabla, tipo_operacion, resultado, mensaje, usuario_ejecuto)
        VALUES ('cita', 'REPAIR', 'ERROR', v_msg, p_usuario);
        SELECT 'ERROR' AS Resultado, v_msg AS Mensaje;
    END;
    
    SET @sql_repair = 'REPAIR TABLE cita';
    PREPARE stmt FROM @sql_repair;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @sql_optimize = 'OPTIMIZE TABLE cita';
    PREPARE stmt FROM @sql_optimize;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    INSERT INTO tbl_repair_log (nombre_tabla, tipo_operacion, resultado, mensaje, usuario_ejecuto)
    VALUES ('cita', 'REPAIR', 'EXITO', 'Tabla cita reparada y optimizada', p_usuario);
    
    SELECT 'EXITO' AS Resultado, 'Tabla cita reparada y optimizada' AS Mensaje;
END //
DELIMITER ;

-- ===============================================
-- MÉTODO EXECUTE: Ejecutar consulta dinámica
-- ===============================================

DROP PROCEDURE IF EXISTS sp_execute_cita;
DELIMITER //
CREATE PROCEDURE sp_execute_cita(
    IN p_consulta TEXT,
    IN p_tipo_usuario VARCHAR(20),
    IN p_usuario VARCHAR(50)
)
BEGIN
    DECLARE v_inicio DATETIME;
    DECLARE v_fin DATETIME;
    DECLARE v_tiempo INT;
    DECLARE v_errno INT DEFAULT 0;
    DECLARE v_msg TEXT DEFAULT '';
    
    SET v_inicio = NOW();
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_fin = NOW();
        SET v_tiempo = TIMESTAMPDIFF(MICROSECOND, v_inicio, v_fin) / 1000;
        
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_execute_cita', v_errno, v_msg);
        
        SELECT 'ERROR' AS Resultado, v_msg AS Mensaje, v_tiempo AS Tiempo_MS;
    END;
    
    IF p_consulta LIKE '%DROP%' OR p_consulta LIKE '%TRUNCATE%' OR p_consulta LIKE '%ALTER%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta no permitida: comandos DDL no autorizados.';
    END IF;
    
    SET @sql_exec = p_consulta;
    PREPARE stmt FROM @sql_exec;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET v_fin = NOW();
    SET v_tiempo = TIMESTAMPDIFF(MICROSECOND, v_inicio, v_fin) / 1000;
    
    SELECT 'EXITO' AS Resultado, 'Consulta ejecutada' AS Mensaje, v_tiempo AS Tiempo_MS;
END //
DELIMITER ;
