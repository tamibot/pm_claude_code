# Integrations Setup Guide

## Overview

The PM agent needs 4 integrations to work effectively. Two require browser access and two use native API connections.

```
+-------------------+     +-------------------+
| Browser-Based     |     | Native API (MCP)  |
|                   |     |                   |
| - WhatsApp Web    |     | - Gmail API       |
| - LinkedIn        |     | - Google Calendar |
+-------------------+     +-------------------+
         |                          |
         v                          v
+-------------------------------------------+
|          AI Agent (Claude Code)            |
|  - Reads/writes to PostgreSQL             |
|  - Generates tasks, drafts, briefings     |
+-------------------------------------------+
```

## 1. WhatsApp Web (Browser)

### How it works
The AI agent opens WhatsApp Web in a browser tab and navigates through chats using automation (clicks, scrolls, screenshots).

### Setup Steps
1. Open your browser (Chrome recommended)
2. Navigate to `https://web.whatsapp.com/`
3. Scan the QR code with your phone
4. Keep the session active

### Agent Behavior
- Uses the `whatsapp_exclusions` table to skip personal/community chats
- Reads messages from the most recent first
- Identifies action items by context (questions, requests, mentions)
- Registers new contacts in `whatsapp_contacts`
- Saves key messages in `whatsapp_messages`

### Exclusion Types
| Type | Example | Description |
|------|---------|-------------|
| `personal` | Family groups, friends | Skip completely |
| `comunidad` | n8n, Kommo, GHL groups | Community chats, skip |
| `social` | Padel, parties, events | Social groups, skip |
| `spam` | Promotions, banks, bots | Promotional messages |
| `operadora` | Movistar, Entel | Carrier messages |

### Important Rules
- **NEVER send messages** without explicit user confirmation
- **Always check exclusion list** before reviewing a chat
- **Register action items** as tasks when they require follow-up
- **Record unknown numbers** with suggested names

## 2. Gmail (Native MCP)

### How it works
Claude Code connects directly to Gmail via OAuth MCP. This provides full API access without needing the browser.

### Setup
In Claude Code, enable the Gmail MCP integration:
1. Open Claude Code settings
2. Go to MCP Servers
3. Enable Gmail integration
4. Authorize with your Google account

### Agent Capabilities
- `gmail_search_messages` - Search with Gmail query syntax
- `gmail_read_message` - Read full email content
- `gmail_create_draft` - Create email drafts (never send directly)
- `gmail_list_labels` - List available labels
- `gmail_get_profile` - Get account info

### Email Classification
| Type | Action | Example |
|------|--------|---------|
| `work` | Register + create task | Client requests, follow-ups |
| `report` | Register | Automated reports, analytics |
| `notification` | Register if relevant | Payment receipts, alerts |
| `newsletter` | Skip | Marketing emails |
| `spam` | Skip | Promotions |

## 3. Google Calendar (Native MCP)

### Setup
Same as Gmail - enable Google Calendar MCP in Claude Code settings.

### Agent Capabilities
- `gcal_list_events` - List events in a time range
- `gcal_create_event` - Create new events
- `gcal_find_meeting_times` - Find available slots
- `gcal_find_my_free_time` - Check your availability

### Daily Usage
The agent checks the calendar every morning to:
1. List today's meetings with context
2. Identify conflicts
3. Prepare talking points for each meeting
4. Cross-reference with pending tasks per client

## 4. PostgreSQL (Direct Connection)

### Setup
```bash
# .env file
DATABASE_URL=postgresql://user:password@host:port/database
ENCRYPTION_KEY=your-fernet-key-here
```

### Connection Pattern
```python
import psycopg2
from contextlib import contextmanager

@contextmanager
def get_db():
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
```

## Alternative: Browser-Only Mode

If your AI tool doesn't support native MCP integrations, you can use browser automation for everything:

| Integration | Native MCP | Browser Alternative |
|-------------|-----------|-------------------|
| WhatsApp | N/A (browser only) | Open web.whatsapp.com |
| Gmail | Gmail MCP | Open mail.google.com |
| Calendar | Calendar MCP | Open calendar.google.com |
| Database | psycopg2 | Use a DB admin UI like pgAdmin |

The agent will use screenshots, clicks, and keyboard input to interact with each service through the browser.
