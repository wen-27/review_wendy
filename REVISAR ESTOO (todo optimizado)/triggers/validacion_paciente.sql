USE sistema_medicos;

DELIMITER //

-- 1. Validación para INSERCIÓN
DROP TRIGGER IF EXISTS tr_validar_paciente_insert //
CREATE TRIGGER tr_validar_paciente_insert
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    -- Validar nombre 
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El nombre es obligatorio';
    END IF;

    -- Validar apellido 
    IF NEW.apellido IS NULL OR TRIM(NEW.apellido) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El apellido es obligatorio';
    END IF;

    -- Validar teléfono
    IF NEW.telefono IS NULL OR TRIM(NEW.telefono) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El teléfono es obligatorio';
    END IF;
    
    -- Limpiar espacios extra automáticamente
    SET NEW.nombre = TRIM(NEW.nombre);
    SET NEW.apellido = TRIM(NEW.apellido);
END //

-- 2. Validación para ACTUALIZACIÓN
DROP TRIGGER IF EXISTS tr_validar_paciente_update //
CREATE TRIGGER tr_validar_paciente_update
BEFORE UPDATE ON pacientes
FOR EACH ROW
BEGIN
    -- Impedir que al actualizar dejen el nombre o apellido vacíos
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No puedes dejar el nombre vacío en la actualización';
    END IF;
    
    IF NEW.apellido IS NULL OR TRIM(NEW.apellido) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No puedes dejar el apellido vacío';
    END IF;

    -- Limpieza automática
    SET NEW.nombre = TRIM(NEW.nombre);
    SET NEW.apellido = TRIM(NEW.apellido);
END //

DELIMITER ;