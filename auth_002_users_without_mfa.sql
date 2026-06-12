/*
  ID:            AUTH-002
  Title:         Active Users Without MFA Enabled
  Control Theme: MFA / Authentication — Gap Report
  TSC:           CC6.1, CC6.7
  Source:        APP
  Frequency:     Quarterly

  Description:
    Returns all active non-service-account users who do not have MFA
    enabled. This is the exception report for the MFA policy — each
    row should either have a documented exception or trigger remediation.

  Schema Assumptions:
    users:      id, email, full_name, status, mfa_enabled, is_service_account, last_login_at
    user_roles: user_id, role_id, revoked_at
    roles:      id, name, is_admin

  Parameters:
    \set as_of_date '2024-04-18'   -- set to today's date when running live;
                                   -- use the reference date to reproduce sample CSV output

  Expected Output:
    user_id | email              | full_name        | role            | is_admin | last_login_at       | days_since_login
    --------+--------------------+------------------+-----------------+----------+---------------------+-----------------
    5       | eve@acmecorp.com   | Eve Exec         | billing_manager | f        | 2024-01-08 09:00:00 | 100
    3       | carol@acmecorp.com | Carol Compliance | member          | f        | 2024-04-04 11:00:00 | 14

  Adaptation Notes:
    - Remove AND u.is_service_account = false if you also want to include
      service accounts in the gap report.
    - Change :as_of_date to TODAY when running against your live database.
*/

\set as_of_date '2024-04-18'

SELECT
    u.id                                                            AS user_id,
    u.email,
    u.full_name,
    COALESCE(r.name, 'no_role')                                     AS role,
    COALESCE(r.is_admin, false)                                     AS is_admin,
    u.last_login_at,
    CASE
        WHEN u.last_login_at IS NULL THEN NULL
        ELSE (:'as_of_date'::DATE - u.last_login_at::DATE)
    END                                                             AS days_since_login
FROM public.users u
LEFT JOIN public.user_roles ur
    ON ur.user_id = u.id
    AND ur.revoked_at IS NULL
LEFT JOIN public.roles r
    ON r.id = ur.role_id
WHERE u.status = 'active'
  AND u.mfa_enabled = false
  AND u.is_service_account = false
ORDER BY r.is_admin DESC NULLS LAST, days_since_login DESC NULLS LAST;
