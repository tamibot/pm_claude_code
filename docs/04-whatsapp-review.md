# 📱 Guia Detallada — Revision de WhatsApp

## Prerequisito

WhatsApp Web debe estar abierto y logueado en el navegador. Claude Code accede a el via Chrome MCP (browser automation).

## Proceso completo

### Fase 1: Preparacion

Antes de abrir cualquier chat, el agente debe:

1. **Cargar la lista de exclusiones** desde la BD:
```sql
SELECT chat_name, exclusion_type FROM whatsapp_exclusions ORDER BY exclusion_type;
```

2. **Cargar la lista de contactos conocidos** para identificar numeros guardados vs nuevos:
```sql
SELECT chat_name, phone, company_id, should_review FROM whatsapp_contacts;
```

3. **Cargar chats prioritarios** si el usuario los indico:
```
"Revisa primero los grupos de [Cliente X] y los chats con [Persona Y]"
```

### Fase 2: Escaneo inicial

1. Abrir WhatsApp Web en el navegador
2. Hacer clic en filtro **"No leidos"** para ver todos los pendientes
3. **Scrollear toda la lista** clasificando cada chat:
   - 🔴 **Trabajo** → revisar a detalle
   - ⚪ **Excluido** → saltar (personal, comunidad, spam)
   - 🟡 **Desconocido** → entrar para identificar

4. Registrar el conteo: "X chats de trabajo, Y excluidos, Z desconocidos"

### Fase 3: Revision chat por chat

Para cada chat de trabajo, el agente debe:

#### a) Abrir el chat
- Buscar por nombre o numero
- Verificar nombre del grupo y participantes

#### b) Leer mensajes
- Scrollear hasta la fecha limite indicada por el usuario
- Leer cada mensaje identificando:
  - **Quien** lo envio (nombre)
  - **Que** dijo (resumen)
  - **Cuando** (fecha y hora)
  - **Requiere accion?** (pregunta, solicitud, compromiso)

#### c) Extraer informacion
Para cada mensaje relevante, registrar en `whatsapp_messages`:
```sql
INSERT INTO whatsapp_messages (chat_name, sender, message_preview, message_date, action_required, action_description)
VALUES ('Grupo Producto', 'Jorge campos', 'La tarjeta vencio, necesitamos cambiar metodo de pago', '2026-04-01', true, 'URGENTE: cambiar tarjeta Meta Ads');
```

#### d) Identificar numeros no guardados
Si aparece un numero sin nombre:
1. Ver los **grupos en comun** para identificar quien es
2. Ver el **perfil** (nombre de negocio, descripcion)
3. Leer el **contexto de la conversacion**
4. Proponer nombre y guardar:
```sql
INSERT INTO whatsapp_contacts (chat_name, phone, chat_type, should_review, review_notes)
VALUES ('Angie Silva - Proper Tech', '+51952615177', 'individual', true, 'Maneja cuentas Google de Proper');
```

#### e) Crear tareas por pendientes
Cada accion requerida genera una tarea:
```sql
INSERT INTO tasks (company_id, title, task_type, status, priority, due_date, comments)
VALUES (22, 'Proper | Cambiar tarjeta Meta Ads - vencida', 'Operativo', 'Pendiente', 'Urgente', '2026-04-03',
'Jorge campos reporto en grupo Producto que la tarjeta vencio.');
```

### Fase 4: Revision de grupos de trabajo

Los grupos tienen dinamicas diferentes:

| Tipo de grupo | Que buscar | Ejemplo |
|---------------|-----------|---------|
| **Operativo** | Errores, entregas, bloqueos | "Producto", "Test Rentas" |
| **Marketing** | Contenido, campanas, metricas | "Marketing Proper" |
| **Ventas** | Leads, cotizaciones, cierres | "Ventas Proper" |
| **Soporte** | Bugs, solicitudes, escalaciones | "Coordinacion Kommo" |
| **Proyecto** | Avances, entregables, deadlines | "Bot IA - Werkalec" |

### Fase 5: Proponer mensajes de respuesta

Para cada pendiente, el agente propone un borrador:

```markdown
**Jorge campos (Proper):**
> Jorge, buen dia. Sobre la tarjeta: dale, procedamos con lanzar
> la campana de Novo 3 desde cuenta Proper. Mantenme al tanto.
```

El usuario decide si enviar, modificar o descartar.

### Fase 6: Registro final

Al terminar la revision:
```sql
INSERT INTO review_log (review_type, review_date, chats_reviewed, tasks_created, new_contacts, summary)
VALUES ('whatsapp', CURRENT_DATE, 15, 8, 3, 'Resumen de hallazgos principales...');
```

## Reglas de oro

1. 🚫 **NUNCA enviar mensajes** sin que el usuario confirme
2. 📝 **SIEMPRE crear tarea de seguimiento** cuando se envia algo
3. 👤 **SIEMPRE registrar numeros desconocidos** con nombre sugerido
4. 🔍 **SIEMPRE entrar a los chats** — no asumir por el preview
5. 📊 **SIEMPRE guardar en BD** — mensajes, contactos, tareas
6. 🚫 **SIEMPRE respetar exclusiones** — no revisar chats de la lista
