# Sistema de Gestión Médica 

Este repositorio contiene la arquitectura de base de datos para un sistema médico profesional, enfocado en la **integridad de datos**, el **control de errores centralizado** y la **automatización de procesos** mediante procedimientos almacenados y funciones.

## Características Principales

* **Validación Modular:** Cada entidad cuenta con funciones de validación dedicadas que filtran errores de lógica antes de afectar las tablas.
* **CRUD Robusto:** Procedimientos individuales para Crear, Leer, Actualizar y Eliminar (CRUD) que garantizan un acceso controlado a los datos.
* **Cero Variables Globales:** Implementación estricta utilizando variables locales (`DECLARE`) para mayor seguridad y rendimiento.
* **Auditoría y Logs:** Sistema de "Caja Negra" que registra automáticamente cualquier error técnico (código y mensaje) en una tabla de auditoría.

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

### 2. Sistema de Logs 

Se utiliza una tabla centralizada para capturar excepciones de SQL:

* **Tabla:** `logs`
* **Mecanismo:** `DECLARE EXIT HANDLER FOR SQLEXCEPTION`
* **Datos capturados:** Nombre de la tabla, objeto (función/proc), operación, código de error MySQL y mensaje descriptivo.

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

## Requisitos

* MySQL Server 8.0 o superior.
* MySQL Workbench (recomendado para visualización de logs).

> Nota: Antes de ejecutar los CRUDs, es obligatorio correr los scripts de creación de tablas y las funciones de validación (`fn_validar_...`) para evitar errores de dependencia.

---

Si quieres, puedo agregar directamente la sección **Próximos Pasos** con ideas de Triggers, Vistas y reportes para completar el README.

¿Quieres que lo haga?
