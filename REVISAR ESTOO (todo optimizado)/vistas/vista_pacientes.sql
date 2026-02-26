-- datos de prueba 

USE sistema_medicos;

-- 1. Crear Pacientes
INSERT INTO pacientes (nombre, apellido, telefono) VALUES ('Juan', 'Perez', '555-1234');
INSERT INTO pacientes (nombre, apellido, telefono) VALUES ('Ana', 'Gomez', '555-5678');

-- 2. Crear Citas (Usando IDs 1 y 2 que acabamos de crear)
-- Nota: id_cita y fecha_cita son PK, asegúrate de poner una fecha.
INSERT INTO citas (id_cita, id_paciente, id_medico, fecha_cita, id_sede) 
VALUES (101, 1, 10, '2026-02-25 10:00:00', 1);

INSERT INTO citas (id_cita, id_paciente, id_medico, fecha_cita, id_sede) 
VALUES (102, 2, 10, '2026-02-25 11:00:00', 1);

-- 3. Crear Recetas (Ambos reciben Paracetamol)
INSERT INTO recetas (id_cita, medicamento, dosis) VALUES (101, 'Paracetamol', '500mg');
INSERT INTO recetas (id_cita, medicamento, dosis) VALUES (102, 'Paracetamol', '500mg');

-- vista 

USE sistema_medicos;

CREATE OR REPLACE VIEW vw_pacientes_por_medicamento AS
SELECT 
    r.medicamento AS nombre_medicamento,
    COUNT(DISTINCT c.id_paciente) AS total_pacientes_unicos,
    COUNT(r.medicamento) AS total_veces_recetado 
FROM recetas r
INNER JOIN citas c ON r.id_cita = c.id_cita
GROUP BY r.medicamento
ORDER BY total_pacientes_unicos DESC;

-- ejecutar vista

SELECT * FROM vw_pacientes_por_medicamento;