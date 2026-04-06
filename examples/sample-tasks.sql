-- Tareas de ejemplo con diferentes prioridades y tipos

-- Tareas operativas (trabajo tecnico)
INSERT INTO tasks (company_id, title, task_type, status, priority, due_date, comments) VALUES
(2, 'Inmobiliaria | Configurar bot WA con plantillas aprobadas', 'Operativo', 'Pendiente', 'Urgente', CURRENT_DATE,
 'Bot debe estar listo para el lunes. Plantillas ya aprobadas por Meta.'),
(2, 'Inmobiliaria | Revisar reporte diario — da error en datos', 'Operativo', 'Pendiente', 'Alta', CURRENT_DATE + 1,
 'Jorge reporto que el reporte sale con datos incorrectos.'),
(3, 'Clinica | Crear agente IA para agendar citas', 'Operativo', 'En Progreso', 'Alta', CURRENT_DATE + 3,
 'Carlos esta desarrollando. Necesita acceso a AgendaPro.');

-- Tareas administrativas
INSERT INTO tasks (company_id, title, task_type, status, priority, due_date, comments) VALUES
(2, 'Inmobiliaria | Emitir factura marzo $250', 'Admin', 'Pendiente', 'Alta', CURRENT_DATE,
 'Enviar factura a jorge@inmobiliaria.com. PayPal o transferencia.'),
(1, 'Agencia | Firmar adenda contrato trabajo', 'Admin', 'Pendiente', 'Media', CURRENT_DATE + 15,
 'Digital Signatures. Expira en 30 dias.');

-- Tareas de seguimiento (generadas automaticamente)
INSERT INTO tasks (company_id, title, task_type, status, priority, due_date, comments) VALUES
(4, 'Educacion | Seguimiento cotizacion enviada 01/04', 'Operativo', 'Pendiente', 'Media', CURRENT_DATE + 2,
 'Se envio cotizacion por correo. Si no responde, reenviar borrador.');

-- Tareas personales
INSERT INTO tasks (company_id, title, task_type, status, priority, due_date, comments) VALUES
(NULL, 'Preparar charla AI First Founders martes 7pm', 'Personal', 'Pendiente', 'Alta', CURRENT_DATE + 1,
 'Tema: Automatiza n8n con Claude Code. Preparar demo y slides.');
