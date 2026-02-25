DELIMITER //

CREATE PROCEDURE sp_generar_informe_diario()
BEGIN
    -- Limpiamos datos del día para evitar duplicados si se corre varias veces
    DELETE FROM reporte_diario_productividad WHERE fecha_consulta = CURDATE();

    -- Insertamos la consolidación
    INSERT INTO reporte_diario_productividad (fecha_consulta, sede, nombre_medico, total_pacientes)
    SELECT 
        c.Fecha,
        c.Hospital_Sede,
        m.Nombre_Medico,
        COUNT(c.Cod_paciente)
    FROM cita c
    INNER JOIN MEDICOSSS m ON c.Cod_medico = m.Medico_ID
    WHERE c.Fecha = CURDATE()
    GROUP BY c.Hospital_Sede, m.Nombre_Medico;
    
    SELECT 'ÉXITO: Informe diario actualizado' AS Mensaje;
END //

DELIMITER ;