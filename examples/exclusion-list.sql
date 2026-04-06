-- Lista de exclusiones WhatsApp — Ejemplo
-- Estos chats seran saltados durante la revision automatica

-- Grupos de comunidad (alto volumen, no accionables)
INSERT INTO whatsapp_exclusions (chat_name, exclusion_type, notes) VALUES
('n8n en espanol', 'comunidad', 'Comunidad de automatizacion'),
('n8n Latam', 'comunidad', 'Comunidad regional'),
('Kommo Socios', 'comunidad', 'Partners de Kommo CRM'),
('Kommo Desarrolladores', 'comunidad', 'Devs de Kommo'),
('Make en espanol', 'comunidad', 'Comunidad Make/Integromat'),
('GHL En espanol', 'comunidad', 'Comunidad GoHighLevel'),
('Notion en Espanol', 'comunidad', 'Comunidad Notion'),
('AI First', 'comunidad', 'Comunidad IA');

-- Chats personales (familia, amigos)
INSERT INTO whatsapp_exclusions (chat_name, exclusion_type, notes) VALUES
('Familia', 'personal', 'Grupo familiar principal'),
('Mama', 'personal', 'Chat con mama'),
('Primos', 'personal', 'Grupo de primos');

-- Social (deportes, eventos, ocio)
INSERT INTO whatsapp_exclusions (chat_name, exclusion_type, notes) VALUES
('Padel Team', 'social', 'Grupo de padel'),
('Cumple Juan', 'social', 'Evento social'),
('Gimnasio', 'social', 'Grupo del gym');

-- Spam y operadoras
INSERT INTO whatsapp_exclusions (chat_name, exclusion_type, notes) VALUES
('Banco X', 'spam', 'Notificaciones bancarias'),
('Instagram', 'spam', 'Bot de Instagram'),
('Movistar', 'operadora', 'Operador telefonico'),
('Claro', 'operadora', 'Operador telefonico');
