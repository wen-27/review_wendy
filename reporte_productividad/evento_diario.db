SET GLOBAL event_scheduler = ON;

CREATE EVENT ev_actualizar_reporte_diario
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY - INTERVAL 1 MINUTE)
DO
  CALL sp_generar_informe_diario();