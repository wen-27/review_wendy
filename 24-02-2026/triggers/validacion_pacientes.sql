
USE Sistema_Medico;

DELIMITER //

-- Validación para inserción de pacientes

CREATE TRIGGER tr_validar_paciente_insert
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    -- Validar nombre no vacío
    IF NEW.nombre_paciente IS NULL OR TRIM(NEW.nombre_paciente) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El nombre del paciente no puede estar vacío';
    END IF;

    -- Validar teléfono no vacío
    IF NEW.telefono IS NULL OR TRIM(NEW.telefono) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El teléfono es obligatorio para contacto';
    END IF;
END //

-- Validación para actualización de pacientes
CREATE TRIGGER tr_validar_paciente_update
BEFORE UPDATE ON pacientes
FOR EACH ROW
BEGIN
    IF NEW.nombre_paciente IS NULL OR TRIM(NEW.nombre_paciente) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No se puede dejar el nombre vacío';
    END IF;
END //

DELIMITER ;
