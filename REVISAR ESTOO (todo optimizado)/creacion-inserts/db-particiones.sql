-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS sistema_medicos;
USE sistema_medicos;

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

-- 5. Pacientes 
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

CREATE TABLE citas (
    id_cita INT NOT NULL,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_cita DATETIME NOT NULL,
    id_diagnostico INT,
    id_sede INT,
    PRIMARY KEY (id_cita, fecha_cita), 
    INDEX (id_paciente),
    INDEX (id_medico)
) 
PARTITION BY RANGE (YEAR(fecha_cita)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- 8. Recetas
CREATE TABLE recetas (
    id_cita INT,
    medicamento VARCHAR(100),
    dosis VARCHAR(50),
    PRIMARY KEY (id_cita, medicamento)
);

-- 9. Reporte Diario 

CREATE TABLE reporte_diario_productividad (
    id_reporte INT NOT NULL,
    fecha_atencion DATE NOT NULL,
    id_sede INT,
    id_medico INT,
    cantidad_pacientes INT,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_reporte, fecha_atencion)
)
PARTITION BY RANGE COLUMNS(fecha_atencion) (
    PARTITION p_old VALUES LESS THAN ('2025-01-01'),
    PARTITION p2025_q1 VALUES LESS THAN ('2025-04-01'),
    PARTITION p2025_q2 VALUES LESS THAN ('2025-07-01'),
    PARTITION p_max VALUES LESS THAN MAXVALUE
);

-- 10. Logs 
CREATE TABLE logs (
    id_log INT NOT NULL AUTO_INCREMENT,
    nombre_tabla VARCHAR(50),
    operacion VARCHAR(50),
    codigo_error INT,
    mensaje_error TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_log, fecha_hora)
)
PARTITION BY RANGE (UNIX_TIMESTAMP(fecha_hora)) (
    PARTITION p_inicio VALUES LESS THAN (UNIX_TIMESTAMP('2025-01-01 00:00:00')),
    PARTITION p_actual VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01 00:00:00')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);