USE Sistema_Medicos;

DELIMITER //

-- 1. FUNCIÓN DE VALIDACIÓN (
DROP FUNCTION IF EXISTS fn_validar_sede //
CREATE FUNCTION fn_validar_sede(p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_nombre = '' OR p_nombre IS NULL THEN 
        RETURN 'Error: El nombre de la sede es obligatorio';
    ELSEIF EXISTS(SELECT 1 FROM sedes_hospital WHERE nombre = p_nombre) THEN 
        RETURN 'Error: Ya existe una sede con ese nombre';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR 
DROP PROCEDURE IF EXISTS sp_crear_sede //
CREATE PROCEDURE sp_crear_sede(IN p_nombre VARCHAR(100), IN p_direccion VARCHAR(255))
BEGIN
    DECLARE v_valida VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('sedes_hospital', 'sp_crear_sede', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END;

    SET v_valida = fn_validar_sede(p_nombre);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;
            INSERT INTO sedes_hospital (nombre, direccion) VALUES (p_nombre, p_direccion);
        COMMIT;
        SELECT 'ÉXITO: Sede registrada correctamente' AS Mensaje;
    ELSE 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_valida;
    END IF;
END //

-- B. LEER (Aquí estaba el error 1064, faltaba el SELECT)
DROP PROCEDURE IF EXISTS sp_listar_sedes //
CREATE PROCEDURE sp_listar_sedes()
BEGIN
    SELECT 
        id_sede AS 'ID', 
        nombre AS 'Nombre de Sede', 
        direccion AS 'Dirección' 
    FROM sedes_hospital
    ORDER BY id_sede DESC;
END //

-- C. ACTUALIZAR
DROP PROCEDURE IF EXISTS sp_actualizar_sede //
CREATE PROCEDURE sp_actualizar_sede(IN p_id INT, IN p_nuevo_nom VARCHAR(100), IN p_nueva_dir VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('sedes_hospital', 'sp_actualizar_sede', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar sede';
    END;

    IF NOT EXISTS(SELECT 1 FROM sedes_hospital WHERE id_sede = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID de sede no encontrado';
    ELSE
        START TRANSACTION;
            UPDATE sedes_hospital 
            SET nombre = p_nuevo_nom, direccion = p_nueva_dir 
            WHERE id_sede = p_id;
        COMMIT;
        SELECT 'ÉXITO: Sede actualizada' AS Mensaje;
    END IF;
END //

-- D. ELIMINAR
DROP PROCEDURE IF EXISTS sp_eliminar_sede //
CREATE PROCEDURE sp_eliminar_sede(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('sedes_hospital', 'sp_eliminar_sede', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La sede tiene registros vinculados (médicos o citas)';
    END;

    IF NOT EXISTS(SELECT 1 FROM sedes_hospital WHERE id_sede = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sede no existe';
    ELSE
        START TRANSACTION;
            DELETE FROM sedes_hospital WHERE id_sede = p_id;
        COMMIT;
        SELECT 'ÉXITO: Sede eliminada' AS Mensaje;
    END IF;
END //

DELIMITER ;