-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS Sistema_Medico;
USE Sistema_Medico;

-- 1. Tabla Especialidades
CREATE TABLE especialidades (
    ID_especialida VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 2. Tabla Facultad_nombres (Información del Decano y Facultad)
CREATE TABLE facultad_nombres (
    id_facultad_nombre VARCHAR(10) PRIMARY KEY,
    facultad VARCHAR(100),
    decano VARCHAR(100)
);

-- 3. Tabla Hospital_Sede
CREATE TABLE Hospital_Sede (
    id_hospital VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100),
    direccion VARCHAR(255)
);

-- 4. Tabla Diagnosticos
CREATE TABLE Diagnosticos (
    id_diagnostico VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100)
);

-- 5. Tabla MEDICOSSS (Relaciona especialidad y facultad)
CREATE TABLE MEDICOSSS (
    Medico_ID VARCHAR(10) PRIMARY KEY,
    Nombre_Medico VARCHAR(100),
    Especialidades VARCHAR(10),
    Facultad_nombres VARCHAR(10),
    FOREIGN KEY (Especialidades) REFERENCES especialidades(ID_especialida),
    FOREIGN KEY (Facultad_nombres) REFERENCES facultad_nombres(id_facultad_nombre)
);

-- 6. Tabla Cita (Tabla central)
CREATE TABLE cita (
    Cod_Cita VARCHAR(10) PRIMARY KEY,
    Cod_paciente VARCHAR(10),
    Cod_medico VARCHAR(10),
    Fecha_Cita DATE,
    Diagnostico VARCHAR(10),
    Hospital_Sede VARCHAR(10),
    FOREIGN KEY (Cod_medico) REFERENCES MEDICOSSS(Medico_ID),
    FOREIGN KEY (Diagnostico) REFERENCES Diagnosticos(id_diagnostico),
    FOREIGN KEY (Hospital_Sede) REFERENCES Hospital_Sede(id_hospital)
);

-- 7. Tabla Receta_cita (Detalle de medicamentos por cita)
CREATE TABLE receta_cita (
    cod_cita VARCHAR(10),
    medicamento VARCHAR(100),
    dosis VARCHAR(50),
    PRIMARY KEY (cod_cita, medicamento),
    FOREIGN KEY (cod_cita) REFERENCES cita(Cod_Cita)
);

-- 8. tabla reporte_diario

CREATE TABLE IF NOT EXISTS reporte_diario_productividad (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    fecha_atencion DATE,
    sede_nombre VARCHAR(100),
    medico_nombre VARCHAR(100),
    cantidad_pacientes INT,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 9. tabla logs

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
