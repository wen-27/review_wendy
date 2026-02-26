
# Sistema de Gestión Médica 

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

## Particionamiento de Tablas

El sistema utiliza **particionamiento** para optimizar el rendimiento y la gestión de datos en tablas críticas que experimentan alto volumen de consultas y crecimiento continuo.

### Tablas Particionadas

1. **Citas**
   - **Estrategia:** Partición por rango basado en el año de la fecha de la cita (`YEAR(fecha_cita)`)
   - **Justificación:** Las citas son el eje central del flujo clínico. El particionamiento por año permite:
     - Búsqueda rápida de citas por periodo (consultas de productividad, estadísticas)
     - Mantenimiento eficiente (eliminación de datos antiguos por partición)
     - Mejor rendimiento en consultas de informes diarios y mensuales
   - **Particiones:** `p2024`, `p2025`, `p2026`, `p_futuro`

2. **Reporte Diario de Productividad**
   - **Estrategia:** Partición por rango basado en la fecha de atención (`fecha_atencion`)
   - **Justificación:** Este reporte se genera automáticamente cada día y acumula datos históricos. El particionamiento permite:
     - Consultas rápidas por periodo para análisis de productividad
     - Archivado eficiente de datos antiguos
     - Optimización de consultas de tendencias y métricas
   - **Particiones:** `p_old` (datos antiguos), `p2025_q1`, `p2025_q2`, `p_max`

3. **Logs de Auditoría**
   - **Estrategia:** Partición por rango basado en timestamp (`UNIX_TIMESTAMP(fecha_hora)`)
   - **Justificación:** Los logs capturan errores y eventos del sistema de forma continua. El particionamiento permite:
     - Búsqueda rápida de eventos por periodo
     - Mantenimiento eficiente (rotación de logs antiguos)
     - Mejor rendimiento en consultas de auditoría y troubleshooting
   - **Particiones:** `p_inicio`, `p_actual`, `p_futuro`

### Beneficios del Particionamiento

- **Rendimiento:** Consultas más rápidas al acceder solo a particiones relevantes
- **Mantenimiento:** Eliminación eficiente de datos antiguos sin afectar particiones activas
- **Escalabilidad:** Mejor manejo de grandes volúmenes de datos
- **Disponibilidad:** Operaciones de mantenimiento en particiones específicas sin bloquear todo el sistema

---

## Análisis de Funcionamiento de una Clínica Universitaria

### Flujo de Atención Médica

1. **Registro y Agendamiento**
   - Los pacientes se registran en el sistema con datos básicos
   - La recepción agenda citas considerando disponibilidad de médicos y sedes
   - Las citas se almacenan con fecha, hora, médico asignado y sede

2. **Atención Clínica**
   - El médico accede al historial del paciente
   - Realiza el diagnóstico y registra los hallazgos
   - Prescribe medicamentos y genera la receta electrónica

3. **Gestión Académica**
   - Los médicos están vinculados a facultades específicas
   - Las especialidades definen el campo de acción de cada profesional
   - El sistema permite el seguimiento académico y la gestión de recursos

4. **Reportes y Productividad**
   - Sistema genera informes automáticos de productividad diaria
   - Permite el seguimiento de métricas por médico, especialidad y sede
   - Facilita la toma de decisiones basada en datos

### Patrones Identificados

1. **Acceso Frecuente por Fecha**
   - Las consultas más comunes buscan información por rangos de fechas
   - El particionamiento por fecha optimiza estas operaciones críticas

2. **Búsqueda por Médico y Especialidad**
   - Los pacientes buscan médicos por especialidad
   - La administración consulta la carga de trabajo por médico
   - Los índices en `id_medico` y `id_especialidad` optimizan estas búsquedas

3. **Historial de Pacientes**
   - Los médicos necesitan acceso rápido al historial clínico
   - Las recetas y diagnósticos se asocian a las citas para mantener el historial
   - Las vistas permiten una consulta simplificada del historial

4. **Gestión de Inventarios Médicos**
   - El seguimiento de medicamentos recetados permite la gestión de inventarios
   - Las consultas por medicamento ayudan en la planificación de compras

### Datos para Búsqueda desde la Vista del Médico

Desde la vista del médico (`vw_medicos_jerarquia`), se pueden realizar búsquedas utilizando:

1. **Facultad** - Para consultar médicos por dependencia académica
2. **Especialidad** - Para buscar profesionales por área médica
3. **Nombre del Médico** - Para consultas específicas de personal
4. **Sede Hospitalaria** - Para gestionar la distribución geográfica del personal

Estos datos permiten una gestión eficiente del recurso humano médico, facilitando la asignación de turnos, la cobertura de guardias y la planificación de servicios según la especialidad requerida.

---
