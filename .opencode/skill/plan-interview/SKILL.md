---
name: plan-interview
version: 1.0.0
type: planning
description: |
  ⚠️ AGENT: YOU MUST READ THIS FILE BEFORE RESPONDING TO THE USER.
  
  TRIGGER CONDITIONS - Load this skill when user says ANY of:
  
  1. EXPLICIT PLANNING KEYWORDS:
     "planning mode", "plan mode", "let's plan", "spec generation",
     "create a spec", "define requirements", "project goal"
  
  2. COMPLEX FEATURE REQUESTS:
     - "I want to build/create/make X"
     - "build me X" / "create X app/feature"  
     - "implement X" / "add X feature"
     - Requests needing database + backend + frontend together
     - Ambiguous scope or multiple interpretations
  
  3. NEW PROJECT/FEATURE FROM SCRATCH:
     - "using this repo, build X"
     - "transform this into X"
     - "exploit this as bootstrap for X"
     - Any greenfield feature development
  
  ⚠️ DO NOT explore codebase first. READ THIS FILE → follow interview protocol → THEN explore.
  OUTPUT: Formal spec document to docs/specs/
scope:
  - planning
  - plan mode
  - planning mode
  - spec generation
  - requirements
  - specification
  - project goal
  - build
  - create
  - implement
  - feature request
triggers:
  - user says "planning mode" or "plan mode"
  - user says "I want to build/create/implement X"
  - user says "build me X" or "create X app/feature"
  - user requests a complex multi-step feature
  - user requests spec generation or specification
  - user asks to plan a feature or project goal
  - user says "let's plan" or "define requirements"
  - user provides a plan file to review
  - ambiguous feature request needing clarification
  - user asks to create or write a spec
  - greenfield feature requiring DB + API + UI work
output: spec file written to docs/specs/ or user-specified location
---

## Intent

Replace shallow clarifying questions with a deep, structured interview process. When planning features, don't just ask "what do you want?" - conduct a thorough interview that uncovers hidden requirements, edge cases, and design decisions the user hasn't considered yet.

## When to Activate

This skill MUST be invoked when:

| Trigger | Example |
|---------|---------|
| User provides a plan file | "Review this plan: docs/feature-x.md" |
| User requests feature planning | "Let's plan the authentication system" |
| Ambiguous scope | "Add user management" (what does this mean?) |
| Complex feature request | Multiple systems, unclear boundaries |
| User explicitly asks | "Interview me about this feature" |

## Interview Protocol

### Phase 1: Context Gathering

Start by understanding the landscape:

```
Before diving into details, let me understand the context:

1. **Scope**: Is this a new feature, enhancement, or replacement?
2. **Users**: Who will use this? (end users, admins, other systems)
3. **Timeline**: Any deadlines or dependencies?
4. **Constraints**: Technical limitations, budget, team size?
```

### Phase 2: Deep Dive Questions

Ask NON-OBVIOUS questions. Never ask things that are:
- Already stated in the plan
- Trivially inferable
- Generic/boilerplate

**Good questions probe:**

| Category | Example Questions |
|----------|-------------------|
| **Edge Cases** | "What happens if a user tries to X while Y is in progress?" |
| **Failure Modes** | "If the payment fails mid-checkout, should we hold inventory?" |
| **Scale** | "At 10x current load, which part breaks first?" |
| **Security** | "Who should NOT be able to see this data?" |
| **UX Tradeoffs** | "Would you sacrifice feature X for faster load times?" |
| **Integration** | "How does this interact with [existing system]?" |
| **Migration** | "What happens to existing data/users?" |
| **Observability** | "How will you know if this is working correctly?" |

### Phase 3: Technical Deep Dive

After understanding requirements, probe implementation:

```
Now let's get technical:

1. **Data Model**: What entities? Relationships? 
2. **API Design**: REST/GraphQL? Sync/async?
3. **State Management**: Where does state live? How synced?
4. **Error Handling**: What errors are recoverable?
5. **Testing Strategy**: What's the riskiest part to test?
```

### Phase 4: UI/UX Deep Dive (if applicable)

```
For the user interface:

1. **User Journey**: Walk me through the happy path
2. **Error States**: What does the user see when X fails?
3. **Loading States**: Skeleton? Spinner? Optimistic update?
4. **Accessibility**: Keyboard nav? Screen readers?
5. **Responsive**: Mobile-first or desktop-first?
6. **Empty States**: What if there's no data yet?
```

### Phase 5: Tradeoffs & Priorities

```
Help me prioritize:

1. If you had to cut ONE feature, which goes first?
2. Performance vs. features - where's the line?
3. Build vs. buy for [component]?
4. Perfect now vs. good enough + iterate?
```

## Interview Rules

### DO:
- Ask ONE question at a time (don't overwhelm)
- Wait for response before next question
- Reference their previous answers ("You mentioned X, so...")
- Challenge assumptions ("Are you sure users want Y?")
- Suggest alternatives ("Have you considered Z instead?")
- Dig deeper on vague answers ("Can you give an example?")

### DON'T:
- Ask questions already answered in the plan
- Ask generic questions that apply to any project
- Skip to implementation before understanding requirements
- Accept "yes/no" answers without follow-up
- Move on if something seems unclear
- Stop interviewing prematurely

## Completion Criteria

The interview is complete when you have:

- [ ] Clear scope boundaries (what's in, what's out)
- [ ] All user types and their permissions defined
- [ ] Happy path fully described
- [ ] Major error scenarios covered
- [ ] Data model sketched
- [ ] API contracts outlined (if applicable)
- [ ] UI states enumerated (if applicable)
- [ ] Non-functional requirements stated (perf, security)
- [ ] Priority order for features
- [ ] Open questions documented

## Output: Spec Document

After interview completion, write a spec to the agreed location:

```markdown
# Feature: [Name]

## Overview
[2-3 sentence summary]

## Goals
- Primary: [main objective]
- Secondary: [nice-to-haves]

## Non-Goals
- [explicitly out of scope]

## User Stories
- As a [user], I want [action] so that [benefit]

## Technical Design

### Data Model
[entities, relationships]

### API Endpoints
[routes, methods, payloads]

### UI Components (if applicable)
[component tree, states]

## Edge Cases & Error Handling
| Scenario | Behavior |
|----------|----------|
| ... | ... |

## Security Considerations
[auth, authz, data protection]

## Testing Strategy
[what to test, how]

## Open Questions
[unresolved items for future]

## Appendix: Interview Notes
[key decisions and rationale]
```

## Example Interview Flow

```
User: "I want to add a notes feature to my app"

Agent: "Let's plan this properly. First question:

**Who creates notes?** 
- Only logged-in users?
- Can guests create temporary notes?
- Are there admin-created 'system notes'?"

User: "Only logged-in users for now"

Agent: "Got it. **Ownership & Sharing:**
- Are notes private by default?
- Can users share notes with specific people?
- Or is there a 'public' option?
- Can shared notes be edited by others or view-only?"

User: "Private only, no sharing for v1"

Agent: "Simple is good. **Organization:**
- Flat list or folders/categories?
- Tags? Search?
- How do users find old notes?"

[...continues until spec is complete...]
```

## Integration with Other Skills

After spec is complete, the agent should:
1. Create todo list from spec sections
2. Suggest implementation order
3. Identify which specialized agents to invoke (/backend, /frontend, etc.)
