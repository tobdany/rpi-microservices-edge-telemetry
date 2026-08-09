# 🛠️ Mock API Service (Prototipado REST)

Este módulo representa la **Fase de Prototipado y Definición de Contrato (API-First)** del ecosistema de microservicios. 

Su propósito es congelar el formato del payload JSON y exponer endpoints simulados (*mocked*) para validar la comunicación cliente-servidor antes de implementar la persistencia y la lógica del backend en C++.

---

## 🚀 Guía de Ejecución

### Prerrequisitos
- Node.js instalado (incluye `npx`).

### Comando para Iniciar el Servidor Mock
Desde la raíz de este directorio (`mock-api-service/`), ejecuta:

```bash
npx json-server db.json --port 3000