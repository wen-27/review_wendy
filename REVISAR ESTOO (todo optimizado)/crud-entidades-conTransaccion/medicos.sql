USE Sistema_Medicos;

DELIMITER //

-- 1. CREAR MÉDICO
DROP PROCEDURE IF EXISTS sp_crear_medico//
CREATE PROCEDURE sp_crear_medico(
    IN p_nombre VARCHAR(100), 
    IN p_esp INT, 
    IN p_fac INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('medicos', 'sp_crear_medico', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END;

    -- VALIDACIONES 
    IF p_nombre = '' OR p_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre es obligatorio.';
    ELSEIF NOT EXISTS (SELECT 1 FROM especialidades WHERE id_especialidad = p_esp) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La especialidad no existe.';
    ELSEIF NOT EXISTS (SELECT 1 FROM facultades WHERE id_facultad = p_fac) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La facultad no existe.';
    ELSE
        START TRANSACTION;
            INSERT INTO medicos (nombre_medico, id_especialidad, id_facultad) 
            VALUES (p_nombre, p_esp, p_fac);
        COMMIT;
        SELECT 'ÉXITO: Médico registrado correctamente.' AS Mensaje;
    END IF;
END //

-- 2. LEER MÉDICOS
DROP PROCEDURE IF EXISTS sp_listar_medicos//
CREATE PROCEDURE sp_listar_medicos()
BEGIN
    SELECT 
        m.id_medico AS 'ID', 
        m.nombre_medico AS 'Nombre Médico', 
        e.nombre AS 'Especialidad', 
        f.nombre AS 'Facultad'
    FROM medicos m
    INNER JOIN especialidades e ON m.id_especialidad = e.id_especialidad
    INNER JOIN facultades f ON m.id_facultad = f.id_facultad
    ORDER BY m.id_medico DESC;
END //

-- 3. ACTUALIZAR MÉDICO
DROP PROCEDURE IF EXISTS sp_actualizar_medico//
CREATE PROCEDURE sp_actualizar_medico(
    IN p_id INT, 
    IN p_nuevo_nombre VARCHAR(100),
    IN p_nueva_esp INT,
    IN p_nueva_fac INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('medicos', 'sp_actualizar_medico', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar el registro.';
    END;

    IF NOT EXISTS (SELECT 1 FROM medicos WHERE id_medico = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El médico no existe.';
    ELSE
        START TRANSACTION;
            UPDATE medicos 
            SET nombre_medico = p_nuevo_nombre, 
                id_especialidad = p_nueva_esp, 
                id_facultad = p_nueva_fac 
            WHERE id_medico = p_id;
        COMMIT;
        SELECT 'ÉXITO: Información actualizada.' AS Mensaje;
    END IF;
END //

-- 4. ELIMINAR MÉDICO
DROP PROCEDURE IF EXISTS sp_eliminar_medico//
CREATE PROCEDURE sp_eliminar_medico(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('medicos', 'sp_eliminar_medico', @errno, @msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: el médico tiene datos vinculados (citas/diagnósticos).';
    END;

    IF NOT EXISTS (SELECT 1 FROM medicos WHERE id_medico = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID de médico no encontrado.';
    ELSE
        START TRANSACTION;
            DELETE FROM medicos WHERE id_medico = p_id;
        COMMIT;
        SELECT 'ÉXITO: Médico eliminado.' AS Mensaje;
    END IF;
END //

DELIMITER ;