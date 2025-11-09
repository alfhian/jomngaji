# Backend Service

NestJS API for the JomNgaji platform, powering account onboarding, learning journeys, AI-linked assessments, and mentor scheduling.

## Commands

- `npm install` – install dependencies (run from repository root or this folder).
- `npm run start:dev` – start the development server.
- `npm run lint` – lint TypeScript sources with ESLint.
- `npm run test` – execute Jest unit tests.
- `npm run prisma:generate` – generate the Prisma client after editing the schema.

## Domain Overview

- **Programs** – catalog of curated learning tracks with modular breakdowns (`/programs`).
- **Journeys** – personalised learning journeys that orchestrate missions, assessments, and coach sessions (`/journeys`).
- **Assessments** – voice scoring snapshots produced by the AI microservice and persisted for longitudinal insight (`/assessments`).
- **Users** – authentication, role management (student / coach), and profile enrichment.

The Prisma schema lives in `prisma/schema.prisma` and targets PostgreSQL.
