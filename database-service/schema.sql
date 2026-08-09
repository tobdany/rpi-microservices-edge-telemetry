-- ============================================================
-- Creación de las tablas
-- ============================================================

SELECT '=== MIGRACIÓN DE LA BASE DE DATOS ===' AS Status;

CREATE DATABASE IF NOT EXISTS rpi_edge_monitor;
USE rpi_edge_monitor;
SELECT '-> Base de datos rpi_edge_monitor seleccionada/creada correctamente' AS Status;

-- Eliminar tablas en orden inverso a sus dependencias
DROP TABLE IF EXISTS container_metrics;
DROP TABLE IF EXISTS node_telemetry;
DROP TABLE IF EXISTS containers;
DROP TABLE IF EXISTS edge_nodes;

-- Creación de la tabla de dispositivos físicos 
CREATE TABLE edge_nodes (
    node_id VARCHAR(50) PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL, -- Nombre de red de la Raspberry Pi
    ip_address VARCHAR(45) NOT NULL, -- Para direcciones IPv4 o IPv6
    status ENUM('ONLINE','OFFLINE','MAINTENANCE') DEFAULT 'ONLINE',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT '-> Tabla "edge_nodes" creada exitosamente' AS Status;

-- Tabla de contenedores Docker corriendo en el nodo (Relación 1:N)
CREATE TABLE containers (
    container_id VARCHAR(64) PRIMARY KEY, -- Hash SHA-256 proveniente de Docker
    node_id VARCHAR(50) NOT NULL, -- Relación hacia la Raspberry Pi donde está instalado
    service_name VARCHAR(100) NOT NULL,
    image_name VARCHAR(100) NOT NULL, -- Imagen de Docker utilizada
    status ENUM('RUNNING','STOPPED','CRASHED') DEFAULT 'RUNNING',
    FOREIGN KEY (node_id) REFERENCES edge_nodes(node_id) ON DELETE CASCADE
);
SELECT '-> Tabla "containers" creada exitosamente' AS Status;

-- Tabla de Telemetría Global de Hardware del Nodo
CREATE TABLE node_telemetry (
    reading_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    node_id VARCHAR(50) NOT NULL,
    cpu_temp_celsius FLOAT NOT NULL,
    cpu_usage_pct FLOAT NOT NULL,
    used_ram_mb INT NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (node_id) REFERENCES edge_nodes(node_id) ON DELETE CASCADE,
    -- Índice compuesto para optimizar consultas de series de tiempo en dashboards
    INDEX idx_node_time (node_id, recorded_at)
);
SELECT '-> Tabla "node_telemetry" creada exitosamente' AS Status;

-- Consumo Individual por Contenedor
CREATE TABLE container_metrics (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Identificador de cada registro de consumo
    container_id VARCHAR(64) NOT NULL,
    reading_id BIGINT NOT NULL, -- La métrica está asociada al evento de lectura global
    cpu_percent FLOAT NOT NULL,
    memory_usage_mb FLOAT NOT NULL, -- RAM en MB
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (container_id) REFERENCES containers(container_id) ON DELETE CASCADE,
    FOREIGN KEY (reading_id) REFERENCES node_telemetry(reading_id) ON DELETE CASCADE,
    INDEX idx_container_time (container_id, recorded_at)
);
SELECT '-> Tabla "container_metrics" creada exitosamente' AS Status;