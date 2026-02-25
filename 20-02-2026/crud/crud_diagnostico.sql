-- VALIDACION DIAGNOSTICO 

use Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_diagnostico;
DELIMITER //
CREATE FUNCTION fn_validar_diagnostico(p_cita VARCHAR(10)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF NOT EXISTS(SELECT 1 FROM cita WHERE Cod_Cita = p_cita) THEN RETURN 'Error: Cita no existe';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- CRUD

-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_diagnostico;
DELIMITER //
CREATE PROCEDURE sp_crear_diagnostico(IN p_cita VARCHAR(10), IN p_desc TEXT)
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Diagnosticos', 'sp_crear_diagnostico', v_errno, v_msg);
        SELECT 'ERROR SISTEMA: No se pudo guardar el diagnóstico' AS Mensaje;
    END;
    SET v_valida = fn_validar_diagnostico(p_cita);
    IF v_valida = 'OK' THEN
        INSERT INTO Diagnosticos (cod_cita, descripcion) VALUES (p_cita, p_desc);
        SELECT 'ÉXITO: Diagnóstico guardado' AS Mensaje;
    ELSE SELECT v_valida AS Mensaje; END IF;
END //

-- LEER 
CREATE PROCEDURE sp_leer_diagnostico(IN p_cita VARCHAR(10))
BEGIN
    SELECT * FROM Diagnosticos WHERE cod_cita = p_cita;
END //
DELIMITER ;

-- ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_diagnostico;
DELIMITER //
CREATE PROCEDURE sp_actualizar_diagnostico(IN p_cita VARCHAR(10), IN p_nueva_desc TEXT)
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Diagnosticos', 'sp_actualizar_diagnostico', v_errno, v_msg);
        SELECT 'ERROR SISTEMA: Fallo al actualizar diagnóstico' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM Diagnosticos WHERE cod_cita = p_cita) THEN
        UPDATE Diagnosticos SET descripcion = p_nueva_desc WHERE cod_cita = p_cita;
        SELECT 'ÉXITO: Diagnóstico actualizado' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: No hay diagnóstico registrado para esta cita' AS Mensaje; 
    END IF;
END //
DELIMITER ;

-- ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_diagnostico;
DELIMITER //
CREATE PROCEDURE sp_eliminar_diagnostico(IN p_cita VARCHAR(10))
BEGIN
    IF EXISTS(SELECT 1 FROM Diagnosticos WHERE cod_cita = p_cita) THEN
        DELETE FROM Diagnosticos WHERE cod_cita = p_cita;
        SELECT 'ÉXITO: Diagnóstico eliminado' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: El diagnóstico no existe' AS Mensaje; 
    END IF;
END //
DELIMITER ;