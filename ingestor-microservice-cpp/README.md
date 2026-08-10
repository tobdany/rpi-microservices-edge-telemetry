# Microservicio Ingestor de Telemetría (C++)

Este microservicio se encarga de recibir métricas de hardware (temperatura de CPU, uso de CPU y memoria RAM) desde los nodos edge vía HTTP POST y almacenarlas en una base de datos MySQL. También expone un endpoint HTTP GET para consultar el historial de lecturas.

---

## 🚀 Requisitos Previos

Asegúrate de contar con lo siguiente instalado en tu sistema:

* **Compilador C++17** (`g++` o `clang`)
* **CMake** (v3.14 o superior)
* **Librería cliente de MySQL / MariaDB**:
  * En Debian/Ubuntu/Raspberry Pi OS: `sudo apt install libmysqlclient-dev`
  * En macOS: `brew install mysql-client`

---

## ⚙️ Configuración del Entorno (`.env`)

Crea un archivo `.env` dentro del directorio `src/` (o en la raíz de este microservicio) tomando como base la siguiente estructura de variables de entorno:

```env
# Configuración de MySQL
DB_HOST=
DB_USER=
DB_PASS=
DB_NAME=
DB_PORT=
```
---

## Compilación
```bash
cd ingestor-microservice-cpp
mkdir build && cd build
cmake ..
make
./telemetry_server
```
---
## Endpoints de la API
### Telemetría
**Método:** POST  
**Ruta:** /telemetry
```bash
{
  "node_id": "rpi-node-01",
  "hardware": {
    "cpu_temp": 55.4,
    "cpu_usage_pct": 32.1,
    "ram_used_mb": 1024
  }
}
```
### Historial
**Método:** GET  
**Ruta:** /telemetry  
(200 OK): Devuelve las últimas 10 lecturas registradas en la base de datos.