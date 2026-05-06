# Member 1 Deliverables: System Design + Database

Project context: Online Proctoring and Cheating Detection System.

Member 1 is responsible for the system architecture and all base database design files before other team members begin frontend/backend work.

## Deliverables in this starter kit

1. `architecture/architecture.png`
   - Ready-to-use system architecture diagram for README.

2. `architecture/architecture.drawio`
   - Editable diagram.net / draw.io file.

3. `architecture/architecture.mmd`
   - Mermaid version of the same architecture.

4. `postgres/01_schema.sql`
   - PostgreSQL schema for users, exams, questions, answers, scores, and disputes.
   - Also includes a helper table named `question_options` for normalized MCQ options.

5. `postgres/02_seed.sql`
   - Sample PostgreSQL data.

6. `mongo/VideoSession.js`
   - Mongoose model for video/proctoring sessions.

7. `mongo/FrameAnalysis.js`
   - Mongoose model for frame-level suspicious activity analysis.

8. `redis/redis-key-patterns.md`
   - Redis/Memurai key naming, value formats, TTLs, and purpose.

9. `scripts/seed-all.js`
   - Optional Node.js seed script to insert PostgreSQL, MongoDB, and Redis sample data.

10. `.env.example` and `package.json`
    - Configuration and dependencies for the optional seed script.

## Recommended working order

1. Open `architecture/architecture.drawio` in diagrams.net or draw.io.
2. Confirm the architecture with the team.
3. Run `postgres/01_schema.sql` in pgAdmin Query Tool or psql.
4. Run `postgres/02_seed.sql` in pgAdmin Query Tool or psql.
5. Add the two Mongoose model files to the backend project under `models/`.
6. Share `redis/redis-key-patterns.md` with the backend and WebSocket team.
7. Use `scripts/seed-all.js` only if the team wants one combined seeding script.

## pgAdmin execution order

Run this order:

```sql
-- 1. Schema
\i postgres/01_schema.sql

-- 2. Sample data
\i postgres/02_seed.sql
```

In pgAdmin, open Query Tool, paste the SQL file content, and click Execute.

## Why PostgreSQL, MongoDB, and Redis are all used

- PostgreSQL stores structured academic and exam data: users, exams, questions, answers, scores, and disputes.
- MongoDB stores flexible proctoring metadata: video sessions and frame analysis results.
- Redis or Memurai stores temporary real-time data: login sessions, live exam state, WebSocket presence, latest suspicious flags, and locks.

## Important note

The project should not store real student video or sensitive personal data during development. Use dummy data only.
