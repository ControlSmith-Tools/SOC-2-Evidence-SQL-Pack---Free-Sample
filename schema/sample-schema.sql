-- =============================================================
-- SOC 2 Evidence SQL Pack — Sample Application Schema
-- =============================================================
-- This schema defines the fictional SaaS application tables
-- referenced by app-level queries in this pack.
--
-- Your real table names and column names will differ.
-- See /docs/schema-adaptation-guide.md for how to adapt.
-- =============================================================

-- gen_random_uuid() requires pgcrypto on Postgres 12; it is built-in from Postgres 13+.
-- This line is safe to run on any version.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Drop order respects foreign keys
DROP TABLE IF EXISTS public.audit_events        CASCADE;
DROP TABLE IF EXISTS public.sessions            CASCADE;
DROP TABLE IF EXISTS public.api_keys            CASCADE;
DROP TABLE IF EXISTS public.access_grants       CASCADE;
DROP TABLE IF EXISTS public.data_exports        CASCADE;
DROP TABLE IF EXISTS public.schema_migrations   CASCADE;
DROP TABLE IF EXISTS public.customer_users      CASCADE;
DROP TABLE IF EXISTS public.user_roles          CASCADE;
DROP TABLE IF EXISTS public.users               CASCADE;
DROP TABLE IF EXISTS public.roles               CASCADE;
DROP TABLE IF EXISTS public.customers           CASCADE;

-- -------------------------------------------------------------
-- customers
-- -------------------------------------------------------------
CREATE TABLE public.customers (
    id              SERIAL PRIMARY KEY,
    name            TEXT        NOT NULL,
    plan            TEXT        NOT NULL DEFAULT 'starter',  -- starter, growth, enterprise
    mrr_cents       INTEGER     NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);

-- -------------------------------------------------------------
-- roles  (application RBAC roles, not DB roles)
-- -------------------------------------------------------------
CREATE TABLE public.roles (
    id          SERIAL PRIMARY KEY,
    name        TEXT    NOT NULL UNIQUE,  -- admin, member, viewer, billing_manager
    is_admin    BOOLEAN NOT NULL DEFAULT false,
    description TEXT
);

-- -------------------------------------------------------------
-- users
-- -------------------------------------------------------------
CREATE TABLE public.users (
    id                  SERIAL PRIMARY KEY,
    email               TEXT        NOT NULL UNIQUE,
    full_name           TEXT        NOT NULL,
    status              TEXT        NOT NULL DEFAULT 'active',  -- active, inactive, suspended, invited
    mfa_enabled         BOOLEAN     NOT NULL DEFAULT false,
    mfa_method          TEXT,                                   -- totp, sms, hardware_key
    is_service_account  BOOLEAN     NOT NULL DEFAULT false,
    invited_by_user_id  INTEGER     REFERENCES public.users(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at       TIMESTAMPTZ,
    deactivated_at      TIMESTAMPTZ,
    deactivated_by_user_id INTEGER  REFERENCES public.users(id),
    password_changed_at TIMESTAMPTZ
);

-- -------------------------------------------------------------
-- user_roles
-- -------------------------------------------------------------
CREATE TABLE public.user_roles (
    id                  SERIAL PRIMARY KEY,
    user_id             INTEGER     NOT NULL REFERENCES public.users(id),
    role_id             INTEGER     NOT NULL REFERENCES public.roles(id),
    assigned_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    assigned_by_user_id INTEGER     REFERENCES public.users(id),
    revoked_at          TIMESTAMPTZ,
    revoked_by_user_id  INTEGER     REFERENCES public.users(id),
    UNIQUE (user_id, role_id)
);

-- -------------------------------------------------------------
-- customer_users  (which customers a user belongs to)
-- -------------------------------------------------------------
CREATE TABLE public.customer_users (
    user_id     INTEGER NOT NULL REFERENCES public.users(id),
    customer_id INTEGER NOT NULL REFERENCES public.customers(id),
    role        TEXT    NOT NULL DEFAULT 'member',
    joined_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, customer_id)
);

-- -------------------------------------------------------------
-- sessions
-- -------------------------------------------------------------
CREATE TABLE public.sessions (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     INTEGER     NOT NULL REFERENCES public.users(id),
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked_at  TIMESTAMPTZ,
    revoke_reason TEXT
);

-- -------------------------------------------------------------
-- api_keys
-- -------------------------------------------------------------
CREATE TABLE public.api_keys (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER     NOT NULL REFERENCES public.users(id),
    name            TEXT        NOT NULL,
    key_prefix      TEXT        NOT NULL,   -- first 8 chars of key for identification
    key_hash        TEXT        NOT NULL,   -- bcrypt/sha256 of full key
    scopes          TEXT[]      NOT NULL DEFAULT '{}',
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    revoked_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- -------------------------------------------------------------
-- access_grants  (resource-level permissions)
-- -------------------------------------------------------------
CREATE TABLE public.access_grants (
    id                  SERIAL PRIMARY KEY,
    user_id             INTEGER     NOT NULL REFERENCES public.users(id),
    resource_type       TEXT        NOT NULL,  -- project, dataset, report, pipeline
    resource_id         INTEGER     NOT NULL,
    permission_level    TEXT        NOT NULL,  -- read, write, admin, owner
    granted_by_user_id  INTEGER     REFERENCES public.users(id),
    granted_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at          TIMESTAMPTZ,
    revoked_at          TIMESTAMPTZ,
    revoked_by_user_id  INTEGER     REFERENCES public.users(id)
);

-- -------------------------------------------------------------
-- audit_events  (application-level audit log)
-- -------------------------------------------------------------
CREATE TABLE public.audit_events (
    id                      BIGSERIAL   PRIMARY KEY,
    event_type              TEXT        NOT NULL,
    actor_user_id           INTEGER     REFERENCES public.users(id),
    actor_ip                INET,
    target_user_id          INTEGER     REFERENCES public.users(id),
    target_resource_type    TEXT,
    target_resource_id      INTEGER,
    outcome                 TEXT        NOT NULL DEFAULT 'success',  -- success, failure, error
    details                 JSONB,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX audit_events_actor_user_id_idx  ON public.audit_events (actor_user_id);
CREATE INDEX audit_events_event_type_idx     ON public.audit_events (event_type);
CREATE INDEX audit_events_created_at_idx     ON public.audit_events (created_at);
CREATE INDEX audit_events_outcome_idx        ON public.audit_events (outcome);

-- -------------------------------------------------------------
-- data_exports
-- -------------------------------------------------------------
CREATE TABLE public.data_exports (
    id                      SERIAL PRIMARY KEY,
    requested_by_user_id    INTEGER     NOT NULL REFERENCES public.users(id),
    data_type               TEXT        NOT NULL,  -- user_data, audit_log, billing, full_backup
    status                  TEXT        NOT NULL DEFAULT 'pending',
    file_size_bytes         BIGINT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at            TIMESTAMPTZ,
    retention_expires_at    TIMESTAMPTZ,
    download_count          INTEGER     NOT NULL DEFAULT 0
);

-- -------------------------------------------------------------
-- schema_migrations
-- -------------------------------------------------------------
CREATE TABLE public.schema_migrations (
    version         TEXT        NOT NULL PRIMARY KEY,
    description     TEXT,
    applied_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    applied_by      TEXT        NOT NULL DEFAULT current_user,
    duration_ms     INTEGER
);
