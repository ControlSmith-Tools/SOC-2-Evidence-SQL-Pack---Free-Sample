/*
  ID:            ENC-001
  Title:         PostgreSQL SSL/TLS Configuration Settings
  Control Theme: Encryption in Transit
  TSC:           CC6.1, CC6.7
  Source:        CATALOG
  Frequency:     Quarterly

  Description:
    Returns all Postgres settings related to SSL/TLS configuration.
    Primary evidence that the database enforces encrypted connections.
    Pairs with AUTH-007 for the full encryption-in-transit picture.

  Schema Assumptions:
    None (system catalog)

  Parameters:
    None

  Expected Output:
    name                     | setting        | source
    -------------------------+----------------+--------
    ssl                      | on             | configuration file
    ssl_min_protocol_version | TLSv1.2        | configuration file
    ssl_cert_file            | server.crt     | configuration file

  Adaptation Notes:
    - 'ssl = off' is a critical finding; escalate immediately.
    - On RDS/Aurora/Cloud SQL, SSL is managed by the provider; include
      a screenshot of the provider console as supplementary evidence.
    - ssl_min_protocol_version requires Postgres 12+.
*/

SELECT
    name,
    setting,
    unit,
    short_desc  AS description,
    source,
    sourcefile
FROM pg_settings
WHERE name LIKE 'ssl%'
ORDER BY name;
