-- QuantRadar proposed SQLite schema
--
-- PLANNING STAGE ONLY.
-- This file is a design proposal. It has not been applied to a running
-- database, and no application code exists yet. Table and column names
-- may change during implementation through explicit migrations.
--
-- Conventions:
--   * Timestamps are stored as ISO-8601 text in UTC.
--   * Calendar dates that represent U.S. equity "trading days" or briefing
--     dates are New York calendar dates (YYYY-MM-DD), labeled in column
--     comments where that matters.
--   * Money and share counts are REAL and must be interpreted with
--     currency + unit_scale on the parent snapshot. Do not assume millions.
--   * Missing values are NULL. Do not invent placeholders that look like data.
--   * Personal holdings that may later be stored in these tables must stay
--     in a local, uncommitted database file.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Reference and portfolio
-- ---------------------------------------------------------------------------

CREATE TABLE instrument (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    exchange TEXT,                  -- e.g. NYSE, NASDAQ, NYSEAMERICAN
    name TEXT,
    instrument_type TEXT,           -- common_stock, adr, etf, other
    sector TEXT,
    currency TEXT NOT NULL DEFAULT 'USD',
    cik TEXT,                       -- SEC CIK when known
    isin TEXT,
    cusip TEXT,                     -- optional; do not commit real personal files with this if sensitive
    active INTEGER NOT NULL DEFAULT 1,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (ticker, exchange)
);

CREATE TABLE watchlist_item (
    id INTEGER PRIMARY KEY,
    instrument_id INTEGER NOT NULL REFERENCES instrument(id),
    list_name TEXT NOT NULL DEFAULT 'default',
    thesis_summary TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (instrument_id, list_name)
);

