-- 1. Especialidades
INSERT INTO especialidades (ID_especialida, nombre) VALUES 
('E1', 'Infectología'),
('E2', 'Cardiología'),
('E3', 'Neurocirugía');

-- 2. Facultades y Decanos
INSERT INTO facultad_nombres (id_facultad_nombre, facultad, decano) VALUES 
('f1', 'Medicina', 'Dr. Wilson'),
('f2', 'Ciencias', 'Dr. Palmer');

-- 3. Hospitales
INSERT INTO Hospital_Sede (id_hospital, nombre, direccion) VALUES 
('h1', 'Centro Médico', 'Calle 5 #10'),
('h2', 'Clínica Norte', 'Av. Libertador');

-- 4. Diagnósticos
INSERT INTO Diagnosticos (id_diagnostico, nombre) VALUES 
('D1', 'Gripe Fuerte'),
('D2', 'Infección'),
('D3', 'Arritmia'),
('D4', 'Migraña');

-- 5. Médicos
INSERT INTO MEDICOSSS (Medico_ID, Nombre_Medico, Especialidades, Facultad_nombres) VALUES 
('M-10', 'Dr. House', 'E1', 'f1'),
('M-22', 'Dra. Grey', 'E2', 'f1'),
('M-30', 'Dr. Strange', 'E3', 'f2');

-- 6. Citas
-- Nota: He ajustado el formato de fecha a YYYY-MM-DD para compatibilidad SQL
INSERT INTO cita (Cod_Cita, Cod_paciente, Cod_medico, Fecha_Cita, Diagnostico, Hospital_Sede) VALUES 
('C-001', 'P-501', 'M-10', '2024-05-10', 'D1', 'h1'),
('C-002', 'P-502', 'M-10', '2024-05-11', 'D2', 'h1'),
('C-003', 'P-501', 'M-22', '2024-05-12', 'D3', 'h2'),
('C-004', 'P-503', 'M-30', '2024-05-15', 'D4', 'h2');

-- 7. Recetas de las Citas
INSERT INTO receta_cita (cod_cita, medicamento, dosis) VALUES 
('C-001', 'Paracetamo', '500mg'),
('C-001', 'Ibuprofeno', '400mg'),
('C-002', 'Amoxicilina', '875mg'),
('C-003', 'Aspirina', '100mg'),
('C-004', 'Ergotamina', '1mg');