-- ============================================================
-- Registro de los datos
-- ============================================================

USE rpi_edge_monitor;

-- Registrar el nodo 
INSERT INTO edge_nodes (node_id, hostname, ip_address, status) 
VALUES ('rpi-oaxaca-01', 'raspberrypi-master', '192.168.1.150', 'ONLINE')
ON DUPLICATE KEY UPDATE status = 'ONLINE';

-- Registrar los contenedores Docker
INSERT INTO containers (container_id, node_id, service_name, image_name, status) VALUES 
('c1a2b3c4d5', 'rpi-oaxaca-01', 'mi-blog-personal', 'nginx:alpine', 'RUNNING'),
('e6f7g8h9i0', 'rpi-oaxaca-01', 'mysql-database', 'mysql:8.0', 'RUNNING'),
('j1k2l3m4n5', 'rpi-oaxaca-01', 'cpp-telemetry-api', 'telemetry-app:v1', 'RUNNING')
ON DUPLICATE KEY UPDATE status = 'RUNNING';

-- Insertar la lectura de hardware
INSERT INTO node_telemetry (node_id, cpu_temp_celsius, cpu_usage_pct, used_ram_mb)
VALUES ('rpi-oaxaca-01', 52.4, 45.2, 1850);

-- Guardar explícitamente el último ID generado en una variable @last_reading
SET @last_reading = LAST_INSERT_ID();

-- Insertar las métricas referenciando la variable @last_reading
INSERT INTO container_metrics (container_id, reading_id, cpu_percent, memory_usage_mb) VALUES
('c1a2b3c4d5', @last_reading, 12.1, 210.5),
('e6f7g8h9i0', @last_reading, 28.4, 850.0),
('j1k2l3m4n5', @last_reading, 2.5, 18.2);