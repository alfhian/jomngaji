# JomNgaji Monorepo

This repository contains the mobile application, backend services, and AI tooling that power the JomNgaji platform.

## Structure

- `apps/mobile` – Flutter client application.
- `services/backend` – NestJS API with Prisma/PostgreSQL integration.
- `services/ai` – FastAPI service for speech scoring.
- `docker-compose.yml` – Local orchestration for all services and supporting infrastructure.

## Tooling

- Node.js workspaces are configured via the root `package.json` for the backend service.
- Python packaging uses a `pyproject.toml` inside each Python service.
- Flutter tooling remains encapsulated in the `apps/mobile` project directory.

Refer to each subdirectory for component-specific instructions.
