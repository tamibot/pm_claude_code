# Database Setup Guide

## Overview

The PM system uses 20 normalized PostgreSQL tables. The `companies` table is the central entity - almost everything links back to it via `company_id`.

## Quick Setup

```bash
# 1. Create a PostgreSQL database (Railway, Supabase, or local)
# 2. Set your connection string
export DATABASE_URL="postgresql://user:password@host:port/database"

# 3. Run the schema
python scripts/migrate.py
```

## Table Categories

### Core (7 tables)
These are the backbone of the system:

```sql
-- Companies: Your clients and internal entities
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Activo',
    sector_id INTEGER REFERENCES sectors(id),
    notes TEXT,
    last_contact_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Contacts: People linked to companies
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    role VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tasks: All pending work
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    project_id INTEGER REFERENCES projects(id),
    title TEXT NOT NULL,
    task_type VARCHAR(50) DEFAULT 'Operativo',
    status VARCHAR(50) DEFAULT 'Pendiente',
    priority VARCHAR(50) DEFAULT 'Media',
    due_date DATE,
    scheduled_date DATE,
    resolution_date DATE,
    comments TEXT,
    estimated_minutes INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
-- task_type: Operativo, Administrativo, Personal
-- status: Pendiente, En Progreso, Cerrado, Cancelado
-- priority: Urgente, Alta, Media, Baja

-- Projects: Deliverables and repos
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    name VARCHAR(255) NOT NULL,
    repo_url TEXT,
    tech_stack TEXT,
    status VARCHAR(50) DEFAULT 'Activo',
    last_activity DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Billing: Income and expenses
CREATE TABLE billing (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    concept TEXT,
    billing_type VARCHAR(50) DEFAULT 'Ingreso',
    payment_status VARCHAR(50) DEFAULT 'Pendiente',
    amount_usd DECIMAL(12,2),
    issue_date DATE,
    due_date DATE,
    payment_date DATE,
    payment_method VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Quotations: Sales pipeline
CREATE TABLE quotations (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    concept TEXT,
    status VARCHAR(50) DEFAULT 'Seguimiento',
    amount_usd DECIMAL(12,2),
    next_followup_date DATE,
    source_channel VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
-- status: Seguimiento, Cotizacion Enviada, A la espera de respuesta, Ganado, Perdido

-- Credentials: Encrypted service logins
CREATE TABLE credentials (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    service_name VARCHAR(255),
    username VARCHAR(255),
    password_encrypted BYTEA,
    url TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Communication Tracking (5 tables)

```sql
-- WhatsApp directory
CREATE TABLE whatsapp_contacts (
    id SERIAL PRIMARY KEY,
    chat_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    chat_type VARCHAR(50) DEFAULT 'individual',
    company_id INTEGER REFERENCES companies(id),
    should_review BOOLEAN DEFAULT true,
    review_notes TEXT,
    last_reviewed DATE
);

-- Chats to SKIP during review
CREATE TABLE whatsapp_exclusions (
    id SERIAL PRIMARY KEY,
    chat_name VARCHAR(255) NOT NULL UNIQUE,
    exclusion_type VARCHAR(50),
    added_date DATE DEFAULT CURRENT_DATE,
    notes TEXT
);
-- exclusion_type: personal, comunidad, social, spam, operadora

-- Key messages registered
CREATE TABLE whatsapp_messages (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER REFERENCES whatsapp_contacts(id),
    chat_name VARCHAR(255),
    sender VARCHAR(255),
    message_preview TEXT,
    message_date DATE,
    message_time TIME,
    has_audio BOOLEAN DEFAULT false,
    has_media BOOLEAN DEFAULT false,
    action_required BOOLEAN DEFAULT false,
    action_description TEXT,
    task_id INTEGER REFERENCES tasks(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Email tracking
CREATE TABLE email_tracking (
    id SERIAL PRIMARY KEY,
    email_account VARCHAR(255),
    from_address VARCHAR(255),
    from_name VARCHAR(255),
    subject TEXT,
    received_date DATE,
    email_type VARCHAR(50),
    company_id INTEGER REFERENCES companies(id),
    action_required BOOLEAN DEFAULT false,
    action_description TEXT,
    is_unsubscribed BOOLEAN DEFAULT false,
    task_id INTEGER REFERENCES tasks(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Review audit log
CREATE TABLE review_log (
    id SERIAL PRIMARY KEY,
    review_type VARCHAR(50),
    review_date DATE DEFAULT CURRENT_DATE,
    chats_reviewed INTEGER DEFAULT 0,
    tasks_created INTEGER DEFAULT 0,
    new_contacts INTEGER DEFAULT 0,
    summary TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Support (8 tables)

```sql
CREATE TABLE sectors (id SERIAL PRIMARY KEY, name VARCHAR(100) UNIQUE);
CREATE TABLE meetings (id SERIAL PRIMARY KEY, company_id INTEGER REFERENCES companies(id), title TEXT, scheduled_date TIMESTAMP, status VARCHAR(50), summary TEXT, action_items JSONB, duration_minutes INTEGER, meeting_link TEXT);
CREATE TABLE notes (id SERIAL PRIMARY KEY, company_id INTEGER REFERENCES companies(id), title TEXT, content TEXT, note_type VARCHAR(50), created_at TIMESTAMP DEFAULT NOW());
CREATE TABLE inbox (id SERIAL PRIMARY KEY, company_id INTEGER REFERENCES companies(id), content TEXT, source VARCHAR(100), status VARCHAR(50) DEFAULT 'Pendiente', tags TEXT[], created_at TIMESTAMP DEFAULT NOW());
CREATE TABLE daily_briefings (id SERIAL PRIMARY KEY, briefing_date DATE, content TEXT, tasks_summary JSONB, billing_summary JSONB, generated_at TIMESTAMP DEFAULT NOW());
CREATE TABLE tags (id SERIAL PRIMARY KEY, name VARCHAR(100), color VARCHAR(7));
CREATE TABLE entity_tags (id SERIAL PRIMARY KEY, tag_id INTEGER REFERENCES tags(id), entity_type VARCHAR(50), entity_id INTEGER);
CREATE TABLE activity_log (id SERIAL PRIMARY KEY, entity_type VARCHAR(50), entity_id INTEGER, action VARCHAR(50), details JSONB, created_at TIMESTAMP DEFAULT NOW());
```

## Recommended Indexes

```sql
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_company_id ON tasks(company_id);
CREATE INDEX idx_billing_status ON billing(payment_status);
CREATE INDEX idx_billing_company_id ON billing(company_id);
CREATE INDEX idx_contacts_company_id ON contacts(company_id);
CREATE INDEX idx_wa_exclusions_name ON whatsapp_exclusions(chat_name);
CREATE INDEX idx_email_tracking_date ON email_tracking(received_date);
```
