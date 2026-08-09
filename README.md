# rpi-microservices-edge-telemetry
# 🐋 Raspberry Pi Edge Telemetry - Microservices Architecture

Sistema distribuido basado en **Arquitectura de Microservicios** diseñado para el monitoreo en tiempo real de nodos **Raspberry Pi** y sus contenedores Docker/Servicios en ejecución.

El proyecto demuestra el ciclo de vida completo de un software de backend: desde el prototipado inicial del contrato REST mediante **JSON Server**, el modelado e indexación en **MySQL**, hasta la implementación de un **microservicio nativo en C++** orientado a baja latencia e ingesta de métricas de hardware.

---

## 🏗️ Ecosistema de Microservicios

1. **Mock API Service (JSON Server):** Prototipado rápido y desacoplado para la definición del contrato REST (*API-First Design*).
2. **Ingestor Microservice (C++):** Microservicio nativo de alta eficiencia para procesar payloads JSON de telemetría con mínimo footprint de memoria y CPU en nodos ARM64.
3. **Database Layer (MySQL 8.0):** Persistencia relacional estructurada mediante un modelo $1:N$ (Nodo $\rightarrow$ Contenedores) optimizado con índices relacionales para series de tiempo.
4. **API Client & Testing (Postman):** Suite de pruebas de integración para validación de códigos de estado HTTP (`201 Created`, `400 Bad Request`, `200 OK`) y payloads JSON.

---

## 📁 Estructura del Repositorio

```text
rpi-microservices-edge-telemetry/
├── README.md                          # Documentación del ecosistema
├── .gitignore                         # Control de versiones (exclusión de binarios)
│
├── mock-api-service/                  # FASE 1: Prototipado REST (JSON Server)
│   ├── db.json                        # Dataset mock para contratos de API
│   └── README.md
│
├── database-service/                  # FASE 2: Persistencia Relacional (MySQL)
│   ├── schema.sql                     # Script DDL (Tablas, FK e Índices)
│   ├── seed.sql                       # Datos iniciales de prueba
│   └── queries.sql                    # Consultas analíticas para el Dashboard
│
├── ingestor-microservice-cpp/         # FASE 3: Microservicio de Ingesta (C++)
│   ├── CMakeLists.txt
│   ├── include/
│   │   ├── httplib.h                  # Servidor HTTP Header-only
│   │   └── json.hpp                   # Parser JSON Header-only
│   └── src/
│       └── main.cpp                   # Lógica de endpoints y reglas de negocio
│
└── api-testing-postman/               # FASE 4: Documentación de Endpoints
    └── Edge_Microservices_API.json    # Colección exportada de Postman
## 📁 Requisitos e Instalación
### Prerrequisitos
C++ Compiler: g++ (C++17 o superior) / clang / cmake

Base de Datos: MySQL 8.0+ / MySQL Workbench

Node.js & npm: (Para ejecutar JSON Server)

Cliente HTTP: Postman / Bruno / cURL
