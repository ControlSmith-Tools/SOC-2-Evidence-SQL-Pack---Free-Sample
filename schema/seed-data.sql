-- =============================================================
-- SOC 2 Evidence SQL Pack — Sample Seed Data
-- =============================================================
-- Run sample-schema.sql first, then this file.
-- All data is fictional. Do not use real credentials or PII.
--
-- REFERENCE DATE: 2024-04-18
-- All timestamps are fixed to this reference date so that
-- date-filtered queries using the default range of
-- 2024-01-01 to 2024-12-31 reliably return rows.
-- Days-since-login values shown in sample CSVs are calculated
-- relative to 2024-04-18.
-- =============================================================

-- customers
INSERT INTO public.customers (name, plan, mrr_cents) VALUES
    ('Acme Corp',    'enterprise', 499900),
    ('Globex LLC',   'growth',      19900),
    ('Initech Inc',  'starter',      4900),
    ('Umbrella Ltd', 'enterprise', 299900);

-- roles
INSERT INTO public.roles (name, is_admin, description) VALUES
    ('admin',           true,  'Full system access'),
    ('member',          false, 'Standard user access'),
    ('viewer',          false, 'Read-only access'),
    ('billing_manager', false, 'Billing and subscription access');

-- users  (column list explicit to document intent)
INSERT INTO public.users (
    email, full_name, status, mfa_enabled, mfa_method,
    is_service_account, created_at, updated_at, last_login_at,
    password_changed_at, deactivated_at
) VALUES
--  email                         full_name          status     mfa    method          svc    created_at                  updated_at                  last_login_at               pwd_changed_at              deactivated_at
    ('alice@acmecorp.com',        'Alice Admin',      'active',  true,  'totp',         false, '2023-10-20 08:00:00+00', '2024-03-19 00:00:00+00', '2024-04-17 09:00:00+00', '2024-03-19 00:00:00+00', NULL),
    ('bob@acmecorp.com',          'Bob Builder',      'active',  true,  'totp',         false, '2024-01-20 08:00:00+00', '2024-02-19 00:00:00+00', '2024-04-15 14:00:00+00', '2024-02-19 00:00:00+00', NULL),
    ('carol@acmecorp.com',        'Carol Compliance', 'active',  false, NULL,           false, '2024-02-19 08:00:00+00', '2024-02-19 00:00:00+00', '2024-04-04 11:00:00+00', '2024-02-19 00:00:00+00', NULL),
    ('dan@acmecorp.com',          'Dan Developer',    'active',  true,  'hardware_key', false, '2024-03-04 08:00:00+00', '2024-03-04 00:00:00+00', '2024-04-16 16:00:00+00', '2024-03-04 00:00:00+00', NULL),
    ('eve@acmecorp.com',          'Eve Exec',         'active',  false, NULL,           false, '2023-10-01 08:00:00+00', '2023-10-01 00:00:00+00', '2024-01-08 09:00:00+00', '2023-10-01 00:00:00+00', NULL),
    ('frank@acmecorp.com',        'Frank Former',     'inactive',false, NULL,           false, '2023-01-10 08:00:00+00', '2024-01-15 09:05:00+00', '2023-12-19 17:00:00+00', '2023-01-10 00:00:00+00', '2024-01-15 09:05:00+00'),
    ('grace@globex.com',          'Grace Guest',      'active',  true,  'totp',         false, '2024-03-19 08:00:00+00', '2024-03-19 00:00:00+00', '2024-04-13 09:00:00+00', '2024-03-19 00:00:00+00', NULL),
    ('svc-pipeline@acmecorp.com', 'Pipeline Bot',     'active',  false, NULL,           true,  '2023-04-20 08:00:00+00', '2023-04-20 00:00:00+00', '2024-04-18 08:00:00+00', '2023-04-20 00:00:00+00', NULL),
    ('harry@initech.com',         'Harry Helper',     'invited', false, NULL,           false, '2024-04-11 08:00:00+00', '2024-04-11 00:00:00+00', NULL,                      NULL,                      NULL),
    ('ivan@umbrella.com',         'Ivan IT',          'active',  true,  'sms',          false, '2024-02-28 08:00:00+00', '2024-02-28 00:00:00+00', '2024-04-17 08:00:00+00', '2024-02-28 00:00:00+00', NULL);

-- Frank was deactivated by Alice (user id=1); set after the initial insert
-- because self-referencing within a single INSERT is not possible.
UPDATE public.users
SET deactivated_by_user_id = 1
WHERE email = 'frank@acmecorp.com';

