/*
  ID:            AR-006
  Title:         Active Users with No Login in 90+ Days
  Control Theme: Access Review — Stale Accounts
  TSC:           CC6.2, CC6.3
  Source:        APP
  Frequency:     Quarterly

  Description:
    Identifies active users who have not logged in within the threshold
    period. These accounts represent a standing access risk and should
    be reviewed, confirmed, or deactivated.

  Schema Assumptions:
    users:      id, email, full_name, status, last_login_at, created_at
    user_roles: user_id, role_id, revoked_at
    roles:      id, name, is_admin

  Parameters:
    \set stale_days  90
    \set as_of_date  '2024-04-18'  -- set to today's date when running live;
                                   -- use the reference date to reproduce sample CSV output

  Expected Output:
    user_id | email              | full_name  | role            | is_admin | last_login_at       | days_since_login | created_at
    --------+--------------------+------------+-----------------+----------+---------------------+------------------+-------------------
    5       | eve@acmecorp.com   | Eve Exec   | billing_manager | f        | 2024-01-08 09:00:00 | 100              | 2023-10-01 08:00:00

  Adaptation Notes:
    - Set \set stale_days to your policy threshold (30, 60, 90, or 180).
    - Change :as_of_date to TODAY when running against your live database.
    - Include AND u.is_service_account = false to skip service accounts.
    - Users created within the threshold window are excluded to avoid
      flagging new users who have not had a chance to log in.
*/

\set stale_days  90
\set as_of_date  '2024-04-18'

SELECT
    u.id                                                                    AS user_id,
    u.email,
    u.full_name,
    COALESCE(r.name, 'no_role')                                             AS role,
    COALESCE(r.is_admin, false)                                             AS is_admin,
    u.last_login_at,
    (:'as_of_date'::DATE - u.last_login_at::DATE)                          AS days_since_login,
    u.created_at
FROM public.users u
LEFT JOIN public.user_roles ur
    ON ur.user_id = u.id
    AND ur.revoked_at IS NULL
LEFT JOIN public.roles r
    ON r.id = ur.role_id
WHERE u.status = 'active'
  AND u.created_at < :'as_of_date'::DATE - (:stale_days || ' days')::INTERVAL
  AND (
      u.last_login_at IS NULL
      OR u.last_login_at < :'as_of_date'::DATE - (:stale_days || ' days')::INTERVAL
  )
ORDER BY days_since_login DESC NULLS FIRST, u.email;
