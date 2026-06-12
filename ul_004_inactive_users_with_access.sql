/*
  ID:            UL-004
  Title:         Deactivated Users with Live Access Grants
  Control Theme: Deprovisioning Gap
  TSC:           CC6.2, CC6.3
  Source:        APP
  Frequency:     Quarterly

  Description:
    Identifies deactivated or inactive users who still have non-revoked
    resource-level access grants. This is a direct gap in the offboarding
    process and a high-priority finding in any SOC 2 access review.

  Schema Assumptions:
    users:         id, email, full_name, status, deactivated_at
    access_grants: id, user_id, resource_type, resource_id, permission_level, revoked_at

  Parameters:
    None

  Expected Output:
    user_id | email              | status   | deactivated_at      | grant_id | resource_type | permission
    --------+--------------------+----------+---------------------+----------+---------------+-----------
    6       | frank@acmecorp.com | inactive | 2023-12-21 00:00:00 | 4        | project       | read

  Adaptation Notes:
    - A non-empty result set is a control exception — document each row
      with remediation owner and expected resolution date.
*/

SELECT
    u.id                        AS user_id,
    u.email,
    u.full_name,
    u.status,
    u.deactivated_at,
    ag.id                       AS grant_id,
    ag.resource_type,
    ag.resource_id,
    ag.permission_level         AS permission,
    ag.granted_at,
    ag.expires_at
FROM public.users u
JOIN public.access_grants ag
    ON ag.user_id    = u.id
    AND ag.revoked_at IS NULL
WHERE u.status IN ('inactive', 'suspended')
ORDER BY u.email, ag.resource_type;
