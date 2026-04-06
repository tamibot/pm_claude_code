# 📝 Guia — Reporte Diario

## Que es el reporte diario?

Es un documento Markdown que se genera cada manana con todo lo que necesitas saber para operar el dia. Incluye:

1. **Agenda** — tus reuniones del dia con contexto
2. **Tareas urgentes** — organizadas por responsable
3. **Borradores de correo** — listos para enviar
4. **Mensajes WA sugeridos** — con el texto segun contexto
5. **Cobranzas** — montos y contactos
6. **Seguimientos** — correos/mensajes enviados sin respuesta
7. **Estado por empresa** — resumen de cada cliente activo
8. **Tareas vencidas** — para decidir cerrar o reagendar
9. **Metricas** — leads, inversion, conversiones

## Como se genera?

El agente ejecuta el comando `/daily-brief` que:

1. Consulta la BD: tareas de hoy, vencidas, billing pendiente
2. Revisa Gmail: correos nuevos + enviados sin respuesta
3. Revisa WhatsApp: chats con mensajes nuevos
4. Revisa Calendar: eventos del dia
5. Genera el documento `REPORTE-YYYY-MM-DD.md`

## Donde se guarda?

- En el directorio del proyecto como `REPORTE-YYYY-MM-DD.md`
- En la tabla `daily_briefings` como registro historico

## Regla de seguimiento

Cada vez que se envia un correo o mensaje:
```
ENVIO → Se crea TAREA de seguimiento (due_date = +3 dias)
         ↓
    ¿Respondieron?
    ├── SI → Cerrar tarea + registrar respuesta
    └── NO → Aparece en "Seguimientos sin respuesta"
              ↓
         Agente propone borrador de reiteracion
```

## Template

Ver `templates/daily-report-template.md` para la plantilla completa.
