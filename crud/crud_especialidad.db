-- validacion especialidad

use Sistema_Medico;

DROP FUNCTION IF EXISTS fn_validar_especialidad;
DELIMITER //
CREATE FUNCTION fn_validar_especialidad(p_id VARCHAR(10), p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_id = '' OR p_nombre = '' THEN RETURN 'Error: Campos vacíos';
    ELSEIF EXISTS(SELECT 1 FROM especialidades WHERE ID_especialida = p_id) THEN RETURN 'Error: ID duplicado';
    ELSE RETURN 'OK';
    END IF;
END //
DELIMITER ;

-- crud especialidad

-- CREAR
DROP PROCEDURE IF EXISTS sp_crear_especialidad;
DELIMITER //
CREATE PROCEDURE sp_crear_especialidad(IN p_id VARCHAR(10), IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_crear_especialidad', v_errno, v_msg);
        SELECT CONCAT('ERROR SISTEMA: ', v_msg) AS Mensaje;
    END;
    SET v_valida = fn_validar_especialidad(p_id, p_nombre);
    IF v_valida = 'OK' THEN
        INSERT INTO especialidades (ID_especialida, Nombre_especialidad) VALUES (p_id, p_nombre);
        SELECT 'ÉXITO: Especialidad registrada' AS Mensaje;
    ELSE SELECT v_valida AS Mensaje; END IF;
END //

-- LEER
CREATE PROCEDURE sp_listar_especialidades()
BEGIN
    SELECT * FROM especialidades;
END //

-- ACTUALIZAR
CREATE PROCEDURE sp_actualizar_especialidad(IN p_id VARCHAR(10), IN p_nuevo_nom VARCHAR(100))
BEGIN
    IF EXISTS(SELECT 1 FROM especialidades WHERE ID_especialida = p_id) THEN
        UPDATE especialidades SET Nombre_especialidad = p_nuevo_nom WHERE ID_especialida = p_id;
        SELECT 'ÉXITO: Especialidad actualizada' AS Mensaje;
    ELSE SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; END IF;
END //

-- ELIMINAR
CREATE PROCEDURE sp_eliminar_especialidad(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        SELECT 'ERROR: No se puede eliminar, hay médicos asociados' AS Mensaje;
    END;
    DELETE FROM especialidades WHERE ID_especialida = p_id;
    SELECT 'ÉXITO: Especialidad eliminada' AS Mensaje;
END //
DELIMITER ;