# SOC 2 Evidence SQL Pack — Free Sample (10 Queries)

*by ControlSmith Tools · audit evidence, ready to run.*

This folder contains 10 free Postgres queries from the full **SOC 2 Evidence SQL Pack**.

The full pack contains **240 parameterised queries** — 60 queries across 9 control themes, ported to four dialects: **Postgres, Snowflake, BigQuery, and Microsoft SQL Server**. This free sampler ships the Postgres version of 10 representative queries so you can evaluate the style and depth before purchasing.

---

## Folder structure

```
sample/
├── README.md
├── DISCLAIMER.md
├── schema/
│   ├── sample-schema.sql
│   └── seed-data.sql
└── *.sql
```

---

## What's in this sample

| File | ID | Theme | Type |
|------|----|-------|------|
| `ar_001_all_active_users.sql` | AR-001 | Access Review | APP |
| `ar_006_stale_users_no_login_90d.sql` | AR-006 | Access Review | APP |
| `pu_001_db_superusers_detail.sql` | PU-001 | Privileged Users | CATALOG |
| `auth_002_users_without_mfa.sql` | AUTH-002 | Authentication | APP |
| `fl_003_brute_force_detection.sql` | FL-003 | Failed Logins | APP |
| `ul_004_inactive_users_with_access.sql` | UL-004 | User Lifecycle | APP |
| `al_001_audit_log_volume.sql` | AL-001 | Audit Logs | APP |
| `dr_001_exports_past_retention.sql` | DR-001 | Data Retention | APP |
| `enc_001_pg_ssl_settings.sql` | ENC-001 | Encryption | CATALOG |
| `ch_001_schema_migration_log.sql` | CH-001 | Change History | APP |

---

## How to use these queries

### Prerequisites

- A Postgres 12+ database
- A read-only role with access to `information_schema` and `pg_*` catalog views

### For APP queries (queries against application tables)

1. Clone or download this folder.
2. Run `schema/sample-schema.sql` and `schema/seed-data.sql` on a test database to create the sample tables.
3. Run any APP query against that test database to see how it works.
4. Adapt table and column names to your real schema using the adaptation notes in each file.

### For CATALOG queries

No adaptation needed — run directly against your Postgres instance with an appropriate role.

---

## What's in the full pack

The paid pack adds:

- **230 additional queries** — the remaining 50 Postgres queries plus full ports to Snowflake (60), BigQuery (60), and Microsoft SQL Server T-SQL (60)
- **Evidence Register** spreadsheet with query index, owner tracking, and review sign-off
- **Control Map** linking every query to SOC 2 TSC criteria
- **Schema Adaptation Guide** with parameter syntax for each dialect, common adaptation patterns, and troubleshooting
- **Performance and Usage Guide** with cadence guidance, per-dialect cost notes, and a 1.05-billion-row benchmark
- Sample schema and seed data for testing
- Sample output CSVs
- Per-dialect READMEs covering region handling (BigQuery), latency caveats (Snowflake), and edition differences (SQL Server / Azure SQL DB / Managed Instance)
- Single-user commercial licence

**→ Get the full pack — link in this repository's description.**

---

## Disclaimer

These queries are provided for informational purposes only. They are not legal or audit advice,
and do not guarantee that any auditor will accept their output as sufficient evidence.
Adapt all queries to your schema before use. See `DISCLAIMER.md` for the complete disclaimer.

---

*If this sampler was useful, please share it with your team and consider starring the repo.*

---

**ControlSmith Tools** · [controlsmithtools.com](https://controlsmithtools.com) · support@controlsmithtools.com
