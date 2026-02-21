-- logs tabla y funcion para guardar en logs

use Sistema_Medico;

CREATE TABLE IF NOT EXISTS logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tabla VARCHAR(50) NOT NULL,
    nombre_objeto VARCHAR(50) NOT NULL,
    tipo_objeto VARCHAR(20) NOT NULL,
    operacion VARCHAR(50) NOT NULL,
    codigo_error INT NOT NULL,
    mensaje_error TEXT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE FUNCTION fn_total_pacientes_medico(p_id_medico INT)
RETURNS INT
DETERMINISTIC
BEGIN

 
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_codigo_error INT;
    DECLARE v_mensaje_error VARCHAR(255);

 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_codigo_error = MYSQL_ERRNO,
            v_mensaje_error = MESSAGE_TEXT;

        INSERT INTO logs (
            nombre_tabla,
            nombre_objeto,
            tipo_objeto,
            operacion,
            codigo_error,
            mensaje_error
        )
        VALUES (
            'citas',
            'fn_total_pacientes_medico',
            'FUNCTION',
            'SELECT',
            v_codigo_error,
            v_mensaje_error
        );

        RETURN -1;
    END;

   
    SELECT COUNT(DISTINCT id_paciente)
    INTO v_total
    FROM citas
    WHERE id_medico = p_id_medico;

    RETURN v_total;

END$$

DELIMITER ;
