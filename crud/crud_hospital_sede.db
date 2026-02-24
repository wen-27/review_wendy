-- validacion hospital sede 

use Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_sede;
DELIMITER //
CREATE FUNCTION fn_validar_sede(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' THEN RETURN 'Error: ID requerido';
    ELSEIF EXISTS(SELECT 1 FROM Hospital_Sede WHERE id_hospital = p_id) THEN RETURN 'Error: ID duplicado';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- crud hospital sede 

-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_sede;
DELIMITER //
CREATE PROCEDURE sp_crear_sede(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Hospital_Sede', 'sp_crear_sede', v_errno, v_msg);
        SELECT CONCAT('ERROR SISTEMA: ', v_msg) AS Mensaje;
    END;
    SET v_valida = fn_validar_sede(p_id, p_nombre, 'INSERT');
    IF v_valida = 'OK' THEN
        INSERT INTO Hospital_Sede (id_hospital, nombre) VALUES (p_id, p_nombre);
        SELECT 'ÉXITO: Sede guardada' AS Mensaje;
    ELSE SELECT v_valida AS Mensaje; END IF;
END //

-- LEER
CREATE PROCEDURE sp_listar_sedes()
BEGIN
    SELECT * FROM Hospital_Sede;
END //

DELIMITER //

-- ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_sede;
CREATE PROCEDURE sp_actualizar_sede(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('Hospital_Sede', 'sp_actualizar_sede', v_errno, v_msg);
        SELECT CONCAT('ERROR SISTEMA: ', v_msg) AS Mensaje;
    END;

    -- Llamamos a la validación con el modo 'UPDATE'
    SET v_valida = fn_validar_sede(p_id, p_nombre, 'UPDATE');
    
    IF v_valida = 'OK' THEN
        UPDATE Hospital_Sede 
        SET nombre = p_nombre 
        WHERE id_hospital = p_id;
        
        SELECT 'ÉXITO: Sede actualizada correctamente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

DELIMITER ;

-- ELIMINAR
CREATE PROCEDURE sp_eliminar_sede(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        SELECT 'ERROR: No se puede borrar, sede tiene citas vinculadas' AS Mensaje;
    END;
    DELETE FROM Hospital_Sede WHERE id_hospital = p_id;
    SELECT 'ÉXITO: Sede eliminada' AS Mensaje;
END //
DELIMITER ;

