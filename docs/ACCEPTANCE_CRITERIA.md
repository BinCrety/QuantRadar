# QuantRadar Acceptance Criteria

| Field | Value |
| --- | --- |
| Document status | Draft, planning only |
| Product | QuantRadar |
| Stage | **Not implemented.** The checks below are intended test specifications for a future build. They are not test results, and none of them has been executed against a running product. |

Passing these checks would show that the software behaves as specified. It would **not** show that any heuristic predicts returns, defaults, or event outcomes.

This file expands section 13 of `docs/PRD.md`. Version scope and backlog are in `docs/ROADMAP.md`. Hypothetical operator walk-throughs are in `docs/USE_CASES.md`.

Tests should use local fixtures and permitted public sample data. They must not require a brokerage or wallet login, and they must not bypass source access rules.

## Standing rules (every version)

- No check may be satisfied by inventing a missing number.
- Last good snapshots must remain after a failed job, with a stale or partial label when appropriate.
- Prediction-market prices, when shown, travel with resolution criteria, as-of time, and spread/liquidity or an explicit “unavailable” note.
- Unmapped markets and events do not appear in a name-centric view.
- Portfolio return, win rate, and prediction-market calibration are **not** acceptance metrics.

## Provisional freshness rules

Exact windows are still an open question in the PRD. The following are **design proposals** for tests, not measured production SLAs and not a promise that a live system already enforces them.

| Subject | Proposed rule to test | What is not stale |
| --- | --- | --- |
| Job health | If an expected scheduled run does not start within a configured grace period, the run is missed and an alert is visible | A quiet filing day with a successful “nothing new” pull |
| Open mapped Polymarket markets | A snapshot older than a configured window (proposed starting point: 30 minutes) is labeled stale; prices are not interpolated | A closed or resolved market whose last snapshot is labeled closed or resolved and is not presented as live |
| Equity snapshots | The briefing shows the last successful ingest time; a failed or missed pull marks affected sections stale or partial | Absence of a new 10-Q or 8-K is not, by itself, staleness |
| Briefing | If any contributing must-have source failed or is stale, briefing status is `partial` or `failed`, never silently `ready` | A successful run that correctly reports no new filings |

The configured windows must be visible to the operator in the running app, once one exists.

## Evidence provenance (applies as soon as snapshots are shown)

A financial or filing snapshot used in a diagnostic or briefing is acceptable only if all of the following are stored and visible:

- Instrument identifier
- Period end and period type, consistent with filing metadata when a filing is the source
- Currency and unit scale
- Source URL, plus accession number and form type when the source is an SEC filing
- Ingest or capture time in UTC

If any of those are missing, the row is flagged and must not be treated as a complete input to a change calculation.

## Version 1 checks

These are required to call Version 1 complete. Each is written so a future automated or scripted test can pass or fail it.

### V1-A. Watchlist and holdings

- **Given** a fresh local database and no third-party accounts, **when** the operator adds an instrument and optional share quantity and cost basis, **then** the records persist after a process restart, and no broker or wallet prompt is shown.

### V1-B. Source-linked equity snapshot

- **Given** a fixture filing for a watched instrument, **when** a successful ingest runs, **then** the snapshot stores period, currency, unit scale, and a source URL, and the UI can present that URL.
- **Given** a fixture in which a required field is absent, **when** the snapshot is shown, **then** the field is missing or flagged, not filled with an estimate.

### V1-C. Daily briefing freshness and status

- **Given** all must-have jobs succeeded inside their windows, **when** the briefing is generated, **then** it has a New York calendar date, a visible last-successful-data time, and status `ready`.
- **Given** one must-have source failed after the allowed retry, **when** the briefing is generated, **then** status is `partial` or `failed`, the failed section is labeled, and earlier snapshots remain visible if present.

### V1-D. Mapped Polymarket snapshots

- **Given** a mapped market fixture that includes outcomes, prices, resolution criteria, spread, liquidity, and a capture time, **when** the briefing or market view is rendered, **then** all of those fields are shown, and nearby copy describes the prices as a market snapshot as of that capture time.
- **Given** a mapped market fixture with prices but no spread or no liquidity, **when** rendered, **then** the UI says “spread unavailable” and/or “liquidity unavailable” rather than showing a blank that could be mistaken for zero or for a tight market.
- **Given** an open-market fixture whose capture time is older than the configured window, **when** rendered, **then** the snapshot is labeled stale and the last values are not interpolated.
- **Given** a resolved market fixture, **when** rendered, **then** the resolved outcome is shown and the view is not labeled as a live forecast.

### V1-E. Mapping boundary

- **Given** a prediction market that exists in the database but has no active mapping to an instrument or theme, **when** an instrument page or holdings-centric briefing section is opened, **then** that market does not appear there.

### V1-F. Failure behavior and idempotency

- **Given** a source that fails on the first attempt and succeeds on the single retry, **when** the job finishes, **then** there is one logical set of snapshot side effects for the idempotency key, and status is success.
- **Given** a source that fails on the first attempt and the retry, **when** the job finishes, **then** status is failed, an alert is visible, last good data remains, and it is labeled stale if it is out of date.
- **Given** a worker that is stopped mid-job so the heartbeat expires, **when** the operator inspects job health, **then** a stuck or equivalent alert is visible, and a later safe retry does not duplicate snapshots for the same idempotency key.
- **Given** a scheduled slot that never starts within the grace period, **when** that period elapses, **then** a missed-run alert is visible.

