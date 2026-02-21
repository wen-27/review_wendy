-- VALIDACION FACULTAD_NOMBRE

use Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_facultad;
DELIMITER //
CREATE FUNCTION fn_validar_facultad(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' OR p_nombre = '' THEN RETURN 'Error: Datos incompletos';
    ELSEIF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN RETURN 'Error: Facultad ya existe';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- CRUD 

-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_facultad;
DELIMITER //
CREATE PROCEDURE sp_crear_facultad(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultad_nombres', 'sp_crear_facultad', v_errno, v_msg);
        SELECT CONCAT('SISTEMA: ', v_msg) AS Mensaje;
    END;
    SET v_valida = fn_validar_facultad(p_id, p_nombre);
    IF v_valida = 'OK' THEN
        INSERT INTO facultad_nombres (id_facultad, nombre) VALUES (p_id, p_nombre);
        SELECT 'ÉXITO: Facultad registrada' AS Mensaje;
    ELSE SELECT v_valida AS Mensaje; END IF;
END //

-- LEER
CREATE PROCEDURE sp_listar_facultades()
BEGIN
    SELECT * FROM facultad_nombres;
END //

-- ACTUALIZAR
CREATE PROCEDURE sp_actualizar_facultad(IN p_id VARCHAR(10), IN p_nuevo_nom VARCHAR(100))
BEGIN
    IF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN
        UPDATE facultad_nombres SET nombre = p_nuevo_nom WHERE id_facultad = p_id;
        SELECT 'ÉXITO: Facultad actualizada' AS Mensaje;
    ELSE SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; END IF;
END //
DELIMITER ;

-- ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_facultad;
DELIMITER //
CREATE PROCEDURE sp_eliminar_facultad(IN p_id VARCHAR(10))
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('facultad_nombres', 'sp_eliminar_facultad', v_errno, v_msg);
        SELECT 'ERROR: No se puede eliminar la facultad porque tiene médicos asignados.' AS Mensaje;
    END;

    IF EXISTS(SELECT 1 FROM facultad_nombres WHERE id_facultad = p_id) THEN
        DELETE FROM facultad_nombres WHERE id_facultad = p_id;
        SELECT 'ÉXITO: Facultad eliminada' AS Mensaje;
    ELSE 
        SELECT 'VALIDACIÓN: La facultad no existe.' AS Mensaje; 
    END IF;
END //
DELIMITER ;