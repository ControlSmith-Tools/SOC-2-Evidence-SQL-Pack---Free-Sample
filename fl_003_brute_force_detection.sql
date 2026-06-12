/*
  ID:            FL-003
  Title:         Brute-Force Pattern Detection
  Control Theme: Failed Authentication — Anomaly Detection
  TSC:           CC6.1, CC7.2
  Source:        APP
  Frequency:     Monthly

  Description:
    Detects accounts or source IPs that produced N or more failed logons
    within any sliding W-minute window. Catches both per-account hammering
    (one user being attacked) AND per-IP spraying (one IP across many users)
    via two parallel window passes, then UNIONed and de-duplicated.

    Implementation note: this uses a window function rather than a self-join.
    A self-join with an OR predicate — `JOIN failures f2 ON (f2.user = f1.user
    OR f2.ip = f1.ip)` — cannot be index-optimised by Postgres and becomes
    quadratic in the failure count. On a table with 2M+ failures the self-join
    version did not finish in 90+ minutes; the window-function version below
    returned the same results in ~0.5 seconds. See docs/schema-adaptation-guide.md
    Step 8 for the general pattern.

  Schema Assumptions:
    audit_events: event_type, actor_user_id, actor_ip, outcome, created_at
    users:        id, email

  Parameters:
    \set review_start '2024-01-01'
    \set review_end   '2024-12-31'
    \set window_mins  60
    \set threshold    5

  Expected Output:
    user_email       | actor_ip         | window_start        | failures_in_window
    -----------------+------------------+---------------------+-------------------
    eve@acmecorp.com | 198.51.100.22/32 | 2024-04-18 04:00:00 | 6

  Adaptation Notes:
    - For performance at scale, build the covering partial index from
      docs/schema-adaptation-guide.md Step 7:
        CREATE INDEX audit_failed_login_cov
          ON audit_events (actor_user_id, created_at, actor_ip)
          WHERE event_type='user.login' AND outcome='failure';
      Plus the by-IP variant if you use the by_ip CTE below:
        CREATE INDEX audit_failed_login_by_ip_cov
          ON audit_events (actor_ip, created_at, actor_user_id)
          WHERE event_type='user.login' AND outcome='failure';
    - If you only want per-account detection (cheaper, simpler), delete the
      by_ip CTE and the second branch of the UNION.
    - The window column is named `window_start` to match common SOC2 evidence
      conventions — it is the timestamp of the FIRST failure in the burst,
      with the count covering the next :window_mins minutes.

  Disclaimer: Reference only. Not legal or audit advice.
*/

\set review_start '2024-01-01'
\set review_end   '2024-12-31'
\set window_mins  60
\set threshold    5

WITH failures AS (
    SELECT ae.actor_user_id, ae.actor_ip, ae.created_at
    FROM public.audit_events ae
    WHERE ae.event_type = 'user.login'
      AND ae.outcome    = 'failure'
      AND ae.created_at >= :'review_start'::TIMESTAMPTZ
      AND ae.created_at <  :'review_end'::TIMESTAMPTZ + INTERVAL '1 day'
),
by_user AS (
    SELECT actor_user_id, actor_ip, created_at,
           COUNT(*) OVER (
               PARTITION BY actor_user_id
               ORDER BY created_at
               RANGE BETWEEN CURRENT ROW
                         AND (:window_mins || ' minutes')::INTERVAL FOLLOWING
           ) AS failures_in_window
    FROM failures
),
by_ip AS (
    SELECT actor_user_id, actor_ip, created_at,
           COUNT(*) OVER (
               PARTITION BY actor_ip
               ORDER BY created_at
               RANGE BETWEEN CURRENT ROW
                         AND (:window_mins || ' minutes')::INTERVAL FOLLOWING
           ) AS failures_in_window
    FROM failures
),
flagged AS (
    SELECT actor_user_id, actor_ip, created_at, failures_in_window
    FROM by_user WHERE failures_in_window >= :threshold
    UNION ALL
    SELECT actor_user_id, actor_ip, created_at, failures_in_window
    FROM by_ip   WHERE failures_in_window >= :threshold
)
SELECT DISTINCT ON (f.actor_user_id, f.actor_ip)
    COALESCE(u.email, '(unknown)')   AS user_email,
    f.actor_ip::TEXT,
    f.created_at                     AS window_start,
    f.failures_in_window
FROM flagged f
LEFT JOIN public.users u
    ON u.id = f.actor_user_id
ORDER BY f.actor_user_id, f.actor_ip, f.failures_in_window DESC;
