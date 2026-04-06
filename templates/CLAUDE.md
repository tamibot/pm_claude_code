# PM Claude Code - Project Instructions

## Project
Centralized dashboard and personal AI assistant for managing clients, projects, tasks, billing, and commercial pipeline. Integrates WhatsApp, Gmail, Google Calendar, and PostgreSQL.

## Stack
- Python 3.12 + FastAPI + Jinja2 + Tailwind CSS + Alpine.js
- PostgreSQL (Railway/Supabase/Local)
- Encrypted credentials with Fernet (cryptography)
- Integrations: Gmail API, Google Calendar API, WhatsApp Web (Browser)

## Database
Connection: `DATABASE_URL` variable in `.env`
20 normalized tables centered on `companies` as the main entity.

### Main Tables
- `companies` - Clients and internal entities
- `contacts` - People per company
- `credentials` - Encrypted service credentials
- `projects` - One repo = one project
- `tasks` - Tasks with priority, date, and type
- `billing` - Invoicing and collections
- `quotations` - Commercial pipeline

### Tracking Tables
- `whatsapp_contacts` - WhatsApp directory
- `whatsapp_exclusions` - Chats to NOT review
- `whatsapp_messages` - Key messages
- `email_tracking` - Actionable emails
- `review_log` - Review audit log

### Common Queries
```sql
-- Today's pending tasks
SELECT t.title, c.name, t.priority FROM tasks t
JOIN companies c ON t.company_id = c.id
WHERE t.status = 'Pendiente' AND t.due_date <= CURRENT_DATE
ORDER BY CASE t.priority WHEN 'Urgente' THEN 1 WHEN 'Alta' THEN 2 WHEN 'Media' THEN 3 ELSE 4 END;

-- Pending billing
SELECT b.concept, b.amount_usd, c.name FROM billing b
JOIN companies c ON b.company_id = c.id
WHERE b.payment_status IN ('Pendiente', 'Vencido') AND b.amount_usd > 0;

-- WhatsApp exclusion list
SELECT chat_name, exclusion_type FROM whatsapp_exclusions ORDER BY exclusion_type;
```

## Conventions
- Code and comments in your preferred language
- Dates in ISO format (YYYY-MM-DD) in the database
- Amounts always in USD (DECIMAL 12,2)
- Status without emojis in the database (clean text only)
- Credentials always encrypted with Fernet before storing
- Each GitHub repo = 1 project in the database
- ALWAYS create a follow-up task when something is sent (email, message, quotation)
- NEVER send emails directly - only create drafts
- NEVER send WhatsApp messages without confirmation
- Use native integrations (Gmail, Calendar) instead of browser when possible

## How to Register Data
- New tasks: `POST /api/tasks` with company_id, title, task_type, priority, due_date
- New notes: `POST /api/notes` with company_id, title, content
- Inbox: `POST /api/inbox` with content and optionally company_id
- Meetings: `POST /api/meetings` with company_id, title, scheduled_date
- Credentials: `POST /api/companies/{id}/credentials` (auto-encrypted)
