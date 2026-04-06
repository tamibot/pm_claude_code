# Agent Commands Reference

## Slash Commands

These are configured in `.claude/commands/` and can be invoked by the user.

### /daily-brief

Generates a daily summary by querying the database:

1. Today's tasks (by priority)
2. Overdue tasks (count + list)
3. Pending billing/collections
4. Calendar events for today
5. WhatsApp/Gmail review results

**Output**: Short, actionable message organized by team member.

### /review-wa

Reviews unread WhatsApp Web chats:

1. Opens WhatsApp Web in browser
2. Filters using `whatsapp_exclusions` table
3. Enters each work chat
4. Records messages in `whatsapp_messages`
5. Updates `review_log`
6. Identifies chats requiring action

**Rules**:
- Never send messages without confirmation
- Always check exclusion list first
- Register new contacts found
- Create follow-up tasks for action items

### /review-gmail

Reviews unread emails (last 24h):

1. Searches for unread emails
2. Classifies: work, newsletter, spam, notification, report
3. Links to clients in database
4. Saves to `email_tracking`
5. Creates drafts for follow-ups

**Rules**:
- Never send emails directly - only create drafts
- Link emails to company_id when possible
- Register action-required emails

### /update-task

Updates task status in database:

- Valid states: Pendiente, En Progreso, Cerrado, Cancelado
- Valid priorities: Urgente, Alta, Media, Baja
- Can create follow-up tasks when requested
- Logs changes to activity_log

## Agent Configuration

### Task Manager Agent (`.claude/agents/task-manager.md`)

Specialized agent for:
- Creating, updating, closing tasks
- Assigning to projects/companies
- Managing priorities and dates
- Creating billing entries and follow-ups

**Available tools**:
- PostgreSQL (read/write)
- WhatsApp Web (read only)
- Gmail (read + draft creation)
- Google Calendar (create events)

**Rules**:
- NEVER send without user confirmation
- ALWAYS log database changes
- Prioritize urgent over follow-ups
- Use WA exclusion list before review
