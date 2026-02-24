Perfecto, wen. Aquí tienes tu **README completo actualizado**, integrando la sección de RBAC y quitando todos los emojis para mantenerlo formal y profesional:

---

# Sistema de Gestión Médica (Backend MySQL)

Este repositorio contiene la arquitectura de base de datos para un sistema médico profesional, enfocado en la **integridad de datos**, el **control de errores centralizado**, la **seguridad basada en roles ** y la **automatización de procesos** mediante procedimientos almacenados y funciones.

## Características Principales

* **Validación Modular:** Cada entidad cuenta con funciones de validación dedicadas que filtran errores de lógica antes de afectar las tablas.
* **CRUD Robusto:** Procedimientos individuales para Crear, Leer, Actualizar y Eliminar (CRUD) que garantizan un acceso controlado a los datos.
* **Cero Variables Globales:** Implementación estricta utilizando variables locales (`DECLARE`) para mayor seguridad y rendimiento.
* **Auditoría y Logs:** Sistema de registro centralizado que captura automáticamente cualquier error técnico (código y mensaje) en una tabla de auditoría.
* **Control de Acceso por Roles :** Permisos estructurados bajo el principio de mínimo privilegio.

---

## Estructura del Sistema

### 1. Entidades Soportadas

El sistema gestiona el ciclo completo de atención médica:

* **Médicos:** Gestión de personal médico vinculado a facultades.
* **Especialidades:** Catálogo de áreas médicas.
* **Citas:** Control de agendamiento entre pacientes, médicos y sedes.
* **Hospital_Sede:** Gestión de las ubicaciones físicas de atención.
* **Diagnósticos y Recetas:** Registro detallado de la consulta y tratamiento.
* **Facultad_Nombres:** Clasificación académica de los profesionales.

### 2. Sistema de Logs (Auditoría)

Se utiliza una tabla centralizada para capturar excepciones de SQL:

* **Tabla:** `logs`
* **Mecanismo:** `DECLARE EXIT HANDLER FOR SQLEXCEPTION`
* **Datos capturados:** Nombre de la tabla, objeto (función/procedimiento), operación, código de error MySQL, mensaje descriptivo y fecha/hora.

---

## Guía de Uso de Procedimientos

Cada CRUD sigue este estándar de nomenclatura:

* `sp_crear_[entidad]`
* `sp_listar_[entidad]`
* `sp_actualizar_[entidad]`
* `sp_eliminar_[entidad]`

### Ejemplo de ejecución:

```sql
-- Para crear una cita:
CALL sp_crear_cita('C-101', '2026-03-15', 'PAC-01', 'MED-55', 'SEDE-A');

-- Para revisar si hubo errores:
SELECT * FROM logs ORDER BY fecha_hora DESC;
```

---

## Seguridad y Control de Acceso 
El sistema implementa un modelo de **Control de Acceso Basado en Roles**, diseñado bajo el principio de **Privilegio Mínimo**. Cada usuario posee exactamente los permisos necesarios para su labor, reduciendo la superficie de ataque y evitando la manipulación accidental de datos sensibles.

### Justificación de Roles

| Rol                  | Justificación                                                                                                                              | Permisos Clave                                                                            |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| **Admin de Sistema** | Responsable de la infraestructura y mantenimiento. Es el único con facultad para gestionar otros usuarios.                                 | `ALL PRIVILEGES`, `GRANT OPTION`, `CREATE USER`.                                          |
| **Cuerpo Médico**    | Su enfoque es la atención clínica. Necesita registrar el estado del paciente pero no debe alterar la agenda administrativa (Citas).        | `INSERT/UPDATE` en Diagnósticos y Recetas; `EXECUTE` en procedimientos clínicos.          |
| **Recepción**        | Gestiona el flujo operativo de la clínica. Controla quién entra y cuándo (Citas), pero tiene prohibido ver o modificar historias clínicas. | `CRUD` completo en Citas; `SELECT` en Médicos y Sedes; `EXECUTE` en procesos de agenda.   |
| **Paciente**         | Usuario final con fines de consulta. Su acceso es estrictamente de lectura y limitado a su propio historial médico.                        | `SELECT` restringido; `EXECUTE` solo en procedimientos de lectura (Listar recetas/citas). |

### Por qué esta estructura de permisos

1. **Seguridad por Procedimientos (`EXECUTE`):** Al otorgar permisos de ejecución sobre procedimientos en lugar de acceso directo a las tablas, obligamos a que toda transacción pase por nuestras funciones de validación. Esto evita que un usuario inserte datos malformados manualmente.

2. **Segregación de Funciones:** Médicos y Recepcionistas operan en silos distintos. Un error en la recepción no puede borrar un diagnóstico médico, y un médico no puede cancelar una cita sin pasar por el flujo administrativo.

3. **Protección de la Integridad:** El uso de `DROP PROCEDURE IF EXISTS` y `DECLARE EXIT HANDLER` asegura que, ante un intento de operación no permitida o un error técnico, el sistema responda con un mensaje controlado y registre el evento en el Log de Auditoría sin exponer la estructura interna de la base de datos.

---
