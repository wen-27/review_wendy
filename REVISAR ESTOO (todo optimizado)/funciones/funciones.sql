USE sistema_medicos;

-- Optimiza la búsqueda de doctores por especialidad
CREATE INDEX idx_medico_especialidad ON medicos(id_especialidad);

-- Optimiza el conteo de pacientes únicos por médico 
CREATE INDEX idx_citas_medico_paciente ON citas(id_medico, id_paciente);

-- Optimiza el conteo de pacientes únicos por sede
CREATE INDEX idx_citas_sede_paciente ON citas(id_sede, id_paciente);

DELIMITER $$

-- 1. Cantidad de doctores por especialidad

DROP FUNCTION IF EXISTS fn_cantidad_doctores_especialidad$$
CREATE FUNCTION fn_cantidad_doctores_especialidad(p_id_especialidad INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cantidad
    FROM medicos
    WHERE id_especialidad = p_id_especialidad;

    RETURN IFNULL(v_cantidad, 0);
END$$


-- 2. Total pacientes únicos atendidos por un médico

DROP FUNCTION IF EXISTS fn_total_pacientes_medico$$
CREATE FUNCTION fn_total_pacientes_medico(p_id_medico INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT DEFAULT 0;


    SELECT COUNT(DISTINCT id_paciente)
    INTO v_total
    FROM citas
    WHERE id_medico = p_id_medico;

    RETURN IFNULL(v_total, 0);
END$$


-- 3. Cantidad de pacientes atendidos por sede

DROP FUNCTION IF EXISTS fn_pacientes_por_sede$$
CREATE FUNCTION fn_pacientes_por_sede(p_id_sede INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;

    SELECT COUNT(DISTINCT id_paciente)
    INTO v_cantidad
    FROM citas
    WHERE id_sede = p_id_sede;

    RETURN IFNULL(v_cantidad, 0);
END$$

DELIMITER ;