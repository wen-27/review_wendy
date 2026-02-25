USE Sistema_Medico;

DELIMITER //

DROP TRIGGER IF EXISTS tr_validar_fecha_no_futura //

CREATE TRIGGER tr_validar_fecha_no_futura
BEFORE INSERT ON cita
FOR EACH ROW
BEGIN
    -- Si la fecha ingresada es mayor a hoy, lanza un error
    IF NEW.Fecha > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No se permiten citas con fechas futuras. El registro debe ser histórico o del día actual.';
    END IF;
END //

DELIMITER ;