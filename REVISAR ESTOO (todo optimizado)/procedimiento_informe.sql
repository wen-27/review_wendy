USE sistema_medicos;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_generar_informe_diario //

CREATE PROCEDURE sp_generar_informe_diario()
BEGIN

    DECLARE v_inicio DATETIME DEFAULT CONCAT(CURDATE(), ' 00:00:00');
    DECLARE v_fin    DATETIME DEFAULT CONCAT(CURDATE(), ' 23:59:59');

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs (nombre_tabla, operacion, codigo_error, mensaje_error)
        VALUES ('reporte_diario_productividad', 'EVENT_DAILY_REPORT', @errno, @msg);
    END;

    START TRANSACTION;

        INSERT INTO reporte_diario_productividad (fecha_consulta, sede, nombre_medico, total_pacientes)
        SELECT 
            DATE(c.fecha_cita),
            s.nombre,          
            m.nombre,          
            COUNT(c.id_paciente)
        FROM citas c
        INNER JOIN medicos m ON c.id_medico = m.id_medico
        INNER JOIN sedes_hospital s ON c.id_sede = s.id_sede

        WHERE c.fecha_cita >= v_inicio AND c.fecha_cita <= v_fin
        GROUP BY c.id_sede, m.id_medico
        ON DUPLICATE KEY UPDATE 
            total_pacientes = VALUES(total_pacientes);
            
    COMMIT;
    

END //

DELIMITER ;