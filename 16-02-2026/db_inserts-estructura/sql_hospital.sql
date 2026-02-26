-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS sistema_medico;
USE sistema_medico;

-- 1. Especialidades
CREATE TABLE especialidades (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 2. Facultades
CREATE TABLE facultades (
    id_facultad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_facultad VARCHAR(100) NOT NULL,
    decano VARCHAR(100)
);

-- 3. Hospitales / Sedes
CREATE TABLE sedes_hospital (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255)
);

-- 4. Diagnósticos
CREATE TABLE diagnosticos (
    id_diagnostico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 5. Pacientes (Movida arriba para poder referenciarla)
CREATE TABLE pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20)
);

-- 6. Médicos
CREATE TABLE medicos (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nombre_medico VARCHAR(100) NOT NULL,
    id_especialidad INT,
    id_facultad INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad),
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad)
);

-- 7. Citas (Tabla central)
CREATE TABLE citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_cita DATETIME NOT NULL, -- DATETIME es mejor para incluir la hora
    id_diagnostico INT,
    id_sede INT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico),
    FOREIGN KEY (id_diagnostico) REFERENCES diagnosticos(id_diagnostico),
    FOREIGN KEY (id_sede) REFERENCES sedes_hospital(id_sede)
);

-- 8. Recetas (Detalle de medicamentos por cita)
CREATE TABLE recetas (
    id_cita INT,
    medicamento VARCHAR(100),
    dosis VARCHAR(50),
    PRIMARY KEY (id_cita, medicamento),
    FOREIGN KEY (id_cita) REFERENCES citas(id_cita) ON DELETE CASCADE
);