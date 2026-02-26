-- 1. Especialidades 
INSERT INTO especialidades (id_especialidad, nombre) VALUES 
(1, 'Infectología'),
(2, 'Cardiología'),
(3, 'Neurocirugía');

-- 2. Facultades 
INSERT INTO facultades (id_facultad, nombre_facultad, decano) VALUES 
(1, 'Medicina', 'Dr. Wilson'),
(2, 'Ciencias', 'Dr. Palmer');

-- 3. Hospitales / Sedes
INSERT INTO sedes_hospital (id_sede, nombre, direccion) VALUES 
(1, 'Centro Médico', 'Calle 5 #10'),
(2, 'Clínica Norte', 'Av. Libertador');

-- 4. Diagnósticos 
INSERT INTO diagnosticos (id_diagnostico, nombre) VALUES 
(1, 'Gripe Fuerte'),
(2, 'Infección'),
(3, 'Arritmia'),
(4, 'Migraña');

-- 5. Pacientes 
INSERT INTO pacientes (id_paciente, nombre, apellido, telefono) VALUES 
(501, 'Juan', 'Rivas', '600-111'),
(502, 'Ana', 'Soto', '600-222'),
(503, 'Luis', 'Paz', '600-333');

-- 6. Médicos 
INSERT INTO medicos (id_medico, nombre_medico, id_especialidad, id_facultad) VALUES 
(10, 'Dr. House', 1, 1),
(22, 'Dra. Grey', 2, 1),
(30, 'Dr. Strange', 3, 2);

-- 7. Citas
-- Nota: La fecha se registra como YYYY-MM-DD para que entre en la partición p2024
INSERT INTO citas (id_cita, id_paciente, id_medico, fecha_cita, id_diagnostico, id_sede) VALUES 
(1, 501, 10, '2024-05-10 08:00:00', 1, 1),
(2, 502, 10, '2024-05-11 09:00:00', 2, 1),
(3, 501, 22, '2024-05-12 10:00:00', 3, 2),
(4, 503, 30, '2024-05-15 11:00:00', 4, 2);

-- 8. Recetas
INSERT INTO recetas (id_cita, medicamento, dosis) VALUES 
(1, 'Paracetamo', '500mg'),
(1, 'Ibuprofeno', '400mg'),
(2, 'Amoxicilina', '875mg'),
(3, 'Aspirina', '100mg'),
(4, 'Ergotamina', '1mg');