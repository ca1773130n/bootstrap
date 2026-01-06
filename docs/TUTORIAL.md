# Building a Notes App with AI Agents

This tutorial demonstrates how to transform the bootstrap repo into a fully functional Notes app using AI-assisted development with **OpenCode** or **Claude Code**.

You'll learn:
- How to prompt AI agents effectively
- What clarifying questions to expect (and how to answer them)
- How to verify each step works correctly
- How to recover when something goes wrong

## Prerequisites

Before starting, ensure you have:

1. **This repo cloned and initialized**
   ```bash
   git clone https://github.com/YOUR_USER/bootstrap.git my-notes-app
   cd my-notes-app
   ./scripts/init.sh my-notes-app
   make install
   ```

2. **OpenCode or Claude Code installed**
   - [OpenCode](https://github.com/opencode-ai/opencode): `go install github.com/opencode-ai/opencode@latest`
   - [Claude Code](https://claude.ai/code): Follow official installation

3. **Docker running** (for the database)
   ```bash
   make up
   ```

4. **Verify everything works**
   ```bash
   make test  # Should pass with 100% coverage
   ```

## How This Tutorial Works

Each step follows this pattern:

```
┌─────────────────────────────────────────────────────────────┐
│  1. YOUR PROMPT      → What you type to the AI             │
│  2. AI QUESTIONS     → Clarifying questions the AI asks    │
│  3. YOUR ANSWERS     → How you should respond              │
│  4. VERIFICATION     → Commands to check it worked         │
│  5. IF SOMETHING'S WRONG → Follow-up prompts to fix        │
└─────────────────────────────────────────────────────────────┘
```

### Interactive Mode (Optional)

Run the companion script for guided, step-by-step verification:

```bash
./scripts/tutorial.sh
```

The script will show you each prompt and automatically verify your implementation.

---

## Step 1: Planning the App

Start your AI coding session and describe what you want to build.

### Your Prompt

```
I want to build a notes app using this bootstrap repo.
```

### Expected AI Questions

The AI should ask clarifying questions like:

> **AI**: I'd be happy to help you build a notes app! Let me understand the requirements better:
>
> 1. **Note structure**: What fields should a note have? (title, content, timestamps?)
> 2. **Tags/Categories**: Should notes support tags or categories for organization?
> 3. **Features**: Which of these do you need?
>    - Create/Edit/Delete notes
>    - Search notes
>    - Filter by tags
> 4. **Authentication**: Should this be multi-user with login, or single-user?

### Your Answers

```
1. Notes should have a title, content, and timestamps (created/updated)
2. Yes, notes should support tags. A note can have multiple tags.
3. I need: Create, Edit, Delete, List all notes, and Filter by tags. No search for now.
4. No authentication - single user, keep it simple.
```

### What Happens Next

The AI should acknowledge and summarize:

> **AI**: Got it! Here's the plan:
>
> **Notes App Scope:**
> - Notes with title, content, created_at, updated_at
> - Many-to-many relationship with tags
> - CRUD operations (Create, Read, Update, Delete)
> - Filter notes by tag
> - No authentication
>
> I'll implement this in stages:
> 1. Database schema
> 2. Backend API endpoints
> 3. Frontend UI components
>
> Should I start with the database schema?

### Your Response

```
Yes, start with the database schema.
```

### Verification

At this point, no code changes yet - this was just planning. Verify you're still at baseline:

```bash
make test  # Should still pass
```

---

## Step 2: Database Schema

The AI will now design and implement the database schema.

### What the AI Does

The AI should:
1. Update `infra/init.sql` with new tables
2. Explain the schema design

### Expected AI Questions

> **AI**: For the tags implementation, I have a question:
>
> Should tags be **predefined** (user picks from existing tags) or **free-form** (user can type any tag)?
>
> This affects the schema:
> - Predefined: Separate `tags` table, prevents duplicates
> - Free-form: Could store as JSON array, simpler but less queryable

### Your Answer

```
Use predefined tags with a separate table. I want to be able to list all tags and see how many notes use each tag.
```

### AI Implements

The AI will update `infra/init.sql`. The schema should look something like:

```sql
-- Notes table
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Many-to-many join table
CREATE TABLE IF NOT EXISTS note_tags (
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (note_id, tag_id)
);
```

### Verification

```bash
# Check the schema file was updated
cat infra/init.sql

# Recreate the database with new schema
make down && make up

# Tests should still pass (schema change doesn't break existing tests)
make test
```

### If Something's Wrong

If `make up` fails with database errors:

```
The database failed to start. Check the init.sql syntax and fix any errors.
```

If tests fail:

```
The tests are failing after schema change. Please check what broke and fix it.
```

---

## Step 3: Backend API - Models

Now we'll create the Pydantic models for request/response validation.

### Your Prompt

```
Create the Pydantic models for notes and tags.
```

### Expected AI Questions

> **AI**: A few questions about the models:
>
> 1. **Note creation**: When creating a note, should tags be specified by ID or by name?
>    - By ID: Client must know tag IDs beforehand
>    - By name: API creates tags if they don't exist (more convenient)
>
> 2. **Tag response**: When returning a note, should I include full tag objects or just tag names?

### Your Answers

```
1. By name - the API should create tags automatically if they don't exist. Much better UX.
2. Include full tag objects (id and name) so the frontend can link to tag filtering.
```

### AI Implements

The AI should create model files. Expected structure:

```python
# backend/app/models.py (new file)
from pydantic import BaseModel
from datetime import datetime

class TagBase(BaseModel):
    name: str

class Tag(TagBase):
    id: str
    
class NoteCreate(BaseModel):
    title: str
    content: str = ""
    tags: list[str] = []  # Tag names

class NoteUpdate(BaseModel):
    title: str | None = None
    content: str | None = None
    tags: list[str] | None = None

class Note(BaseModel):
    id: str
    title: str
    content: str
    tags: list[Tag]
    created_at: datetime
    updated_at: datetime
```

### Verification

```bash
make test  # Should pass - models alone don't need tests yet
```

---

## Step 4: Backend API - Endpoints

Now we create the actual API endpoints.

### Your Prompt

```
Create the CRUD API endpoints for notes and tags. Remember this repo requires 100% test coverage.
```

### Expected AI Behavior

The AI should:
1. Create endpoints in `backend/app/api.py` (or a new `notes.py` router)
2. Create comprehensive tests
3. Handle database operations

### Expected AI Questions

> **AI**: For the database operations, I see this repo has a minimal setup. Should I:
>
> 1. **Use raw SQL** with `asyncpg` - lightweight, explicit
> 2. **Add SQLAlchemy** - ORM, more abstraction, more dependencies
>
> Given the simple schema, I'd recommend raw SQL with `asyncpg` to keep it minimal. Thoughts?

### Your Answer

```
Yes, use raw SQL with asyncpg. Keep dependencies minimal.
```

### AI Implements

The AI will:
1. Add `asyncpg` to dependencies
2. Create database connection utilities
3. Implement CRUD endpoints
4. Write tests for all endpoints

Expected endpoints:

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/notes | List all notes |
| POST | /api/notes | Create a note |
| GET | /api/notes/{id} | Get single note |
| PUT | /api/notes/{id} | Update a note |
| DELETE | /api/notes/{id} | Delete a note |
| GET | /api/tags | List all tags |
| GET | /api/notes?tag={name} | Filter notes by tag |

### Verification

```bash
# Run tests - must pass with 100% coverage
make test

# Try the API manually (optional)
curl http://localhost:8000/api/notes
curl -X POST http://localhost:8000/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title": "My First Note", "content": "Hello!", "tags": ["test"]}'
```

### If Something's Wrong

If tests fail coverage:

```
Tests pass but coverage is below 100%. Add tests for the uncovered lines.
```

If tests fail:

```
Tests are failing. Here's the error output: [paste error]
Fix the failing tests.
```

---

## Step 5: Frontend - Note List Component

Now we build the Vue.js frontend.

### Your Prompt

```
Create the frontend components to display a list of notes. Start with just viewing notes, we'll add create/edit later.
```

### Expected AI Questions

> **AI**: For the UI, I have some questions:
>
> 1. **Layout**: Should notes display as:
>    - Cards in a grid
>    - Simple list (rows)
>
> 2. **Note preview**: In the list, should I show:
>    - Title only
>    - Title + first few lines of content
>    - Title + tags

### Your Answers

```
1. Simple list - one note per row
2. Show title + tags. Content can be shown when clicking on a note.
```

### AI Implements

The AI should:
1. Update API client with new endpoints
2. Create Vue components for note list
3. Add tests for components

### Verification

```bash
make test  # Frontend tests should pass

# View in browser
# Open http://localhost:5173
```

### If Something's Wrong

If the page shows errors:

```
The frontend shows an error. Here's what I see in the browser console: [paste error]
```

---

## Step 6: Frontend - Create/Edit/Delete

### Your Prompt

```
Add the ability to create, edit, and delete notes in the frontend.
```

### Expected AI Questions

> **AI**: For the editing experience:
>
> 1. **Create/Edit UI**: Should this be:
>    - Inline editing (edit in place in the list)
>    - Modal dialog
>    - Separate page/view
>
> 2. **Delete confirmation**: Require confirmation before delete?

### Your Answers

```
1. Modal dialog for both create and edit
2. Yes, show a confirmation dialog before deleting
```

### AI Implements

Creates:
- NoteForm component (used in modal)
- Create/Edit modal
- Delete confirmation
- Connects all actions to API

### Verification

```bash
make test

# Manual test in browser:
# 1. Click "New Note" - form should appear
# 2. Fill in title, content, tags - click Save
# 3. Note should appear in list
# 4. Click note to edit
# 5. Click delete - confirmation should appear
```

---

## Step 7: Tag Filtering

### Your Prompt

```
Add tag filtering - clicking a tag should filter the notes list to show only notes with that tag.
```

### Expected AI Behavior

This is simpler - the AI shouldn't need to ask questions since the requirements are clear.

### AI Implements

- Adds tag filter state to the UI
- Calls API with `?tag=` parameter when filter active
- Shows active filter indicator
- "Clear filter" option

### Verification

```bash
make test

# Manual test:
# 1. Create notes with different tags
# 2. Click a tag - list should filter
# 3. Click "clear" or the tag again - full list returns
```

---

## Step 8: Final Polish

### Your Prompt

```
Review the app and fix any issues. Make sure all tests pass and the app is ready for deployment.
```

### AI Does

- Runs full test suite
- Fixes any lint errors
- Ensures 100% coverage
- May suggest improvements

### Verification

```bash
# Full validation
make lint
make test
make build

# All should pass with no errors
```

---

## Deployment

Once everything works locally:

### Your Prompt

```
Help me deploy this to Fly.io
```

The AI will guide you through:
1. Setting up Fly.io CLI
2. Configuring environment variables
3. Setting up the production database
4. Deploying backend and frontend

See `infra/postgres-vps.md` and `infra/fly-setup.sh` for detailed deployment instructions.

---

## Troubleshooting

### Common Issues

| Problem | Solution Prompt |
|---------|-----------------|
| Tests fail | "Tests are failing with this error: [error]. Fix it." |
| Coverage < 100% | "Coverage is at X%. Add tests for uncovered code." |
| Type errors | "There are TypeScript/mypy errors. Fix them." |
| API returns 500 | "The API returns 500 error. Here's the log: [log]" |
| Frontend won't build | "Frontend build fails with: [error]" |

### Recovery Prompts

If you get stuck, these prompts help:

```
# See current state
What's the current state of the implementation? What works and what's missing?

# Fix everything
Run make test and fix all failures.

# Start over on a step
Let's redo the [component]. Remove what's there and start fresh.
```

---

## Reference Implementation

A complete implementation is available on the `tutorial-complete` branch:

```bash
# Compare your code with reference
git diff tutorial-complete -- backend/
git diff tutorial-complete -- frontend/

# Or check out the complete version
git checkout tutorial-complete
```

---

## Next Steps

Ideas to extend your notes app:

1. **Search**: Add full-text search with PostgreSQL
2. **Markdown**: Support markdown in note content
3. **Authentication**: Add user accounts with sessions
4. **Rich Editor**: Replace textarea with a rich text editor
5. **Export**: Export notes as JSON or Markdown files
6. **Mobile**: Make the UI responsive for mobile

---

## Summary

You've learned how to:

1. **Plan with AI** - Describe goals, answer clarifying questions
2. **Implement incrementally** - Database → Backend → Frontend
3. **Verify each step** - `make test` after every change
4. **Recover from errors** - Describe the problem, let AI fix it
5. **Deploy** - Use the included Fly.io setup

The key to effective AI-assisted development:
- **Be specific** about what you want
- **Answer questions** thoughtfully - they help AI make better decisions
- **Verify early and often** - catch issues before they compound
- **Describe errors clearly** - include actual error messages

Happy building!
