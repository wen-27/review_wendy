USE Sistema_Medicos;

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_especialidad;
DELIMITER //
CREATE FUNCTION fn_validar_especialidad(p_nombre VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_nombre = '' THEN 
        RETURN 'Error: El nombre de la especialidad es obligatorio';
    -- Validamos duplicados por nombre, ya que el ID es automático
    ELSEIF EXISTS(SELECT 1 FROM especialidades WHERE nombre = p_nombre) THEN 
        RETURN 'Error: Esta especialidad ya está registrada';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR 
DROP PROCEDURE IF EXISTS sp_crear_especialidad;
//
CREATE PROCEDURE sp_crear_especialidad(IN p_nombre VARCHAR(100))
BEGIN
    DECLARE v_valida VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_crear_especialidad', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_especialidad(p_nombre);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;

            SET @sql_ins_esp = 'INSERT INTO especialidades (nombre) VALUES (?)';
            SET @nom_esp = p_nombre;
            PREPARE stmt_ins_esp FROM @sql_ins_esp;
            EXECUTE stmt_ins_esp USING @nom_esp;
            DEALLOCATE PREPARE stmt_ins_esp;
        COMMIT;
        SELECT 'ÉXITO: Especialidad registrada correctamente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER
DROP PROCEDURE IF EXISTS sp_listar_especialidades;
//
CREATE PROCEDURE sp_listar_especialidades()
BEGIN

    SELECT 
        id_especialidad AS 'ID', 
        nombre AS 'Especialidad' 
    FROM especialidades 
    ORDER BY nombre ASC;
END //

-- C. ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_especialidad;
//
CREATE PROCEDURE sp_actualizar_especialidad(IN p_id INT, IN p_nuevo_nom VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_actualizar_especialidad', @errno, @msg);
        SELECT 'ERROR SISTEMA: Fallo al actualizar' AS Mensaje;
    END;

    START TRANSACTION;

        IF EXISTS(SELECT 1 FROM especialidades WHERE id_especialidad = p_id) THEN
            SET @sql_upd_esp = 'UPDATE especialidades SET nombre = ? WHERE id_especialidad = ?';
            SET @unom = p_nuevo_nom, @uid = p_id;
            PREPARE stmt_upd_esp FROM @sql_upd_esp;
            EXECUTE stmt_upd_esp USING @unom, @uid;
            DEALLOCATE PREPARE stmt_upd_esp;
            COMMIT;
            SELECT 'ÉXITO: Especialidad actualizada' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El ID de especialidad no existe' AS Mensaje; 
        END IF;
END //

-- D. ELIMINAR 
DROP PROCEDURE IF EXISTS sp_eliminar_especialidad;
//
CREATE PROCEDURE sp_eliminar_especialidad(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('especialidades', 'sp_eliminar_especialidad', @errno, @msg);
        SELECT 'ERROR: No se puede eliminar (probablemente hay médicos asignados a esta especialidad)' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM especialidades WHERE id_especialidad = p_id) THEN
            SET @sql_del_esp = 'DELETE FROM especialidades WHERE id_especialidad = ?';
            SET @did = p_id;
            PREPARE stmt_del_esp FROM @sql_del_esp;
            EXECUTE stmt_del_esp USING @did;
            DEALLOCATE PREPARE stmt_del_esp;
            COMMIT;
            SELECT 'ÉXITO: Especialidad eliminada' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: ID no existe' AS Mensaje; 
        END IF;
END //

DELIMITER ;