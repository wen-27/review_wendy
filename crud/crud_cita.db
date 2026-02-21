USE Sistema_Medico;

-- VALIDACIÓN CITA
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

-- CRUD

--  CREAR
DROP PROCEDURE IF EXISTS sp_crear_cita;
DELIMITER //
CREATE PROCEDURE sp_crear_cita(
    IN p_cod VARCHAR(10), 
    IN p_fec DATE, 
    IN p_pac VARCHAR(10), 
    IN p_med VARCHAR(10), 
    IN p_sed VARCHAR(10)
)
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_crear_cita', v_errno, v_msg);
        SELECT 'ERROR SISTEMA: Verifique integridad de datos' AS Mensaje;
    END;

    SET v_valida = fn_validar_cita(p_cod, p_med);
    IF v_valida = 'OK' THEN
        INSERT INTO cita (Cod_Cita, Fecha, Cod_paciente, Cod_medico, Hospital_Sede)
        VALUES (p_cod, p_fec, p_pac, p_med, p_sed);
        SELECT 'ÉXITO: Cita registrada' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //
DELIMITER ;

-- LEER
DROP PROCEDURE IF EXISTS sp_listar_citas;
DELIMITER //
CREATE PROCEDURE sp_listar_citas()
BEGIN
    SELECT * FROM cita;
END //
DELIMITER ;

-- ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_cita;
DELIMITER //
CREATE PROCEDURE sp_actualizar_cita(
    IN p_cod VARCHAR(10), 
    IN p_nueva_fecha DATE, 
    IN p_nuevo_medico VARCHAR(10),
    IN p_nueva_sede VARCHAR(10)
)
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE v_existe_cita INT;
    DECLARE v_existe_medico INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('cita', 'sp_actualizar_cita', v_errno, v_msg);
        SELECT CONCAT('ERROR SISTEMA: ', v_msg) AS Mensaje;
    END;

    SELECT COUNT(*) INTO v_existe_cita FROM cita WHERE Cod_Cita = p_cod;
    SELECT COUNT(*) INTO v_existe_medico FROM MEDICOSSS WHERE Medico_ID = p_nuevo_medico;

    IF v_existe_cita = 0 THEN
        SELECT 'VALIDACIÓN: Error, la cita no existe.' AS Mensaje;
    ELSEIF v_existe_medico = 0 THEN
        SELECT 'VALIDACIÓN: Error, el médico no existe.' AS Mensaje;
    ELSE
        UPDATE cita 
        SET Fecha = p_nueva_fecha, 
            Cod_medico = p_nuevo_medico,
            Hospital_Sede = p_nueva_sede
        WHERE Cod_Cita = p_cod;
        SELECT 'ÉXITO: Cita actualizada' AS Mensaje;
    END IF;
END //
DELIMITER ;

-- ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_cita;
DELIMITER //
CREATE PROCEDURE sp_eliminar_cita(IN p_cod VARCHAR(10))
BEGIN
    IF EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cod) THEN
        DELETE FROM cita WHERE Cod_Cita = p_cod;
        SELECT 'ÉXITO: Cita borrada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: Cita no existe' AS Mensaje; 
    END IF;
END //
DELIMITER ;