-- ============================================================
-- Creación de las consultas
-- ============================================================

USE rpi_edge_monitor;

-- Obtener el último estado completo del hardware del nodo
SELECT node_id, cpu_temp_celsius, cpu_usage_pct, used_ram_mb, recorded_at 
FROM node_telemetry 
WHERE node_id = 'rpi-oaxaca-01' 
ORDER BY recorded_at DESC LIMIT 1; -- Obtiene los datos más recientes

-- Top contenedores con mayor consumo de RAM
SELECT c.service_name, c.image_name, cm.memory_usage_mb, cm.cpu_percent
FROM containers c
JOIN container_metrics cm ON c.container_id = cm.container_id
ORDER BY cm.memory_usage_mb DESC; -- Ordena el resultado según la ram

SELECT * FROM node_telemetry ORDER BY reading_id DESC LIMIT 1;