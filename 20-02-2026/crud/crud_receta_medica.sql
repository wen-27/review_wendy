-- VALIDAR RECETA_CITA 

use Sistema_Medico;

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

-- CRUD 

-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_receta;
DELIMITER //
CREATE PROCEDURE sp_crear_receta(IN p_cita VARCHAR(10), IN p_med VARCHAR(100), IN p_dosis VARCHAR(50))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('receta_cita', 'sp_crear_receta', v_errno, v_msg);
        SELECT 'ERROR SISTEMA: Fallo al registrar receta' AS Mensaje;
    END;

    SET v_valida = fn_validar_receta(p_cita, p_med);
    IF v_valida = 'OK' THEN
        INSERT INTO receta_cita (cod_cita, medicamento, dosis) VALUES (p_cita, p_med, p_dosis);
        SELECT 'ÉXITO: Medicamento agregado' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //
DELIMITER ;

-- LEER 
DROP PROCEDURE IF EXISTS sp_listar_receta_cita;
DELIMITER //
CREATE PROCEDURE sp_listar_receta_cita(IN p_cita VARCHAR(10))
BEGIN
    SELECT * FROM receta_cita WHERE cod_cita = p_cita;
END //
DELIMITER ;

-- ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_receta;
DELIMITER //
CREATE PROCEDURE sp_actualizar_receta(
    IN p_cita VARCHAR(10), 
    IN p_med VARCHAR(100), 
    IN p_nueva_dosis VARCHAR(50)
)
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('receta_cita', 'sp_actualizar_receta', v_errno, v_msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar la dosis' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM receta_cita WHERE cod_cita = p_cita AND medicamento = p_med) THEN
        UPDATE receta_cita 
        SET dosis = p_nueva_dosis 
        WHERE cod_cita = p_cita AND medicamento = p_med;
        SELECT 'ÉXITO: Dosis actualizada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: El medicamento no existe en esta receta' AS Mensaje; 
    END IF;
END //
DELIMITER ;

-- ELIMINAR 
DROP PROCEDURE IF EXISTS sp_eliminar_medicamento;
DELIMITER //
CREATE PROCEDURE sp_eliminar_medicamento(IN p_cita VARCHAR(10), IN p_med VARCHAR(100))
BEGIN
    IF EXISTS(SELECT 1 FROM receta_cita WHERE cod_cita = p_cita AND medicamento = p_med) THEN
        DELETE FROM receta_cita WHERE cod_cita = p_cita AND medicamento = p_med;
        SELECT 'ÉXITO: Medicamento removido' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: Registro no encontrado' AS Mensaje; 
    END IF;
END //
DELIMITER ;