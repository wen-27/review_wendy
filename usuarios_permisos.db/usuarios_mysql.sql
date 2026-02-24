USE Sistema_Medico;

-- 1. ADMINISTRADOR DEL SISTEMA (Acceso Total + Gestión de Cuentas)
CREATE USER 'admin_sistema'@'localhost' IDENTIFIED BY 'Admin2024*';
GRANT ALL PRIVILEGES ON Sistema_Medico.* TO 'admin_sistema'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 2. MÉDICO (Enfocado en la parte clínica)
CREATE USER 'medico_user'@'localhost' IDENTIFIED BY 'Medico2024*';

-- Permisos sobre tablas
GRANT SELECT ON Sistema_Medico.cita TO 'medico_user'@'localhost';
GRANT INSERT, UPDATE ON Sistema_Medico.Diagnosticos TO 'medico_user'@'localhost';
GRANT INSERT, UPDATE ON Sistema_Medico.receta_cita TO 'medico_user'@'localhost';

-- Permisos sobre procedimientos (CRUD clínico)
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_leer_diagnostico TO 'medico_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_crear_diagnostico TO 'medico_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_crear_receta TO 'medico_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_listar_receta_cita TO 'medico_user'@'localhost';
FLUSH PRIVILEGES;

-- 3. RECEPCIONISTA (Enfocado en la parte administrativa)

CREATE USER 'recepcionista_user'@'localhost' IDENTIFIED BY 'Recep2024*';

-- Permisos sobre tablas
GRANT SELECT ON Sistema_Medico.MEDICOSSS TO 'recepcionista_user'@'localhost';
GRANT SELECT ON Sistema_Medico.Hospital_Sede TO 'recepcionista_user'@'localhost';
GRANT INSERT, UPDATE, DELETE ON Sistema_Medico.cita TO 'recepcionista_user'@'localhost';

-- Permisos sobre procedimientos (CRUD administrativo)
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_crear_cita TO 'recepcionista_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_listar_citas TO 'recepcionista_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_actualizar_cita TO 'recepcionista_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_eliminar_cita TO 'recepcionista_user'@'localhost';
FLUSH PRIVILEGES;

-- 4. PACIENTE (Acceso de consulta y registro de datos personales)

CREATE USER 'paciente_user'@'localhost' IDENTIFIED BY 'Paciente2024*';

-- Permisos de lectura
GRANT SELECT ON Sistema_Medico.cita TO 'paciente_user'@'localhost';
GRANT SELECT ON Sistema_Medico.especialidades TO 'paciente_user'@'localhost';

-- Permisos de ejecución de procedimientos de lectura
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_listar_citas TO 'paciente_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_leer_diagnostico TO 'paciente_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Sistema_Medico.sp_listar_receta_cita TO 'paciente_user'@'localhost';

-- Permiso sobre funciones (Tipo 4: EXECUTE FUNCTION)
GRANT EXECUTE ON FUNCTION Sistema_Medico.fn_validar_cita TO 'paciente_user'@'localhost';
FLUSH PRIVILEGES;