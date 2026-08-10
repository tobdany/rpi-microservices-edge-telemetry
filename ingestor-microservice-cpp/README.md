# 🚀 Edge Telemetry Ingestion Microservice (`ingestor-microservice-cpp`)

Este componente es un **microservicio de ingesta de telemetría de alto rendimiento**, desarrollado en **C++17**. Su propósito principal es recibir las métricas de monitoreo de hardware enviadas por nodos Edge (como dispositivos Raspberry Pi), validar la información en tiempo real (detección de sobrecalentamiento) y persistir las lecturas directamente en una base de datos **MySQL**.

---

## 🏗️ Arquitectura del Servicio

```text
[ Nodo Edge / Postman ]
          │
          │  HTTP POST / GET
          ▼
┌────────────────────────────────────────────────────────┐
│        Microservicio Ingestor C++ (Puerto 8085)        │
├────────────────────────────────────────────────────────┤
│  • Servidor HTTP Multihilo (`httplib.h`)                │
│  • Parser de Payloads JSON (`nlohmann/json.hpp`)       │
│  • Lógica de Alertas (>70°C)                          │
│  • Conector Nativo C/C++ (`libmysqlclient`)            │
└────────────────────────────────────────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────┐
│             Base de Datos MySQL (Real)                 │
│         Tabla: `node_telemetry`                        │
└────────────────────────────────────────────────────────┘
```
---
## 🛠️ Tecnologías y Librerías
-Lenguaje: C++17
-Servidor HTTP: httplib.h (Header-only)
-Manejo de JSON: nlohmann/json.hpp (Header-only)
-Base de Datos: MySQL Server 8.0
-Cliente MySQL: libmysqlclient-dev (MySQL C API)
-Concurrencia: POSIX Threads (pthread)

---
## Requisitos e Instalación

### Dependencias del sistema

```bash
sudo apt update
sudo apt install build-essential libmysqlclient-dev -y
```
### Cabeceras
```bash
cd src

wget [https://raw.githubusercontent.com/yhirose/cpp-httplib/master/httplib.h](https://raw.githubusercontent.com/yhirose/cpp-httplib/master/httplib.h)

wget [https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp](https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp)
```

---
## Compilar

Para compilar el código vinculando la librería cliente de MySQL y el soporte de multihilo.

```bash
g++ -std=c++17 main.cpp -lmysqlclient -pthread -o api_server
```

Para iniciar el microservicio. El servidor iniciará escuchando en http://localhost:8085

```bash
./api_server
```

---
## Endpoints
### Ingesta de métricas (Post /telemetry)
**URL:** http://localhost:8085/telemetry  
**Método:** POST  
**Headers:** Content-Type: application/json  

```bash
{
  "node_id": "rpi-oaxaca-01",
  "hardware": {
    "cpu_temp": 78.5,
    "cpu_usage_pct": 65.0,
    "ram_used_mb": 1200
  }
}
```
201 Created: Ingesta e inserción en MySQL exitosa.  
400 Bad Request: Formato JSON inválido.  
500 Internal Server Error: Fallo al conectar o insertar en MySQL.  

---
### Consulta de Historial (GET /telemetry)
**URL:** http://localhost:8085/telemetry  
**Método:** GET  

```bash
{
    "count": 1,
    "data": [
        {
            "cpu_temp_celsius": 78.5,
            "cpu_usage_pct": 65.0,
            "node_id": "rpi-oaxaca-01",
            "reading_id": 1,
            "recorded_at": "2026-08-09 21:50:12",
            "used_ram_mb": 1200
        }
    ],
    "status": "success"
}
```