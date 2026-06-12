/*
  ID:            AL-001
  Title:         Audit Log Daily Volume (Completeness Check)
  Control Theme: Audit Log Completeness
  TSC:           CC4.1, CC7.1
  Source:        APP
  Frequency:     Monthly

  Description:
    Counts audit events per day to identify gaps (days with zero or
    unusually low event counts). A sudden drop in volume may indicate
    that logging was disabled or an agent failed.

  Schema Assumptions:
    audit_events: created_at

  Parameters:
    \set review_start '2024-01-01'
    \set review_end   '2024-12-31'

  Expected Output:
    event_date  | total_events | distinct_users | distinct_event_types
    ------------+--------------+----------------+---------------------
    2024-04-18  | 3            | 3              | 3
    2024-04-17  | 5            | 3              | 4

  Adaptation Notes:
    - Compare daily totals to your baseline. Drops below a minimum
      expected volume (e.g., <10 events on a business day) are anomalies.
*/

\set review_start '2024-01-01'
\set review_end   '2024-12-31'

SELECT
    DATE_TRUNC('day', created_at)::DATE     AS event_date,
    COUNT(*)                                AS total_events,
    COUNT(DISTINCT actor_user_id)           AS distinct_users,
    COUNT(DISTINCT event_type)              AS distinct_event_types
FROM public.audit_events
WHERE created_at >= :'review_start'::TIMESTAMPTZ
  AND created_at <  :'review_end'::TIMESTAMPTZ + INTERVAL '1 day'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY event_date DESC;
