USE Sistema_Medicos;

-- 1. FUNCIÓN DE VALIDACIÓN
DROP FUNCTION IF EXISTS fn_validar_receta;
DELIMITER //
CREATE FUNCTION fn_validar_receta(p_id_cita INT, p_med VARCHAR(100)) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    -- Validamos que la cita exista en la tabla maestra 'citas'
    IF NOT EXISTS(SELECT 1 FROM citas WHERE id_cita = p_id_cita) THEN 
        RETURN 'Error: La cita médica no existe';
    ELSEIF p_med = '' THEN 
        RETURN 'Error: El nombre del medicamento no puede estar vacío';
    ELSE 
        RETURN 'OK';
    END IF;
END //

-- A. CREAR 
DROP PROCEDURE IF EXISTS sp_crear_receta;
//
CREATE PROCEDURE sp_crear_receta(IN p_id_cita INT, IN p_med VARCHAR(100), IN p_dosis VARCHAR(50))
BEGIN
    DECLARE v_valida VARCHAR(100);
    -- Manejador de errores con ROLLBACK y registro en logs_errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('recetas', 'sp_crear_receta', @errno, @msg);
        SELECT CONCAT('ERROR SISTEMA: ', @msg) AS Mensaje;
    END;

    SET v_valida = fn_validar_receta(p_id_cita, p_med);
    
    IF v_valida = 'OK' THEN
        START TRANSACTION;
            -- Usamos nombres de STMT únicos para evitar el Error 2014
            SET @sql_ins_rec = 'INSERT INTO recetas (id_cita, medicamento, dosis) VALUES (?, ?, ?)';
            SET @c_id = p_id_cita, @m_txt = p_med, @d_txt = p_dosis;
            
            PREPARE stmt_ins_rec FROM @sql_ins_rec;
            EXECUTE stmt_ins_rec USING @c_id, @m_txt, @d_txt;
            DEALLOCATE PREPARE stmt_ins_rec;
        COMMIT;
        SELECT 'ÉXITO: Medicamento agregado a la receta' AS Mensaje;
    ELSE 
        SELECT v_valida AS Mensaje; 
    END IF;
END //

-- B. LEER 
DROP PROCEDURE IF EXISTS sp_listar_receta_cita;
//
CREATE PROCEDURE sp_listar_receta_cita(IN p_id_cita INT)
BEGIN
    -- Selección directa para liberar el canal de datos inmediatamente
    SELECT 
        id_cita AS 'Cita #',
        medicamento AS 'Medicamento',
        dosis AS 'Dosis Prescrita'
    FROM recetas 
    WHERE id_cita = p_id_cita;
END //

-- C. ACTUALIZAR 
DROP PROCEDURE IF EXISTS sp_actualizar_receta;
//
CREATE PROCEDURE sp_actualizar_receta(
    IN p_id_cita INT, 
    IN p_med VARCHAR(100), 
    IN p_nueva_dosis VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('recetas', 'sp_actualizar_receta', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo actualizar la prescripción' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM recetas WHERE id_cita = p_id_cita AND medicamento = p_med) THEN
            SET @sql_upd_rec = 'UPDATE recetas SET dosis = ? WHERE id_cita = ? AND medicamento = ?';
            SET @ndos = p_nueva_dosis, @cid = p_id_cita, @medm = p_med;
            
            PREPARE stmt_upd_rec FROM @sql_upd_rec;
            EXECUTE stmt_upd_rec USING @ndos, @cid, @medm;
            DEALLOCATE PREPARE stmt_upd_rec;
            
            COMMIT;
            SELECT 'ÉXITO: Dosis actualizada correctamente' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: El medicamento no está en esta receta' AS Mensaje; 
        END IF;
END //

-- D. ELIMINAR 
DROP PROCEDURE IF EXISTS sp_eliminar_medicamento;
//
CREATE PROCEDURE sp_eliminar_medicamento(IN p_id_cita INT, IN p_med VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO logs_errores (nombre_tabla, nombre_procedimiento, codigo_error, mensaje_error)
        VALUES ('recetas', 'sp_eliminar_medicamento', @errno, @msg);
        SELECT 'ERROR SISTEMA: No se pudo eliminar el medicamento' AS Mensaje;
    END;

    START TRANSACTION;
        IF EXISTS(SELECT 1 FROM recetas WHERE id_cita = p_id_cita AND medicamento = p_med) THEN
            SET @sql_del_rec = 'DELETE FROM recetas WHERE id_cita = ? AND medicamento = ?';
            SET @cid_del = p_id_cita, @med_del = p_med;
            
            PREPARE stmt_del_rec FROM @sql_del_rec;
            EXECUTE stmt_del_rec USING @cid_del, @med_del;
            DEALLOCATE PREPARE stmt_del_rec;
            
            COMMIT;
            SELECT 'ÉXITO: Medicamento removido de la receta' AS Mensaje;
        ELSE 
            ROLLBACK;
            SELECT 'VALIDACIÓN: Registro no encontrado' AS Mensaje; 
        END IF;
END //

DELIMITER ;