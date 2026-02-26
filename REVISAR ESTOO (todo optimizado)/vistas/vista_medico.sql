
USE sistema_medicos;

UPDATE especialidades 
SET id_facultad = 1 
WHERE id_facultad IS NULL;

UPDATE medicos 
SET id_sede = 1 
WHERE id_sede IS NULL;

SELECT * FROM facultades WHERE id_facultad = 1;
SELECT * FROM sedes_hospital WHERE id_sede = 1;

-- vista

CREATE OR REPLACE VIEW vw_medicos_jerarquia AS
SELECT 
    f.nombre_facultad AS facultad,
    e.nombre AS especialidad,
    m.id_medico,
    m.nombre_medico AS nombre_completo,
    s.nombre AS sede_hospital
FROM medicos m
INNER JOIN especialidades e ON m.id_especialidad = e.id_especialidad
INNER JOIN facultades f ON e.id_facultad = f.id_facultad
INNER JOIN sedes_hospital s ON m.id_sede = s.id_sede
ORDER BY f.nombre_facultad, e.nombre, m.nombre_medico;



UPDATE medicos SET id_sede = 1;

SELECT id_facultad, nombre_facultad FROM facultades;

UPDATE especialidades SET id_facultad = 1 WHERE id_facultad IS NULL;

SELECT id_medico, nombre_medico, id_especialidad FROM medicos;

UPDATE medicos SET id_especialidad = (ID_DE_TU_TABLA_ESPECIALIDADES) WHERE id_medico = 10;

-- ejecucion 

SELECT * FROM vw_medicos_jerarquia;
