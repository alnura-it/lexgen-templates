# PLAN.md

# Objective

Generate jinja2 templates from a Word or PDF document, transform them into RJSF artifacts, publish the generated files to the target location, and register them in the metadata database of the LexGen project..

---

# Variables

The implementation MUST use the following variables:

| Variable | Description |
|-----------|-------------|
| `{DOCUMENT}` | Name of the initial document. It must be located at the root folder of the lexGen-templates project. It can be Word or a PDF filename. This variable exclude the filename extension |



---

# Execution Flow

```text
┌──────────────────────────────────────────┐
│ templates-builder.agent.md               │
└──────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│ rjsf-builder.agent.md                    │
└──────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│ Publish generated files                  │
└──────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│ Update metadata database                 │
└──────────────────────────────────────────┘
```

---

# Phase 1 - Generate Templates

## Agent

`.github/agents/templates-builder.agent.md`

## Input

```text
{DOCUMENT}
```

## Responsibilities

- Read source document.
- Generate a jinja2 template.
- Validate generated templates.
- Produce a manifest describing generated artifacts.
- Report any generation or validation errors.

## Output

```text
termplates/{DOCUMENT}/
├── {DOCUMENT}-sample.json
├── {DOCUMENT}.jinja2
└── {DOCUMENT}.html
```

## Success Crit*ria

- Output directory exists.
- All generated templates are valid.
- No validation errors remain.

---

# Handoff*
The jinja2 template generated in Phase 1 become the mandatory input for Phase 2.

Input location:

```text
templates/{DOCUMENT}/{DOCUMENT}.jinja2
```

---

# Phase 2 - Generate RJSF Artifacts

## Agent

`.github/agents/rjsf-builder.agent.md`

## Input

```text
templates/{DOCUMENT}/{DOCUMENT}.jinja2
```

## Responsibilities

- Read the jinja2 template.
- Generate a RJSF file to fill the jinga2 placeholders form a web application.

## Output

```text
templates/{DOCUMENT}/{DOCUMENT}.jinja2  
```

## Success Criteria

- No schema validation errors.


---

# *hase 3 - Publish Artifacts

## Sou*ce

```text
{DOCUMENT}/{DOCUMENT}.jinja2
{DOCUMENT}/{DOCUMENT}.json
```*
## Destination

```text
../lexgen-backend/templates/
```

## Responsibilities

- Copy generated artifacts.
- Replace existing versions when necess*ry.
- Validate copied files.

## Validation

- File counts match.
- Required artifacts exist in destination.
- Copy operation completed sucessfully.

## Success Criteria

The {DOCUMENT}/{DOCUMENT}.jinja2 template and the {DOCUMENT}/{DOCUMENT}.json form were copied at ../lexgen-backend/templates/

---

#*Phase 4 - Update Database

## Data*ase

Database is running locally as a container (podman). The .env file contains the container id od the database, the database user, its password and the database name.

## Inputs

```text
{DOCUMENT}
{VERSION} - Get the version from the document name. If you cannot get any, then set version 1.

```

## Responsibilities

Connect to the database and create a new template (template) assigned to the acme oganization.
If the template already exist don't overwrite anything. This is not an error.

## Validation

- No failed inserts or updates.

---
*# Failure Handling

## Template Ge*eration Failure

- Stop execution.
- Do not execute subsequent phases.

## RJSF Generation Failure

- Stop execution.
- Do not publish artifacts.

## Publish Failure

- Stop execution.
- Do not update database.

## Database Failure

- Mark workflow as partially completed.
- Generate an error report.
- Preserve published files.

---

# Final Verification

Verify that:

- A jinga2 templates was generated.
- A RJSF artifact was generated.
- Files were published.
- Database records were updated.
---

# Deliverable

Produce a final execution summary containing:

``*text
Application:
Generated templates:
Generated RJSF artifacts:
HTML sample: 
Warnings:
Errors:
Final Status:*```

---

# Agent Constraints

- Phase 2 MUST NOT start until Phase 1 has completed successfully.
- RJSF generation MUST use the jinja2 template produced by the template generation phase.
- Any validation error MUST stop the workflow.
- The workflow MUST be repeatable and idempotent.