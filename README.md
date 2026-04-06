# 🤖 PM Claude Code — Tu Project Manager con IA

![Claude Code](https://img.shields.io/badge/Claude_Code-Anthropic-orange?logo=anthropic)
![Python](https://img.shields.io/badge/Python-3.12+-blue?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-336791?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-green)

> Convierte Claude Code en tu asistente de gestion de proyectos. Revisa WhatsApp, triagea correos, gestiona calendario, trackea tareas, genera reportes diarios y crea borradores de mensajes — todo desde la terminal.

---

## 🎯 Que problema resuelve?

| Sin PM Agent | Con PM Agent |
|---|---|
| ❌ Revisar 50+ chats de WhatsApp manualmente | ✅ El agente escanea chats, filtra exclusiones, extrae pendientes |
| ❌ Follow-ups perdidos en hilos de correo | ✅ Revisa enviados + recibidos, crea borradores, trackea respuestas |
| ❌ Olvidar reuniones y no prepararse | ✅ Briefing diario con contexto por reunion |
| ❌ No saber el estado de cada cliente/proyecto | ✅ Vista centralizada por empresa con contactos, tareas, billing |
| ❌ Horas armando status updates | ✅ Reporte diario automatico con borradores listos para enviar |

---

## 🏗️ Arquitectura General

La estructura central gira alrededor de **empresas (companies)**. Todo se organiza desde ahi:

```
                        🏢 EMPRESA (Company)
                              |
          +--------+----------+----------+---------+
          |        |          |          |         |
        👥       📋        💰        📊       🔐
     Contactos  Tareas   Billing  Proyectos  Credenciales
                  |                   |
                  v                   v
            📌 Seguimientos      🔗 Repos GitHub
            (cada msg/correo       (contexto tecnico
             genera tarea)          para el agente)
```

Adicionalmente tenemos modulos transversales:

```
📱 WhatsApp ──→ Mensajes clave + Contactos + Exclusiones
📧 Gmail ──→ Emails accionables + Borradores + Seguimiento enviados
📅 Calendar ──→ Reuniones + Transcripciones + Contexto
💼 Pipeline ──→ Cotizaciones + Seguimiento comercial
📝 Reportes ──→ Briefing diario + Weekly review
```

---

## ⚡ Requisitos

### Claude Code (obligatorio)
Este proyecto esta disenado para [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Necesitas:

- ✅ **Claude Code CLI** instalado y autenticado
- ✅ **Gmail MCP** conectado nativamente (OAuth)
- ✅ **Google Calendar MCP** conectado nativamente (OAuth)
- ✅ **Chrome MCP** (Claude in Chrome) para WhatsApp Web
- ✅ **PostgreSQL** accesible (Railway, Supabase o local)
- ✅ **WhatsApp Web** con sesion abierta en el navegador

### Recomendaciones
- 🎙️ Herramienta de transcripcion de reuniones (tl;dv, Read.ai, Fireflies) conectada al calendario para que las notas de reunion se puedan importar
- 📂 Repositorios GitHub de tus proyectos accesibles, para que el agente tenga contexto tecnico al revisar tareas

---

## 🚀 Quick Start

### 1. Clona el repositorio
```bash
git clone https://github.com/tamibot/pm_claude_code.git
cd pm_claude_code
```

### 2. Configura la base de datos
```bash
cp templates/.env.example .env
# Edita .env con tu DATABASE_URL y ENCRYPTION_KEY
python scripts/migrate.py
```

### 3. Copia la configuracion de Claude Code
```bash
cp -r .claude/ tu-proyecto/.claude/
cp templates/CLAUDE.md tu-proyecto/CLAUDE.md
```

### 4. Conecta las integraciones nativas en Claude Code
- Gmail MCP → Settings → MCP Servers → Gmail
- Google Calendar MCP → Settings → MCP Servers → Calendar

### 5. Abre WhatsApp Web
- Navega a `web.whatsapp.com` en Chrome
- Escanea QR con tu telefono
- Manten la sesion activa

### 6. Ejecuta tu primer brief
```
/daily-brief
```

---

## 📱 Guia de Revision WhatsApp

El agente sigue un proceso estructurado para revisar WhatsApp:

### Paso 1: Cargar lista de exclusiones
Antes de revisar cualquier chat, el agente consulta la tabla `whatsapp_exclusions` para saber que chats saltar:

```sql
SELECT chat_name, exclusion_type FROM whatsapp_exclusions ORDER BY exclusion_type;
```

| Tipo | Ejemplo | Que hace |
|------|---------|----------|
| `personal` | Familia, amigos | Salta completamente |
| `comunidad` | n8n Latam, Kommo Socios | Salta (ruido) |
| `social` | Padel, cumpleanos | Salta |
| `spam` | Bancos, tiendas, bots | Salta |
| `operadora` | Movistar, Claro | Salta |

### Paso 2: Escanear chats no leidos
El agente filtra por "No leidos" para identificar rapidamente los urgentes y separa:
- 🔴 Chats de trabajo (clientes, equipo, grupos de proyecto)
- ⚪ Chats excluidos (los salta)

### Paso 3: Entrar a cada chat de trabajo
Para cada chat de trabajo, el agente:
1. **Abre el chat** y scrollea hasta la fecha limite indicada
2. **Lee los mensajes** identificando quien dijo que y cuando
3. **Extrae pendientes**: preguntas sin responder, solicitudes, compromisos
4. **Identifica numeros no guardados** y propone nombre + contexto
5. **Registra mensajes clave** en `whatsapp_messages` con `action_required`

### Paso 4: Priorizar chats importantes
Si el usuario indica chats prioritarios, el agente los revisa primero y con mas detalle:

```
Ejemplo: "Revisa primero los grupos de Proper y los chats con Jesus Doza"
```

### Paso 5: Registrar hallazgos
Todo se guarda en la BD:
- Mensajes accionables → `whatsapp_messages`
- Nuevos contactos → `whatsapp_contacts` (con telefono, nombre sugerido, contexto)
- Nuevas exclusiones → `whatsapp_exclusions`
- Tareas creadas → `tasks` (con company_id, contexto del mensaje)
- Log de revision → `review_log`

### Reglas inquebrantables
- 🚫 **NUNCA enviar mensajes** sin confirmacion explicita del usuario
- 🚫 **NUNCA saltar la lista de exclusiones**
- ✅ **SIEMPRE crear tarea de seguimiento** cuando se envia algo
- ✅ **SIEMPRE registrar numeros desconocidos** con propuesta de nombre

---

## 📧 Guia de Revision Gmail

### Correos recibidos
El agente busca correos no leidos, los clasifica y actua:

```
is:unread -category:promotions -category:social after:YYYY/MM/DD
```

| Clasificacion | Accion |
|---------------|--------|
| 💼 Trabajo | Registrar + crear tarea + borrador respuesta |
| 📊 Reporte | Registrar + extraer metricas clave |
| 🔔 Notificacion | Registrar si es relevante |
| 📰 Newsletter | Saltar |
| 🗑️ Spam | Saltar |

### Correos enviados (seguimiento)
El agente tambien revisa los correos **enviados** para detectar si hubo respuesta:

```
in:sent after:YYYY/MM/DD to:contacto@email.com
```

Si no hubo respuesta en X dias, crea tarea de seguimiento y propone borrador de reiteracion.

### Regla de seguimiento
Cada vez que se envia un correo o mensaje:
1. Se crea una tarea de tipo "Seguimiento" con fecha de vencimiento
2. Si la persona responde, se cierra la tarea
3. Si no responde, aparece en el reporte diario como pendiente

---

## 📅 Integracion con Calendario

El agente usa Google Calendar MCP para:

1. **Listar eventos del dia/semana** con participantes y links
2. **Detectar conflictos** de horarios
3. **Preparar contexto** por reunion (tareas pendientes del cliente, ultimo contacto)
4. **Verificar asistencia** a reuniones pasadas

### Transcripciones de reuniones
Si usas tl;dv, Read.ai u otra herramienta, las notas/transcripciones llegan por correo y el agente puede:
- Extraer action items
- Crear tareas automaticamente
- Actualizar el estado del proyecto

---

## 📊 Estructura de la Base de Datos

### Concepto central: Todo gira alrededor de Empresas

```
🏢 COMPANIES (empresa/cliente)
 ├── 👥 CONTACTS (personas de esa empresa)
 ├── 📋 TASKS (pendientes asociados)
 ├── 💰 BILLING (facturacion: ingresos y egresos)
 ├── 📊 PROJECTS (repos, entregables)
 ├── 🔐 CREDENTIALS (accesos cifrados)
 ├── 📝 NOTES (notas e historial)
 └── 📅 MEETINGS (reuniones con action items)
```

### Modulo Comercial (Pipeline)
```
💼 QUOTATIONS (cotizaciones/oportunidades)
 ├── company_id → vinculado a empresa
 ├── status: Seguimiento → Cotizacion Enviada → Ganado/Perdido
 ├── amount_usd → monto de la oportunidad
 └── next_followup_date → cuando dar seguimiento
```

### Modulo WhatsApp
```
📱 WHATSAPP_CONTACTS (directorio)
 ├── chat_name, phone, chat_type
 ├── company_id → vincula chat a empresa
 └── should_review → flag para el agente

🚫 WHATSAPP_EXCLUSIONS (lista de NO revisar)
 └── chat_name, exclusion_type

💬 WHATSAPP_MESSAGES (mensajes registrados)
 ├── chat_name, sender, message_preview
 ├── action_required → flag de pendiente
 └── task_id → tarea generada
```

### Modulo Email
```
📧 EMAIL_TRACKING (correos accionables)
 ├── from_address, subject, received_date
 ├── company_id → vincula a empresa
 ├── action_required → flag de pendiente
 └── task_id → tarea generada
```

### Tablas de soporte
```
🏷️ SECTORS (industrias: Inmobiliario, Salud, Tech...)
📝 DAILY_BRIEFINGS (resumenes diarios en JSONB)
🏷️ TAGS + ENTITY_TAGS (etiquetas flexibles)
📋 ACTIVITY_LOG (auditoria de cambios)
📥 INBOX (items sin procesar)
📊 REVIEW_LOG (log de revisiones WA/Gmail)
```

---

## 📝 Reporte Diario — Estructura

Cada dia el agente genera un documento con esta estructura:

### Ejemplo: `REPORTE-2026-04-07.md`

```markdown
# Reporte Diario — Lunes 7 de abril 2026

## 📅 Agenda del dia
| Hora | Evento | Notas |
|------|--------|-------|
| 8:00 | Daily Proper | Meet: xyz. Temas: indicadores, tarjeta Meta |
| 14:00 | Consultoria Thiago Lopes | DSV Marketing Panama |
| 19:00 | Charla AI First Founders | Preparar demo n8n + Claude Code |

## 🔴 Tareas urgentes HOY
### Para Martin
- [ ] Confirmar a Jorge lanzar campana Novo3
- [ ] Responder Jesus Doza sobre Oftalmosalud

### Para Carlos
- [ ] JCD: Bots Kommo no responden

### Para Nykoll
- [ ] Seguimiento Femme (3 marcas)

## ✉️ Borradores de correo creados
1. **Victor TM** (vmangiante@tmgi.com.pe) — Seguimiento licencias KommoCRM
2. **Stephie Zorrilla** (szorrilla@japansolutions.pe) — Reagendar consultoria

## 💬 Mensajes WhatsApp sugeridos
**Jorge campos:**
> Jorge, buen dia. Sobre la tarjeta: dale, procedamos con lanzar
> la campana de Novo 3 desde cuenta Proper. Mantenme al tanto.

**Jesus Doza (grupo Oftalmosalud):**
> Hola Jesus, el formulario TikTok lo estamos terminando.
> Nos reunimos martes? Avisa horario.

## 💰 Cobranzas pendientes
| Cliente | Monto | Estado |
|---------|-------|--------|
| Grupo Norte | $402.38 | Pendiente |
| Schumacher | $250 | Pendiente (PayPal) |

## ⏳ Seguimientos sin respuesta
| Enviado a | Fecha envio | Medio | Dias sin rta |
|-----------|-------------|-------|-------------|
| Victor TM | 01/04 | Gmail | 5 dias |
| Antonio Martinez | 28/03 | WA | 9 dias |

## 📊 Estado por empresa (top 5 activas)
### Proper
- Tarjeta Meta vencida (Jorge propone usar cuenta Proper)
- Indicadores inversiones en rojo (Valeria presenta plan lunes)
- MyHome: WA no funciona, verificacion Meta rechazada

### JCD Escuela
- Bots Kommo no responden, etapas se cruzan

### Jesus Doza (3 marcas)
- Oftalmosalud: reunion pendiente
- Femme: doctor ocupado

## ❌ Tareas vencidas no cerradas
| ID | Tarea | Vencio | Accion sugerida |
|----|-------|--------|-----------------|
| 208 | Landing Alquila Seguro | 19/2 | Reagendar o cerrar |
| 213 | Distrillantas bot IA | 19/2 | Carlos debe terminar |
```

---

## 🔄 Flujo Diario Completo

```
🌅 MANANA
  │
  ├─ 1. Consultar calendario del dia
  │     └─ Listar reuniones con contexto y participantes
  │
  ├─ 2. Revisar tareas vencidas y de hoy
  │     └─ Organizar por responsable (CEO, Dev, Comercial)
  │
  ├─ 3. Revisar WhatsApp (con lista de exclusiones)
  │     ├─ Filtrar no leidos
  │     ├─ Entrar a cada chat de trabajo
  │     ├─ Extraer pendientes y contactos nuevos
  │     └─ Crear tareas por cada accion requerida
  │
  ├─ 4. Revisar Gmail
  │     ├─ Correos recibidos no leidos
  │     ├─ Correos enviados sin respuesta
  │     ├─ Crear borradores de follow-up
  │     └─ Crear tareas de seguimiento
  │
  ├─ 5. Revisar cobranzas pendientes
  │     └─ Listar montos, contactos, metodos de pago
  │
  └─ 6. Generar REPORTE DIARIO
        ├─ Agenda del dia
        ├─ Tareas urgentes por responsable
        ├─ Borradores de correo listos
        ├─ Mensajes WA sugeridos con contexto
        ├─ Seguimientos sin respuesta
        ├─ Estado por empresa
        └─ Tareas vencidas para decidir
```

---

## 🔗 Conexion con Repositorios

Si tus proyectos tienen repos en GitHub, puedes vincularlos en la tabla `projects`:

```sql
INSERT INTO projects (company_id, name, repo_url, tech_stack, status)
VALUES (22, 'Bot IA Proper', 'https://github.com/org/bot-proper', 'n8n, KommoCRM, WA API', 'Activo');
```

El agente usa esta info para:
- Dar contexto tecnico cuando revisa tareas del proyecto
- Saber que stack usa cada cliente
- Relacionar commits con avance de tareas

---

## 📂 Estructura del Proyecto

```
pm_claude_code/
│
├── 📖 README.md                    ← Esta guia
├── 📄 LICENSE                      ← MIT
├── 📦 requirements.txt             ← Dependencias Python
│
├── 📚 docs/                        ← Guias detalladas
│   ├── 01-database-setup.md        ← Esquema completo (20 tablas)
│   ├── 02-integrations.md          ← Gmail, Calendar, WhatsApp, PostgreSQL
│   ├── 03-agent-commands.md        ← /daily-brief, /review-wa, /review-gmail
│   ├── 04-whatsapp-review.md       ← Guia detallada revision WA
│   └── 05-daily-report.md          ← Estructura del reporte diario
│
├── 📋 templates/                   ← Plantillas listas para usar
│   ├── CLAUDE.md                   ← Instrucciones para el agente
│   ├── .env.example                ← Variables de entorno
│   ├── daily-report-template.md    ← Template del reporte diario
│   └── weekly-review.md            ← Template de revision semanal
│
├── 💡 examples/                    ← Ejemplos de datos
│   ├── exclusion-list.sql          ← Lista de exclusiones WA ejemplo
│   ├── sample-tasks.sql            ← Tareas de ejemplo
│   └── sample-companies.sql        ← Empresas de ejemplo
│
├── 🔧 scripts/                     ← Scripts de utilidad
│   ├── migrate.py                  ← Ejecutar esquema en BD
│   └── seed.py                     ← Cargar datos de ejemplo
│
└── ⚙️ .claude/                     ← Configuracion Claude Code
    ├── commands/
    │   ├── daily-brief.md           ← /daily-brief
    │   ├── review-wa.md             ← /review-wa
    │   ├── review-gmail.md          ← /review-gmail
    │   └── update-task.md           ← /update-task
    ├── rules/
    │   ├── project-conventions.md   ← Convenciones de datos
    │   └── team-responsibilities.md ← Roles del equipo
    └── agents/
        └── task-manager.md          ← Agente de gestion de tareas
```

---

## 🛡️ Seguridad y Privacidad

- 🔒 Passwords cifrados con **Fernet** antes de almacenar
- 🔑 Encryption key en variable de entorno, nunca en codigo
- 📁 `.env` y credenciales en `.gitignore`
- 🚫 El agente **NUNCA envia mensajes** sin confirmacion
- 🚫 El agente **NUNCA crea cuentas** ni ingresa datos financieros
- 📋 Todas las acciones quedan logueadas en `activity_log` y `review_log`

---

## 🗺️ Roadmap

- [x] Esquema de base de datos (20 tablas)
- [x] Revision WhatsApp con lista de exclusiones
- [x] Triaje Gmail + creacion de borradores
- [x] Integracion Google Calendar
- [x] Generacion de briefing diario
- [x] Seguimiento de correos enviados sin respuesta
- [x] Creacion automatica de tareas de seguimiento
- [ ] Revisiones automaticas programadas (cron)
- [ ] Conexion con transcripciones de reuniones (tl;dv, Read.ai)
- [ ] Dashboard web con metricas en tiempo real
- [ ] Notificaciones push de pendientes criticos
- [ ] Multi-idioma (ES/EN/PT)

---

## 🤝 Contribuir

| Area | Que se necesita |
|------|----------------|
| 📊 Esquemas BD | Nuevas tablas para industrias especificas |
| ⚙️ Comandos | Nuevos slash commands para flujos comunes |
| 📖 Documentacion | Guias en otros idiomas, video tutoriales |
| 📋 Templates | Plantillas por industria (inmobiliaria, salud, educacion) |

---

## 📬 Contacto

| Canal | Detalle |
|-------|---------|
| GitHub | [@tamibot](https://github.com/tamibot) |
| Email | mvelascoo@tamibot.com |
| WhatsApp | +51 995 547 575 |

---

## 📄 Licencia

MIT License — ver [LICENSE](LICENSE)

---

> 🤖 Built with Claude Code by [Creators Latam](https://github.com/tamibot) — Convirtiendo agentes de IA en companeros operativos.