-- user_roles
INSERT INTO public.user_roles (user_id, role_id, assigned_at, assigned_by_user_id) VALUES
    (1,  1, '2023-10-20 08:00:00+00', NULL),  -- alice:        admin  (self/system)
    (2,  2, '2024-01-20 08:00:00+00', 1),      -- bob:          member (alice)
    (3,  2, '2024-02-19 08:00:00+00', 1),      -- carol:        member (alice)
    (4,  2, '2024-03-04 08:00:00+00', 1),      -- dan:          member (alice)
    (5,  4, '2023-10-01 08:00:00+00', 1),      -- eve:          billing_manager (alice)
    (6,  2, '2023-04-20 08:00:00+00', 1),      -- frank:        member (alice) — now inactive
    (7,  3, '2024-03-19 08:00:00+00', 1),      -- grace:        viewer (alice)
    (8,  2, '2023-04-20 08:00:00+00', 1),      -- svc-pipeline: member (alice)
    (10, 1, '2024-02-28 10:00:00+00', 1);      -- ivan:         admin  (alice) — assigned in 2024

-- sessions
INSERT INTO public.sessions (user_id, ip_address, user_agent, created_at, last_seen_at, expires_at) VALUES
    (1,  '203.0.113.10',  'Mozilla/5.0 Chrome/120',  '2024-04-17 09:00:00+00', '2024-04-17 09:55:00+00', '2024-04-18 09:00:00+00'),
    (2,  '203.0.113.11',  'Mozilla/5.0 Firefox/121', '2024-04-15 14:00:00+00', '2024-04-15 14:00:00+00', '2024-04-16 14:00:00+00'),
    (4,  '203.0.113.14',  'Mozilla/5.0 Chrome/120',  '2024-04-16 16:00:00+00', '2024-04-16 16:40:00+00', '2024-04-17 16:00:00+00'),
    (10, '198.51.100.55', 'Mozilla/5.0 Safari/17',   '2024-04-17 08:30:00+00', '2024-04-17 08:58:00+00', '2024-04-18 08:30:00+00'),
    -- frank: expired session never purged — stale beyond the 90-day retention window, flagged by DR-002
    (6,  '203.0.113.66',  'Mozilla/5.0 Chrome/118',  '2023-11-01 09:00:00+00', '2023-11-05 14:00:00+00', '2023-11-08 09:00:00+00');

-- api_keys
INSERT INTO public.api_keys (user_id, name, key_prefix, key_hash, scopes, last_used_at, created_at) VALUES
    (8, 'Pipeline Integration', 'sk_live_ab', 'hashed_value_1', '{read,write}', '2024-04-18 08:00:00+00', '2023-04-20 08:00:00+00'),  -- 364 days old at ref date
    (1, 'Admin CLI',            'sk_live_cd', 'hashed_value_2', '{admin}',      '2024-04-11 09:00:00+00', '2024-02-18 09:00:00+00'),
    (6, 'Legacy Key',           'sk_live_ef', 'hashed_value_3', '{read}',       '2023-11-19 12:00:00+00', '2023-01-20 08:00:00+00');  -- inactive user — key ~454 days old at ref date, flagged by DR-005

-- access_grants
INSERT INTO public.access_grants (user_id, resource_type, resource_id, permission_level, granted_by_user_id, granted_at) VALUES
    (2, 'project',  1, 'write', 1, '2024-01-20 08:00:00+00'),
    (3, 'report',   1, 'read',  1, '2024-02-19 08:00:00+00'),
    (4, 'dataset',  2, 'write', 1, '2024-03-04 08:00:00+00'),
    (6, 'project',  1, 'read',  1, '2023-04-20 08:00:00+00'),  -- frank (inactive) still has this grant
    (8, 'pipeline', 1, 'admin', 1, '2023-04-20 08:00:00+00');

