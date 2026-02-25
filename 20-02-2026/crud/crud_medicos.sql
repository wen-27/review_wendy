-- validaciones
USE Sistema_Medico;

DELIMITER //

CREATE PROCEDURE sp_crear_medico_validado(
    IN p_id VARCHAR(10), 
    IN p_nombre VARCHAR(100), 
    IN p_esp VARCHAR(10), 
    IN p_fac VARCHAR(10)
)
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_crear_medico_validado', @errno, @msg);
        -- Mostramos el mensaje de error del sistema
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    -- VALIDACIÓN 1: Campos vacíos
    IF p_id = '' OR p_nombre = '' THEN
        SELECT 'VALIDACIÓN: El ID y el Nombre son obligatorios.' AS Mensaje;
    
    -- VALIDACIÓN 2: Si el ID ya existe 
    ELSEIF EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: Error, el ID del médico ya se encuentra registrado.' AS Mensaje;
    
    -- VALIDACIÓN 3: Si la especialidad no existe en la tabla maestra
    ELSEIF NOT EXISTS (SELECT 1 FROM especialidades WHERE ID_especialida = p_esp) THEN
        SELECT 'VALIDACIÓN: La especialidad ingresada no existe.' AS Mensaje;

    ELSE
        -- Si pasa todas las validaciones, insertamos
        INSERT INTO MEDICOSSS (Medico_ID, Nombre_Medico, Especialidades, Facultad_nombres)
        VALUES (p_id, p_nombre, p_esp, p_fac);
        SELECT 'ÉXITO: Médico registrado correctamente.' AS Mensaje;
    END IF;

END //

DELIMITER ;

-- crud medicos 


-- crear
DROP PROCEDURE IF EXISTS sp_crear_medico;
DELIMITER //
CREATE PROCEDURE sp_crear_medico(
    IN p_id VARCHAR(10), 
    IN p_nombre VARCHAR(100), 
    IN p_esp VARCHAR(10), 
    IN p_fac VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_crear_medico', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    IF p_id = '' OR p_nombre = '' THEN
        SELECT 'VALIDACIÓN: El ID y el Nombre son obligatorios.' AS Mensaje;
    ELSEIF EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: Error, el ID del médico ya se encuentra registrado.' AS Mensaje;
    ELSEIF NOT EXISTS (SELECT 1 FROM especialidades WHERE ID_especialida = p_esp) THEN
        SELECT 'VALIDACIÓN: La especialidad ingresada no existe.' AS Mensaje;
    ELSE
        INSERT INTO MEDICOSSS (Medico_ID, Nombre_Medico, Especialidades, Facultad_nombres)
        VALUES (p_id, p_nombre, p_esp, p_fac);
        SELECT 'ÉXITO: Médico registrado correctamente.' AS Mensaje;
    END IF;
END //
DELIMITER ;

-- leer
DROP PROCEDURE IF EXISTS sp_listar_medicos;
DELIMITER //
CREATE PROCEDURE sp_listar_medicos()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_listar_medicos', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    SELECT * FROM MEDICOSSS;
END //
DELIMITER ;

-- actualizar
DROP PROCEDURE IF EXISTS sp_actualizar_medico;
DELIMITER //
CREATE PROCEDURE sp_actualizar_medico(
    IN p_id VARCHAR(10), 
    IN p_nuevo_nombre VARCHAR(100),
    IN p_nueva_esp VARCHAR(10),
    IN p_nueva_fac VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_actualizar_medico', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    IF NOT EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: Error, el médico con ese ID no existe.' AS Mensaje;
    ELSEIF p_nuevo_nombre = '' THEN
        SELECT 'VALIDACIÓN: El nombre no puede estar vacío.' AS Mensaje;
    ELSE
        UPDATE MEDICOSSS 
        SET Nombre_Medico = p_nuevo_nombre, 
            Especialidades = p_nueva_esp, 
            Facultad_nombres = p_nueva_fac
        WHERE Medico_ID = p_id;
        SELECT 'ÉXITO: Médico actualizado correctamente.' AS Mensaje;
    END IF;
END //
DELIMITER ;

-- eliminar
DROP PROCEDURE IF EXISTS sp_eliminar_medico;
DELIMITER //
CREATE PROCEDURE sp_eliminar_medico(IN p_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'sp_eliminar_medico', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo eliminar. Es probable que el médico tenga citas registradas.' AS Mensaje;
    END;

    IF NOT EXISTS (SELECT 1 FROM MEDICOSSS WHERE Medico_ID = p_id) THEN
        SELECT 'VALIDACIÓN: El médico no existe.' AS Mensaje;
    ELSE
        DELETE FROM MEDICOSSS WHERE Medico_ID = p_id;
        SELECT 'ÉXITO: Médico eliminado correctamente.' AS Mensaje;
    END IF;
END //
DELIMITER ;

