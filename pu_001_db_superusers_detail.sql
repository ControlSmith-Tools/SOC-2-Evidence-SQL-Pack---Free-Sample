/*
  ID:            PU-001
  Title:         Database Superuser Detail Report
  Control Theme: Privileged Access
  TSC:           CC6.1
  Source:        CATALOG
  Frequency:     Quarterly

  Description:
    Detailed view of all Postgres superuser roles including connection
    limits, password expiry, and current active connections.
    Pairs with AR-008 for the access review; this version adds
    live session count from pg_stat_activity.

  Schema Assumptions:
    None (system catalog)

  Parameters:
    None

  Expected Output:
    role_name | is_superuser | active_connections | password_expires_at | conn_limit
    ----------+--------------+--------------------+---------------------+-----------
    postgres  | t            | 2                  | (none)              | -1

  Adaptation Notes:
    - active_connections counts only connections in pg_stat_activity
      at the moment the query runs.
*/

SELECT
    r.rolname                   AS role_name,
    r.rolsuper                  AS is_superuser,
    r.rolcreatedb               AS can_create_db,
    r.rolcreaterole             AS can_create_role,
    r.rolbypassrls              AS bypasses_rls,
    r.rolcanlogin               AS can_login,
    r.rolconnlimit              AS conn_limit,
    r.rolvaliduntil             AS password_expires_at,
    COUNT(sa.pid)               AS active_connections
FROM pg_roles r
LEFT JOIN pg_stat_activity sa
    ON sa.usename = r.rolname
WHERE r.rolsuper = true
GROUP BY r.rolname, r.rolsuper, r.rolcreatedb, r.rolcreaterole,
         r.rolbypassrls, r.rolcanlogin, r.rolconnlimit, r.rolvaliduntil
ORDER BY r.rolname;
