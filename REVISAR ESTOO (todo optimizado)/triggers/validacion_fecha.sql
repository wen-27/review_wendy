USE sistema_medicos;

DELIMITER //

DROP TRIGGER IF EXISTS tr_validar_fecha_no_futura //

CREATE TRIGGER tr_validar_fecha_no_futura
BEFORE INSERT ON citas
FOR EACH ROW
BEGIN

    IF NEW.fecha_cita > CONCAT(CURDATE(), ' 23:59:59') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No se permiten fechas futuras. Esta tabla es exclusiva para el informe de productividad diario.';
    END IF;

    IF NEW.fecha_cita < '2024-01-01' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Fecha fuera de rango histórico (mínimo año 2024).';
    END IF;
END //

DELIMITER ;