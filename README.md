# JomNgaji Monorepo

This repository contains the mobile application, backend services, and AI tooling that power the JomNgaji platform.

## Structure

- `apps/mobile` – Flutter client application.
- `services/backend` – NestJS API with Prisma/PostgreSQL integration.
- `services/ai` – FastAPI service for speech scoring.
- `docker-compose.yml` – Local orchestration for all services and supporting infrastructure.

## Learning Flow at a Glance

1. **Onboarding & Assessment** – Students register, complete an AI-powered voice assessment, and receive their personalised learning journey.
2. **Adaptive Practice** – Daily missions blend AI drills, live coach sessions, and guided reflection.
3. **Coach Collaboration** – Scheduled sessions and progress dashboards keep mentors aligned with each student’s goals.
4. **Progress Intelligence** – Assessments are stored historically so improvements across tajwid, makhraj, fluency, and pacing are trackable.

## Tooling

- Node.js workspaces are configured via the root `package.json` for the backend service.
- Python packaging uses a `pyproject.toml` inside each Python service.
- Flutter tooling remains encapsulated in the `apps/mobile` project directory.

Refer to each subdirectory for component-specific instructions.
