USE sistema_medicos;

-- 1. Limpieza de usuarios previos
DROP USER IF EXISTS 'recepcion'@'localhost', 'medico'@'localhost', 'usuario'@'localhost', 'admin'@'localhost';

-- 2. Creación de usuarios
CREATE USER 'recepcion'@'localhost' IDENTIFIED BY 'Recepcion2026!';
CREATE USER 'medico'@'localhost' IDENTIFIED BY 'Medico2026!';
CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'Usuario2026!';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Admin2026!';

-- A. PERMISOS PARA RECEPCIÓN (Gestión de pacientes y citas)
GRANT SELECT ON sistema_medicos.medicos TO 'recepcion'@'localhost';
GRANT SELECT ON sistema_medicos.sedes_hospital TO 'recepcion'@'localhost';
GRANT SELECT, INSERT, UPDATE ON sistema_medicos.pacientes TO 'recepcion'@'localhost';
GRANT SELECT, INSERT, UPDATE ON sistema_medicos.citas TO 'recepcion'@'localhost';

-- B. PERMISOS PARA MÉDICOS (Consulta y atención clínica)
GRANT SELECT ON sistema_medicos.pacientes TO 'medico'@'localhost';
GRANT SELECT, UPDATE ON sistema_medicos.citas TO 'medico'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON sistema_medicos.diagnosticos TO 'medico'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON sistema_medicos.recetas TO 'medico'@'localhost';

-- C. PERMISOS PARA USUARIOS (Solo lectura de lo propio)
GRANT SELECT ON sistema_medicos.pacientes TO 'usuario'@'localhost';
GRANT SELECT ON sistema_medicos.citas TO 'usuario'@'localhost';
GRANT SELECT ON sistema_medicos.diagnosticos TO 'usuario'@'localhost';
GRANT SELECT ON sistema_medicos.recetas TO 'usuario'@'localhost';

-- D. PERMISOS PARA ADMIN (Control Total)
GRANT ALL PRIVILEGES ON sistema_medicos.* TO 'admin'@'localhost';
GRANT EVENT ON *.* TO 'admin'@'localhost';

-- E. PERMISO CRUCIAL DE AUDITORÍA 
-- Esto permite que los procedimientos guarden errores incluso si el usuario no tiene otros permisos
GRANT INSERT ON sistema_medicos.logs TO 'recepcion'@'localhost', 'medico'@'localhost', 'admin'@'localhost';

FLUSH PRIVILEGES;