-- audit_events
INSERT INTO public.audit_events (event_type, actor_user_id, actor_ip, target_user_id, target_resource_type, target_resource_id, outcome, details, created_at) VALUES
    -- successful logins
    ('user.login',         1, '203.0.113.10',  NULL, NULL,     NULL, 'success', '{"method":"password+totp"}',                               '2024-04-17 09:00:00+00'),
    ('user.login',         2, '203.0.113.11',  NULL, NULL,     NULL, 'success', '{"method":"password+totp"}',                               '2024-04-15 14:00:00+00'),
    ('user.login',         3, '203.0.113.12',  NULL, NULL,     NULL, 'success', '{"method":"password"}',                                    '2024-04-17 10:05:00+00'),
    -- carol: 3 failed logins on 2024-04-17 (all within 60 min, count=3 — below FL-003 default threshold of 5)
    ('user.login',         3, '203.0.113.12',  NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":1}',                '2024-04-17 10:00:00+00'),
    ('user.login',         3, '203.0.113.12',  NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":2}',                '2024-04-17 10:01:00+00'),
    ('user.login',         3, '203.0.113.12',  NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":3}',                '2024-04-17 10:02:00+00'),
    -- frank deactivated by alice on 2024-01-15 (matches users.deactivated_at)
    ('user.deactivated',   1, '203.0.113.10',  6,    'user',   6,    'success', '{"reason":"offboarding"}',                                 '2024-01-15 09:05:00+00'),
    -- ivan assigned admin role by alice on 2024-02-28 (matches user_roles.assigned_at)
    ('user.role_assigned', 1, '203.0.113.10',  10,   'user',   10,   'success', '{"role":"admin"}',                                         '2024-02-28 10:00:00+00'),
    -- config change
    ('config.updated',     1, '203.0.113.10',  NULL, 'config', NULL, 'success', '{"key":"session_timeout","old":"3600","new":"1800"}',       '2024-04-13 11:00:00+00'),
    -- data export
    ('data.export',        1, '203.0.113.10',  NULL, 'export', 1,    'success', '{"data_type":"audit_log"}',                                '2024-04-16 14:00:00+00'),
    -- access denied
    ('access.denied',      3, '203.0.113.12',  NULL, 'report', 2,    'failure', '{"reason":"insufficient_permissions"}',                    '2024-04-15 09:00:00+00'),
    -- schema migration (matches schema_migrations row)
    ('schema.migration',   NULL, NULL,          NULL, 'schema', NULL, 'success', '{"version":"20240115_001","description":"add_mfa_method_column"}', '2024-01-15 08:00:00+00'),
    -- harry: failed login attempt (invited, not yet active)
    ('user.login',         9, '10.0.0.5',      NULL, NULL,     NULL, 'failure', '{"reason":"account_not_activated"}',                       '2024-04-12 11:00:00+00'),
    -- api key created
    ('api_key.created',    1, '203.0.113.10',  NULL, 'api_key',2,    'success', '{"name":"Admin CLI"}',                                     '2024-02-18 09:00:00+00'),
    -- eve: 6 failed logins at 04:00 UTC — triggers FL-003 (>= 5 threshold) and FL-006 (outside 08:00-20:00)
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":1}',                '2024-04-18 04:00:00+00'),
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":2}',                '2024-04-18 04:01:00+00'),
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":3}',                '2024-04-18 04:03:00+00'),
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":4}',                '2024-04-18 04:05:00+00'),
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"invalid_password","attempt":5}',                '2024-04-18 04:08:00+00'),
    ('user.login',         5, '198.51.100.22', NULL, NULL,     NULL, 'failure', '{"reason":"account_locked"}',                              '2024-04-18 04:10:00+00');

-- data_exports
INSERT INTO public.data_exports (requested_by_user_id, data_type, status, file_size_bytes, created_at, completed_at, retention_expires_at) VALUES
    (1, 'audit_log', 'completed', 15728640, '2024-01-09 10:00:00+00', '2024-01-09 10:05:00+00', '2024-04-08 10:00:00+00'),  -- retention expired; shows in DR-001
    (1, 'user_data', 'completed',  1048576, '2024-04-16 14:05:00+00', '2024-04-16 14:07:00+00', '2024-05-16 14:05:00+00'),
    (3, 'billing',   'completed',   524288, '2024-03-19 09:00:00+00', '2024-03-19 09:01:00+00', '2024-06-17 09:00:00+00');

-- schema_migrations
INSERT INTO public.schema_migrations (version, description, applied_at, applied_by, duration_ms) VALUES
    ('20231001_001', 'initial_schema',           '2023-10-01 07:00:00+00', 'deploy_user', 1200),
    ('20231115_001', 'add_api_keys_table',        '2023-11-15 07:00:00+00', 'deploy_user',  450),
    ('20240115_001', 'add_mfa_method_column',     '2024-01-15 08:00:00+00', 'deploy_user',   85),
    ('20240301_001', 'add_data_exports_table',    '2024-03-01 07:00:00+00', 'deploy_user',  320),
    ('20240401_001', 'add_retention_expires_at',  '2024-04-01 07:00:00+00', 'deploy_user',   95),
    ('20240411_001', 'add_audit_events_indexes',  '2024-04-11 07:00:00+00', 'deploy_user', 8400);