### V1-G. Time labels in Version 1

- **Given** timestamps stored in UTC, **when** briefing dates and as-of times are displayed, **then** they use `America/New_York` via a real timezone database, not a fixed UTC−5 offset.
- Full holiday and early-close calendar coverage is a Version 2 must-have (see V2-C). Version 1 must not *mislabel* a date it does not know; it may show the New York date and time without claiming a cash session type when the calendar row is absent.

### V1-H. Safety and privacy hygiene

- **Given** a repository clone and the published `.gitignore`, **when** a local `.env` and a local SQLite holdings file are created in ignored paths, **then** they are not staged by a default `git add .`.
- **Given** any Version 1 UI, **when** the operator walks the screens, **then** there is no control that places a trade or a bet, and no form that collects broker or wallet credentials.

## Version 2 checks

Required to call Version 2 complete, in addition to Version 1 checks still passing.

### V2-A. Deeper filing metrics and comparisons

- **Given** two comparable snapshots for the same instrument (same period type, compatible units and currency, no unresolved restatement conflict), **when** diagnostics are viewed, **then** the configured comparisons are shown with both periods named.
- **Given** a prior period that is missing, differently scaled, or otherwise incomparable, **when** diagnostics are viewed, **then** the change is not computed and a flag explains why.
- **Given** fixture fields for net income, operating cash flow, stock-based compensation, and diluted or outstanding shares, **when** those fields are present, **then** the attention views described in the PRD are available and labeled as attention heuristics, not as buy, sell, or default predictions.
- **Given** debt maturity rows with amounts and years or dates, **when** the concentration view is shown, **then** the share of debt in a documented window is descriptive only, and each row keeps its source or confidence label.

### V2-B. Historical snapshots

- **Given** an original snapshot and a later restated or corrected snapshot for the same period, **when** history is queried, **then** both rows remain available and the relationship is visible; the original is not silently overwritten without a trail.

### V2-C. U.S. market calendar and event context

- **Given** a fixture date marked `holiday_closed`, **when** a briefing for that New York date is generated, **then** the briefing still may include filings and mapped prediction-market sections, and it states that the U.S. cash session is closed.
- **Given** a fixture date marked `early_close`, **when** session labels are shown, **then** the close is the early-close time in the fixture (typically 13:00 New York time), not 16:00.
- **Given** a fixture date marked `regular`, **when** session labels are shown, **then** the regular cash session is 09:30–16:00 New York time.
- **Given** timezone fixtures for a U.S. spring-forward date and a fall-back date, **when** display and briefing-date boundaries are computed, **then** local labels match `America/New_York` and do not use a hardcoded offset.
- **Given** a fixture filing with a timestamp after 16:00 New York time and a known session label, **when** the filing is listed, **then** it keeps that calendar date and an after-close (or equivalent) label rather than being silently moved to the next morning.
- **Given** a macro event mapped to an instrument with a rationale, **when** the instrument or briefing context is shown, **then** the event, time, session label, source link, and rationale appear, without wording that asserts the event caused a price move.
- **Given** an unmapped macro event, **when** the same instrument view is shown, **then** the event does not appear as if it were linked.

### V2-D. Journal improvements

- **Given** the operator, **when** they create research, discipline, and post-mortem entries, **then** each type can be stored, reopened, and linked to an instrument when provided.
- **Given** a discipline entry with a checklist, **when** an item is marked skipped, **then** that skip is visible later.
- **Given** any journal entry, **when** the operator reviews it, **then** there is no action that submits a trade or bet from the entry.

### V2-E. Operational hardening

- **Given** the Version 1 failure fixtures (retry once, double failure, expired heartbeat, missed slot, duplicate idempotency key), **when** the Version 2 test suite runs, **then** those checks still pass.
- **Given** a validation fixture with mixed unit scales or currencies, **when** a comparison would otherwise run, **then** a data-quality flag is raised and the values are not added or compared as if they were alike.
- **Given** a proposed worker or UI patch in a development session, **when** the documented review gate is followed, **then** tests that exist for the change are run and the patch is not treated as applied to the running app until that review step occurs. This is a process check; it is not an unattended self-deployment system.

## Explicitly out of acceptance

The following would not make a version pass or fail:

- Portfolio return or P&L
- Hit rate of attention flags
- Calibration of Polymarket prices against later outcomes
- Number of markets or issuers covered beyond the operator’s mapped set

## Traceability

| Check group | Main PRD references | Roadmap version |
| --- | --- | --- |
| V1-A watchlist and holdings | §§7.1, 11 | Version 1 must-have |
| V1-B provenance | §§5, 7.2–7.3, 9.2 | Version 1 must-have |
| V1-C briefing freshness | §§7.7, 9.1 | Version 1 must-have |
| V1-D and V1-E Polymarket and mappings | §§7.5–7.6 | Version 1 must-have |
| V1-F failure behavior | §9.1 | Version 1 must-have |
| V1-G time labels | §9.3 | Version 1 must-have (calendar depth in Version 2) |
| V2-A diagnostics | §7.2 | Version 2 must-have |
| V2-B history | §10 | Version 2 must-have |
| V2-C calendar and events | §§7.4, 7.6, 9.3 | Version 2 must-have |
| V2-D journal | §7.8 | Version 2 must-have |
| V2-E hardening | §§8.1, 9, 13 | Version 2 must-have |
