/*
  ID:            DR-001
  Title:         Data Exports Past Retention Date
  Control Theme: Data Retention
  TSC:           C1.2, P4.3
  Source:        APP
  Frequency:     Monthly

  Description:
    Identifies data export records that have passed their configured
    retention expiry date. These should be verified as deleted per
    the data retention policy and documented as evidence.

  Schema Assumptions:
    data_exports: id, requested_by_user_id, data_type, status,
                  file_size_bytes, created_at, retention_expires_at
    users:        id, email, full_name

  Parameters:
    \set as_of_date '2024-04-18'   -- set to today's date for live use

  Expected Output:
    export_id | requester_email     | data_type | created_at          | retention_expires_at | days_overdue
    ----------+---------------------+-----------+---------------------+----------------------+-------------
    1         | alice@acmecorp.com  | audit_log | 2024-01-09 00:00:00 | 2024-04-08 00:00:00  | 10

  Adaptation Notes:
    - A non-empty result set indicates files may not have been purged
      per policy. Validate against your file storage system.
*/

\set as_of_date '2024-04-18'

SELECT
    de.id                                               AS export_id,
    u.email                                             AS requester_email,
    de.data_type,
    de.status,
    de.created_at,
    de.retention_expires_at,
    (:'as_of_date'::DATE - de.retention_expires_at::DATE)      AS days_overdue,
    de.download_count
FROM public.data_exports de
JOIN public.users u
    ON u.id = de.requested_by_user_id
WHERE de.retention_expires_at IS NOT NULL
  AND de.retention_expires_at < :'as_of_date'::TIMESTAMPTZ
ORDER BY days_overdue DESC;
