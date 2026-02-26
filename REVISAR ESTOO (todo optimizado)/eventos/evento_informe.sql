use sistema_medicos;
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS ev_actualizar_reporte_diario;

CREATE EVENT ev_actualizar_reporte_diario
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 1 MINUTE) 
ON COMPLETION PRESERVE
DO
  CALL sp_generar_informe_diario();