-- Manual research ledger only. Not a broker position feed.
CREATE TABLE holding (
    id INTEGER PRIMARY KEY,
    instrument_id INTEGER NOT NULL REFERENCES instrument(id),
    shares REAL,
    cost_basis_per_share REAL,
    cost_basis_total REAL,
    account_label TEXT,             -- local label only; not a login
    acquired_on TEXT,               -- YYYY-MM-DD, optional
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- U.S. cash equity calendar (NYSE-style). Used for session labels and
-- scheduler context. A closed cash session does not skip filing or
-- prediction-market jobs by itself.
CREATE TABLE market_calendar (
    id INTEGER PRIMARY KEY,
    calendar_date TEXT NOT NULL,    -- New York calendar date
    market TEXT NOT NULL DEFAULT 'NYSE',
    session_type TEXT NOT NULL,     -- regular, early_close, holiday_closed
    notes TEXT,
    UNIQUE (calendar_date, market)
);

-- ---------------------------------------------------------------------------
-- SEC filings and fundamentals
-- ---------------------------------------------------------------------------

CREATE TABLE sec_filing (
    id INTEGER PRIMARY KEY,
    instrument_id INTEGER NOT NULL REFERENCES instrument(id),
    accession_number TEXT,
    form_type TEXT NOT NULL,        -- 10-K, 10-Q, 8-K, 20-F, 6-K, amendments, etc.
    filed_at TEXT,                  -- UTC
    period_end TEXT,                -- YYYY-MM-DD when applicable
    filing_url TEXT NOT NULL,
    exhibit_url TEXT,
    title TEXT,
    ingested_at TEXT NOT NULL,      -- UTC
    UNIQUE (accession_number)
);

CREATE TABLE financial_snapshot (
    id INTEGER PRIMARY KEY,
    instrument_id INTEGER NOT NULL REFERENCES instrument(id),
    period_end TEXT NOT NULL,       -- YYYY-MM-DD
    period_type TEXT NOT NULL,      -- FY, Q1, Q2, Q3, Q4, TTM, other
    fiscal_year INTEGER,
    as_reported INTEGER NOT NULL DEFAULT 1, -- 0 if a later restatement series
    restated_from_snapshot_id INTEGER REFERENCES financial_snapshot(id),
    revenue REAL,
    operating_income REAL,
    net_income REAL,
    operating_cash_flow REAL,
    free_cash_flow REAL,            -- only if fcf_method is filled
    fcf_method TEXT,                -- e.g. ocf_minus_capex_as_disclosed; NULL if FCF not used
    stock_based_compensation REAL,
    basic_shares REAL,
    diluted_shares REAL,
    shares_outstanding REAL,
    buybacks_cash REAL,
    share_issuance_cash REAL,
    cash_and_equivalents REAL,
    total_debt REAL,
    short_term_debt REAL,
    long_term_debt REAL,
    interest_expense REAL,
    source_filing_id INTEGER REFERENCES sec_filing(id),
    source_url TEXT,
    currency TEXT NOT NULL DEFAULT 'USD',
    unit_scale INTEGER NOT NULL DEFAULT 1, -- 1, 1000, or 1000000
    raw_payload_json TEXT,
    ingested_at TEXT NOT NULL,
    UNIQUE (instrument_id, period_end, period_type, as_reported)
);

CREATE TABLE debt_maturity (
    id INTEGER PRIMARY KEY,
    financial_snapshot_id INTEGER NOT NULL REFERENCES financial_snapshot(id),
    instrument_id INTEGER NOT NULL REFERENCES instrument(id),
    maturity_year INTEGER,
    maturity_date TEXT,             -- YYYY-MM-DD when a specific date is known
    amount REAL NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    unit_scale INTEGER NOT NULL DEFAULT 1,
    description TEXT,
    source_url TEXT,
    confidence TEXT                 -- parsed, manual, low_confidence_parse
);

-- Generic cited evidence, including IR pages or briefing attachments.
CREATE TABLE evidence_link (
    id INTEGER PRIMARY KEY,
    instrument_id INTEGER REFERENCES instrument(id),
    related_table TEXT,
    related_id INTEGER,
    label TEXT,
    url TEXT NOT NULL,
    source_name TEXT,               -- SEC EDGAR, issuer IR, Polymarket, official calendar
    retrieved_at TEXT
);

-- ---------------------------------------------------------------------------
-- Macro events and selected prediction markets
-- ---------------------------------------------------------------------------

CREATE TABLE macro_event (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    event_type TEXT,                -- fomc, cpi, earnings, other
    scheduled_for TEXT,             -- UTC instant
    timezone_display TEXT NOT NULL DEFAULT 'America/New_York',
    session_label TEXT,             -- before_open, during_session, after_close, not_applicable
    official_source_url TEXT,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Catalog row for a selected market. Not a wallet or order object.
CREATE TABLE prediction_market (
    id INTEGER PRIMARY KEY,
    source TEXT NOT NULL DEFAULT 'polymarket',
    market_id TEXT NOT NULL,
    condition_id TEXT,
    slug TEXT,
    question TEXT NOT NULL,
    description TEXT,
    category TEXT,
    outcomes_json TEXT,             -- JSON array of outcome names
    resolution_criteria TEXT,
    resolution_source TEXT,
    end_date TEXT,
    closed INTEGER NOT NULL DEFAULT 0,
    resolved INTEGER NOT NULL DEFAULT 0,
    resolved_outcome TEXT,
    url TEXT NOT NULL,
    first_seen_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (source, market_id)
);

CREATE TABLE prediction_market_snapshot (
    id INTEGER PRIMARY KEY,
    prediction_market_id INTEGER NOT NULL REFERENCES prediction_market(id),
    captured_at TEXT NOT NULL,      -- UTC
    outcome_prices_json TEXT NOT NULL,
    bid_ask_spreads_json TEXT,      -- NULL if the permitted feed has no spread
    liquidity REAL,                 -- NULL if unavailable; do not zero-fill
    volume_24h REAL,
    open_interest REAL,
    stale INTEGER NOT NULL DEFAULT 0,
    staleness_seconds INTEGER,
    source_url TEXT,
    raw_payload_json TEXT
);

-- Explicit, human-configured links. No automatic causation claim.
CREATE TABLE event_mapping (
    id INTEGER PRIMARY KEY,
    prediction_market_id INTEGER REFERENCES prediction_market(id),
    macro_event_id INTEGER REFERENCES macro_event(id),
    instrument_id INTEGER REFERENCES instrument(id),
    theme TEXT,                     -- optional theme if not a single instrument
    relationship_type TEXT NOT NULL,
    mapping_rationale TEXT NOT NULL,
    confidence_note TEXT,           -- qualitative only; not a measured edge
    active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL DEFAULT 'manual',
    CHECK (
        (prediction_market_id IS NOT NULL OR macro_event_id IS NOT NULL)
        AND (instrument_id IS NOT NULL OR (theme IS NOT NULL AND length(trim(theme)) > 0))
    )
);

-- ---------------------------------------------------------------------------
-- Jobs, alerts, validation
-- ---------------------------------------------------------------------------

CREATE TABLE job_run (
    id INTEGER PRIMARY KEY,
    job_name TEXT NOT NULL,
    idempotency_key TEXT NOT NULL UNIQUE,
    scheduled_for TEXT,             -- UTC intended start or slot
    briefing_date TEXT,             -- New York date when the job is date-scoped
    started_at TEXT NOT NULL,
    heartbeat_at TEXT,
    finished_at TEXT,
    status TEXT NOT NULL,           -- running, success, failed, retrying, missed, cancelled, stuck
    attempt INTEGER NOT NULL DEFAULT 1,
    max_attempts INTEGER NOT NULL DEFAULT 2, -- initial try + one retry
    error_summary TEXT,
    error_detail TEXT,
    stats_json TEXT
);

CREATE INDEX job_run_name_started_idx ON job_run (job_name, started_at);

CREATE TABLE job_alert (
    id INTEGER PRIMARY KEY,
    job_run_id INTEGER REFERENCES job_run(id),
    job_name TEXT NOT NULL,
    alert_type TEXT NOT NULL,       -- missed_run, failed_after_retry, stale_data, heartbeat_timeout, validation_failure
    message TEXT NOT NULL,
    created_at TEXT NOT NULL,
    acknowledged_at TEXT
);

CREATE TABLE data_quality_flag (
    id INTEGER PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id INTEGER,
    instrument_id INTEGER REFERENCES instrument(id),
    flag_type TEXT NOT NULL,        -- missing_field, unit_anomaly, duplicate, stale, period_mismatch, suspicious_value, thin_market
    severity TEXT NOT NULL,         -- info, warning, error
    field_name TEXT,
    message TEXT NOT NULL,
    not_imputed INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    resolved_at TEXT
);

CREATE TABLE ingestion_cursor (
    id INTEGER PRIMARY KEY,
    source_name TEXT NOT NULL UNIQUE,
    cursor_value TEXT,
    last_success_at TEXT,
    last_attempt_at TEXT,
    notes TEXT
);

-- ---------------------------------------------------------------------------
-- Briefings and journal
-- ---------------------------------------------------------------------------

CREATE TABLE briefing (
    id INTEGER PRIMARY KEY,
    briefing_date TEXT NOT NULL UNIQUE, -- New York calendar date
    generated_at TEXT NOT NULL,
    status TEXT NOT NULL,           -- draft, ready, failed, partial
    cash_session_type TEXT,         -- regular, early_close, holiday_closed, unknown
    last_successful_data_at TEXT,
    summary TEXT
);

CREATE TABLE briefing_item (
    id INTEGER PRIMARY KEY,
    briefing_id INTEGER NOT NULL REFERENCES briefing(id),
    instrument_id INTEGER REFERENCES instrument(id),
    item_type TEXT NOT NULL,        -- filing, financial_change, prediction_market, macro, data_quality, job, journal_reminder
    title TEXT NOT NULL,
    body TEXT,
    source_url TEXT,
    sort_order INTEGER,
    created_at TEXT NOT NULL
);

CREATE TABLE journal_entry (
    id INTEGER PRIMARY KEY,
    entry_type TEXT NOT NULL,       -- research, discipline, post_mortem
    instrument_id INTEGER REFERENCES instrument(id),
    title TEXT,
    body TEXT NOT NULL,
    thesis TEXT,
    disconfirming_evidence TEXT,
    process_checklist_json TEXT,
    mood_or_trigger TEXT,           -- optional private self-review; not a medical field
    related_macro_event_id INTEGER REFERENCES macro_event(id),
    related_prediction_market_id INTEGER REFERENCES prediction_market(id),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
