# ⚡ Integraciones — Setup para Claude Code

## Resumen

Claude Code necesita 4 integraciones para funcionar como PM:

| Integracion | Metodo | Para que |
|-------------|--------|----------|
| 📧 Gmail | MCP Nativo (OAuth) | Leer/buscar correos + crear borradores |
| 📅 Calendar | MCP Nativo (OAuth) | Leer eventos + verificar disponibilidad |
| 📱 WhatsApp | Chrome MCP (browser) | Revisar chats via web.whatsapp.com |
| 🗄️ PostgreSQL | Conexion directa | Leer/escribir todas las tablas |

## 1. 📧 Gmail MCP (Nativo)

### Setup
1. En Claude Code, ve a **Settings → MCP Servers**
2. Habilita **Gmail**
3. Autoriza con tu cuenta Google (OAuth)

### Que puede hacer el agente
- `gmail_search_messages` — Buscar con sintaxis Gmail (`is:unread`, `from:`, `after:`)
- `gmail_read_message` — Leer contenido completo de un email
- `gmail_create_draft` — Crear borrador (NUNCA envia directo)
- `gmail_get_profile` — Ver cuenta conectada

### Busquedas utiles
```
# Correos no leidos de trabajo
is:unread -category:promotions -category:social after:2026/04/01

# Correos enviados a alguien (verificar respuesta)
in:sent to:contacto@email.com after:2026/03/15

# Correos de un cliente especifico
from:jorge@cliente.com OR to:jorge@cliente.com
```

## 2. 📅 Google Calendar MCP (Nativo)

### Setup
1. En Claude Code, ve a **Settings → MCP Servers**
2. Habilita **Google Calendar**
3. Autoriza con tu cuenta Google

### Que puede hacer el agente
- `gcal_list_events` — Listar eventos de un rango de fechas
- `gcal_create_event` — Crear eventos
- `gcal_find_meeting_times` — Buscar horarios disponibles
- `gcal_find_my_free_time` — Ver tiempo libre

### Uso diario
Cada manana el agente consulta:
```
gcal_list_events(timeMin="hoy", timeMax="hoy+1", timeZone="America/Lima")
```
Y genera la agenda del dia con participantes, links de Meet, y contexto.

### Transcripciones de reuniones
Si usas **tl;dv**, **Read.ai** o **Fireflies**, las notas llegan por correo. El agente puede:
- Leerlas via Gmail MCP
- Extraer action items
- Crear tareas automaticamente en la BD

## 3. 📱 WhatsApp Web (Chrome MCP)

### Setup
1. Instala la extension **Claude in Chrome**
2. Abre Chrome y navega a `https://web.whatsapp.com/`
3. Escanea el QR code con tu telefono
4. **Manten la sesion abierta** mientras Claude Code trabaja

### Que puede hacer el agente
- Navegar por la lista de chats
- Filtrar por "No leidos", "Grupos", etc.
- Abrir chats individuales y leer mensajes
- Scrollear por el historial
- Tomar screenshots para analizar contenido visual
- **NO puede enviar mensajes** (solo propone borradores)

### Limitaciones
- Requiere sesion activa en Chrome
- Si WhatsApp se desconecta, el agente no puede revisar
- No tiene acceso a llamadas ni videollamadas
- Los mensajes de media (fotos, audios) se ven pero no se pueden transcribir directamente

## 4. 🗄️ PostgreSQL (Conexion Directa)

### Setup
```bash
# .env
DATABASE_URL=postgresql://user:password@host:port/database
ENCRYPTION_KEY=tu-clave-fernet-aqui
```

El agente ejecuta queries SQL directamente via Python (`psycopg2`).

### Patron de conexion
```python
from db.connection import get_db

with get_db() as conn:
    cur = conn.cursor()
    cur.execute("SELECT * FROM tasks WHERE status = 'Pendiente'")
    rows = cur.fetchall()
```

### Proveedores recomendados
| Proveedor | Ventaja | Costo |
|-----------|---------|-------|
| **Railway** | Deploy rapido, SSL incluido | Desde $5/mes |
| **Supabase** | UI web, API REST gratis | Free tier generoso |
| **Local** | Sin costo, control total | Gratis |
