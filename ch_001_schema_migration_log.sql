/*
  ID:            CH-001
  Title:         Schema Migration Log
  Control Theme: Change Management
  TSC:           CC8.1
  Source:        APP
  Frequency:     Quarterly

  Description:
    Returns the full schema migration history with version, description,
    and application metadata. Evidence that database schema changes are
    tracked, versioned, and applied through a controlled process.

  Schema Assumptions:
    schema_migrations: version, description, applied_at, applied_by, duration_ms

  Parameters:
    \set review_start '2024-01-01'
    \set review_end   '2024-12-31'

  Expected Output:
    version          | description              | applied_at          | applied_by  | duration_ms
    -----------------+--------------------------+---------------------+-------------+------------
    20240501_001     | add_audit_events_indexes | 2024-04-11 00:00:00 | deploy_user | 8400

  Adaptation Notes:
    - For Flyway: use flyway_schema_history (version, description, installed_by, installed_on).
    - For Alembic: use alembic_version (version_num only — supplement with git log for description).
    - For Rails: use schema_migrations (version only — pair with git blame db/schema.rb).
*/

\set review_start '2024-01-01'
\set review_end   '2024-12-31'

SELECT
    version,
    description,
    applied_at,
    applied_by,
    duration_ms
FROM public.schema_migrations
WHERE applied_at >= :'review_start'::TIMESTAMPTZ
  AND applied_at <  :'review_end'::TIMESTAMPTZ + INTERVAL '1 day'
ORDER BY applied_at DESC;
