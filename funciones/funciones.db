USE Sistema_Medico;

DELIMITER $$

-- Número de doctores por especialidad
DROP FUNCTION IF EXISTS fn_cantidad_doctores_especialidad$$
CREATE FUNCTION fn_cantidad_doctores_especialidad(p_id_especialidad VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, nombre_objeto, tipo_objeto, operacion, codigo_error, mensaje_error)
        VALUES ('MEDICOSSS', 'fn_cantidad_doctores_especialidad', 'FUNCTION', 'SELECT COUNT', v_errno, v_msg);
        RETURN -1;
    END;

    SELECT COUNT(*) INTO v_cantidad
    FROM MEDICOSSS
    WHERE Especialidad_ID = p_id_especialidad;

    RETURN v_cantidad;
END$$

--  Total pacientes atendidos por un médico
DROP FUNCTION IF EXISTS fn_total_pacientes_medico$$
CREATE FUNCTION fn_total_pacientes_medico(p_id_medico VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, nombre_objeto, tipo_objeto, operacion, codigo_error, mensaje_error)
        VALUES ('cita', 'fn_total_pacientes_medico', 'FUNCTION', 'SELECT COUNT', v_errno, v_msg);
        RETURN -1;
    END;

    SELECT COUNT(DISTINCT Cod_paciente)
    INTO v_total
    FROM cita
    WHERE Cod_medico = p_id_medico;

    RETURN v_total;
END$$

-- Cantidad de pacientes atendidos por sede
DROP FUNCTION IF EXISTS fn_pacientes_por_sede$$
CREATE FUNCTION fn_pacientes_por_sede(p_id_hospital VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;
    DECLARE v_errno INT;
    DECLARE v_msg TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, nombre_objeto, tipo_objeto, operacion, codigo_error, mensaje_error)
        VALUES ('cita', 'fn_pacientes_por_sede', 'FUNCTION', 'SELECT COUNT', v_errno, v_msg);
        RETURN -1;
    END;

    SELECT COUNT(DISTINCT Cod_paciente)
    INTO v_cantidad
    FROM cita
    WHERE Hospital_Sede = p_id_hospital;

    RETURN v_cantidad;
END$$

DELIMITER ;