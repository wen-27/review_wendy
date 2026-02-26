USE sistema_medicos;

DELIMITER //

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_paciente //
CREATE FUNCTION fn_validar_paciente(p_nombre VARCHAR(100), p_apellido VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    IF p_nombre = '' OR p_apellido = '' THEN 
        RETURN 'Error: El nombre y apellido son campos obligatorios';
    -- Verificamos si ya existe alguien con el mismo nombre y apellido para evitar duplicidad
    ELSEIF EXISTS(SELECT 1 FROM pacientes WHERE nombre = p_nombre AND apellido = p_apellido) THEN 
        RETURN 'Error: Este paciente ya se encuentra registrado en el sistema';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR 
DROP PROCEDURE IF EXISTS sp_crear_paciente //
CREATE PROCEDURE sp_crear_paciente(
    IN p_nombre VARCHAR(100), 
    IN p_apellido VARCHAR(100), 
    IN p_telefono VARCHAR(20)
)
BEGIN
    DECLARE v_valida VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('pacientes', 'INSERT_PAC', @errno, @msg);
        SELECT CONCAT('ERROR DE SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_paciente(p_nombre, p_apellido);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;

            SET @stmt_ins_pac = 'INSERT INTO pacientes (nombre, apellido, telefono) VALUES (?, ?, ?)';
            SET @n_pac = p_nombre, @a_pac = p_apellido, @t_pac = p_telefono;
            PREPARE query_ins_pac FROM @stmt_ins_pac;
            EXECUTE query_ins_pac USING @n_pac, @a_pac, @t_pac;
            DEALLOCATE PREPARE query_ins_pac;
        COMMIT;
        SELECT 'ÉXITO: Paciente registrado correctamente' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_pacientes //
CREATE PROCEDURE sp_listar_pacientes()
BEGIN

    SELECT 
        id_paciente AS 'ID', 
        CONCAT(apellido, ', ', nombre) AS 'Paciente', 
        telefono AS 'Teléfono de Contacto'
    FROM pacientes 
    ORDER BY apellido ASC;
END //

-- C. ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_paciente //
CREATE PROCEDURE sp_actualizar_paciente(
    IN p_id INT, 
    IN p_nuevo_nom VARCHAR(100), 
    IN p_nuevo_ape VARCHAR(100), 
    IN p_nuevo_tel VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('pacientes', 'UPDATE_PAC', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar la información del paciente' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM pacientes WHERE id_paciente = p_id) THEN
            SET @stmt_upd_pac = 'UPDATE pacientes SET nombre = ?, apellido = ?, telefono = ? WHERE id_paciente = ?';
            SET @unom = p_nuevo_nom, @uape = p_nuevo_ape, @utel = p_nuevo_tel, @uid = p_id;
            
            PREPARE query_upd_pac FROM @stmt_upd_pac;
            EXECUTE query_upd_pac USING @unom, @uape, @utel, @uid;
            DEALLOCATE PREPARE query_upd_pac;
            
            COMMIT;
            SELECT 'ÉXITO: Datos del paciente actualizados' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El ID de paciente no existe' AS Mensaje; 
        END IF;
END //

-- D. ELIMINAR 
DROP PROCEDURE IF EXISTS sp_eliminar_paciente //
CREATE PROCEDURE sp_eliminar_paciente(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('pacientes', 'DELETE_PAC', @errno, @msg);
        SELECT 'ERROR: El paciente tiene citas registradas y no puede ser borrado' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM pacientes WHERE id_paciente = p_id) THEN
            SET @stmt_del_pac = 'DELETE FROM pacientes WHERE id_paciente = ?';
            SET @did = p_id;
            
            PREPARE query_del_pac FROM @stmt_del_pac;
            EXECUTE query_del_pac USING @did;
            DEALLOCATE PREPARE query_del_pac;
            
            COMMIT;
            SELECT 'ÉXITO: Paciente eliminado del sistema' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: Registro no encontrado' AS Mensaje; 
        END IF;
END //

DELIMITER ;