/*
  ID:            AR-001
  Title:         All Active Application Users
  Control Theme: Access Review
  TSC:           CC6.1, CC6.2
  Source:        APP
  Frequency:     Quarterly

  Description:
    Returns the full list of active application users with their current
    role, MFA status, and last login date. Use as the primary evidence
    artefact for a quarterly access review.

  Schema Assumptions:
    users:      id, email, full_name, status, mfa_enabled, created_at, last_login_at
    user_roles: user_id, role_id, revoked_at
    roles:      id, name, is_admin

  Parameters:
    \set as_of_date '2024-04-18'   -- set to today's date when running live;
                                   -- use the reference date to reproduce sample CSV output

  Expected Output:
    user_id | email                  | full_name    | role   | is_admin | mfa_enabled | status | created_at          | last_login_at       | days_since_login
    --------+------------------------+--------------+--------+----------+-------------+--------+---------------------+---------------------+-----------------
    1       | alice@acmecorp.com     | Alice Admin  | admin  | t        | t           | active | 2023-10-20 08:00:00 | 2024-04-17 09:00:00 | 1
    2       | bob@acmecorp.com       | Bob Builder  | member | f        | t           | active | 2024-01-20 08:00:00 | 2024-04-15 14:00:00 | 3

  Adaptation Notes:
    - Replace 'active' with your active-status value if different.
    - If last_login_at lives in a sessions table, replace with a subquery:
        (SELECT MAX(created_at) FROM public.sessions WHERE user_id = u.id)
    - Add WHERE is_service_account = false to exclude service accounts.
    - Change :as_of_date to TODAY when running against your live database.

  Disclaimer: Reference only. Not legal or audit advice.
*/

\set as_of_date '2024-04-18'

-- SCHEMA ASSUMPTIONS
--   users:      id, email, full_name, status, mfa_enabled, is_service_account, created_at, last_login_at
--   user_roles: user_id, role_id, revoked_at
--   roles:      id, name, is_admin

SELECT
    u.id                                                        AS user_id,
    u.email,
    u.full_name,
    COALESCE(r.name, 'no_role')                                 AS role,
    COALESCE(r.is_admin, false)                                 AS is_admin,
    u.mfa_enabled,
    u.is_service_account,
    u.status,
    u.created_at,
    u.last_login_at,
    CASE
        WHEN u.last_login_at IS NULL THEN NULL
        ELSE (:'as_of_date'::DATE - u.last_login_at::DATE)
    END                                                         AS days_since_login
FROM public.users u
LEFT JOIN public.user_roles ur
    ON ur.user_id = u.id
    AND ur.revoked_at IS NULL
LEFT JOIN public.roles r
    ON r.id = ur.role_id
WHERE u.status = 'active'
ORDER BY r.is_admin DESC NULLS LAST, u.email;
