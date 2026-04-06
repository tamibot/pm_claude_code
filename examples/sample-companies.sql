-- Empresas de ejemplo
-- La estructura central: todo se vincula a companies via company_id

-- Sectores disponibles
INSERT INTO sectors (name) VALUES
('Inmobiliario'), ('Salud'), ('Educacion'), ('Servicios'),
('Retail'), ('Tecnologia'), ('Finanzas'), ('Marketing'), ('Otro');

-- Empresas internas (tu agencia/empresa)
INSERT INTO companies (name, status, notes) VALUES
('Mi Agencia', 'Activo', 'Empresa principal — CRM & AI Automation');

-- Clientes activos
INSERT INTO companies (name, status, sector_id, notes) VALUES
('Cliente Inmobiliaria', 'Activo', 1, 'Bot WA + CRM. Servicio mensual $250'),
('Cliente Salud', 'Activo', 2, 'Agente IA citas. Proyecto unico $500'),
('Cliente Educacion', 'En Negociacion', 3, 'Cotizacion enviada. Follow-up pendiente');

-- Contactos por empresa
INSERT INTO contacts (company_id, name, phone, email, role, is_primary) VALUES
(2, 'Jorge Director', '+51999111222', 'jorge@inmobiliaria.com', 'CEO', true),
(2, 'Valeria Marketing', '+51999333444', 'valeria@inmobiliaria.com', 'Marketing', false),
(3, 'Dr. Garcia', '+51999555666', 'garcia@clinica.com', 'Director', true);

-- Proyectos vinculados
INSERT INTO projects (company_id, name, repo_url, tech_stack, status) VALUES
(2, 'Bot WA Inmobiliaria', 'https://github.com/org/bot-inmob', 'n8n, KommoCRM, WA API', 'Activo'),
(3, 'Agente Citas Clinica', 'https://github.com/org/agente-citas', 'n8n, AgendaPro', 'En Desarrollo');
