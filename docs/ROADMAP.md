# QuantRadar Development Roadmap

| Field | Value |
| --- | --- |
| Document status | Draft, planning only |
| Product | QuantRadar |
| Stage | **Not implemented.** This is a build-order and scope document, not a schedule and not a delivery report. |

This roadmap splits planned work into **Version 1** (a usable minimum research console) and **Version 2** (deeper research and operational hardening). It does not assign release dates, durations, or delivery commitments. A version is “done” only when its acceptance gates in `docs/ACCEPTANCE_CRITERIA.md` are actually met in a future implementation — not when a calendar date arrives.

Related documents:

- `docs/PRD.md` — product requirements and standing boundaries
- `docs/schema.sql` — proposed data shape
- `docs/ACCEPTANCE_CRITERIA.md` — testable checks for each version
- `docs/USE_CASES.md` — hypothetical operator scenarios

Scope for both versions remains a personal, read-only research aid for U.S. equities and a small set of explicitly mapped Polymarket markets, using only lawful, permitted public data. Nothing here authorizes trading, betting, credential storage, or bypassing access restrictions.

What can actually be built depends on permitted source access, field availability (especially prediction-market spread and liquidity), and tests. If a source is unavailable or a field cannot be obtained lawfully, the corresponding item stays out of that version or is shown as missing, not invented.

## Current state (Phase 0)

This repository holds planning documents only. There is no application code, no running worker, no live connector, and no applied database.

Unchecking the boxes below later would be a future implementation record. **None of this work has been started in code.**

## How versions are gated

Each version has:

- **Entry conditions** — what must already be true before implementation of that version should begin.
- **Must-have scope** — required to call the version complete.
- **Stretch scope** — useful if access and testing allow, not required.
- **Acceptance gate** — the checks in `docs/ACCEPTANCE_CRITERIA.md`. Passing them would not prove investment performance.

A later version does not start just because work on the earlier one has begun. Version 2 should wait until Version 1 must-haves pass their gate, or until a documented decision narrows Version 1 and records what was deferred.

There is no automated release calendar in this project.

## Version 1 — usable minimum

**Intent:** a local, read-only console that can hold a small watchlist, show source-linked snapshots for those names, take permitted snapshots of a few mapped Polymarket markets, and produce a daily briefing that is honest about freshness and failure.

### Entry conditions

- Planning documents in this repository are the agreed scope baseline (this file, the PRD, schema, acceptance criteria, and use cases).
- Implementation will use a durable worker and persisted job state, not a fire-and-forget serverless cron as the only scheduler.
- No broker, wallet, or betting integration is in scope.

### Must-have

1. Local web UI and Python worker with SQLite, as outlined in the PRD.
2. Manual watchlist and optional manual holdings entry. No broker connection.
3. Limited U.S. equity snapshots for watched names from permitted official or public filing sources: filing identity, a modest fundamentals snapshot when the fields are present, and a source URL (and accession number when available).
4. Every material figure shown with period, currency, unit scale, and evidence link, or else visibly marked incomplete.
5. Durable scheduled jobs with idempotency keys, a single retry plus backoff, heartbeats, missed-run detection, and in-app alerts.
6. A daily briefing, dated in `America/New_York`, that includes job status and freshness labels. If a source fails, the briefing is **partial** and the last good data remains, labeled stale when it is out of date.
7. Selected, **explicitly mapped** Polymarket markets only, read-only, from permitted public data: question, outcomes, resolution criteria, outcome prices, spread or an explicit “spread unavailable,” liquidity or “liquidity unavailable,” and an as-of (capture) timestamp with a staleness label.
8. Unmapped prediction markets do not appear on an instrument page or in a holdings-centric briefing section.
9. Copy treats prediction-market prices as market snapshots, not as established fact or calibrated forecasts.
10. Secrets, local holdings databases, and `.env` files stay out of git, consistent with `.gitignore`.

### Stretch (not required to complete Version 1)

- A small number of comparable-period diagnostic changes (for example, revenue or operating cash flow versus the prior comparable period) when — and only when — inputs are present and comparable.
- A bare research-note journal (create and edit a note linked to an instrument).
- Display of `America/New_York` session context on a regular weekday even without a full holiday calendar.

### Version 1 acceptance gate

See `docs/ACCEPTANCE_CRITERIA.md` section “Version 1.” Until those checks pass in a future test run, Version 1 is not complete. No performance, return, or forecast-calibration metric is part of this gate.

### Version 1 backlog (planned, not started)

| ID | Item | Priority |
| --- | --- | --- |
| V1-01 | Initialize the Next.js UI and Python worker skeleton, with configuration from uncommitted local files | Must-have |
| V1-02 | Apply a migration of `docs/schema.sql` (adjusted as needed) to a local, uncommitted SQLite file | Must-have |
| V1-03 | Watchlist and optional holdings: add, edit, archive, notes | Must-have |
| V1-04 | Permitted SEC or official filing index pull for watched identifiers | Must-have |
| V1-05 | Store limited financial snapshots with provenance fields; flag missing or incomparable values; do not impute | Must-have |
| V1-06 | Job runner: idempotency, one retry with backoff, heartbeats, missed and stuck alerts | Must-have |
| V1-07 | Daily briefing assembly with partial-status and last-successful-update labels | Must-have |
| V1-08 | Manual event-to-instrument and market-to-instrument mappings with a written rationale | Must-have |
| V1-09 | Permitted public Polymarket snapshots for mapped markets, including resolution, spread, liquidity, and as-of handling | Must-have |
| V1-10 | UI language review: “attention flag,” “stale,” “partial,” “mapped event”; no trade or bet path | Must-have |
| V1-11 | Comparable-period change calculations for a short field list | Stretch |
| V1-12 | Minimal journal notes | Stretch |

## Version 2 — deeper research and hardening

**Intent:** after a usable minimum exists, add richer filing analysis, historical snapshot review, calendar and macro-event context, a more useful journal, and stricter operational behavior.

### Entry conditions

- Version 1 must-haves have passed their acceptance gate, or a written note records which Version 1 items were deferred and why.
- Any source-access limits discovered in Version 1 are documented so Version 2 does not assume fields that were never available.

### Must-have

1. Deeper filing metrics and comparisons when data are comparable: earnings versus operating cash flow, stock-based compensation context, diluted or outstanding share-count change, and debt totals or maturity concentration when those rows can be sourced or entered by hand with a confidence label.
2. Historical snapshots that remain queryable; corrections or restatements do not silently erase prior rows.
3. U.S. cash-equity calendar context: regular session, early close, and full holiday close, plus briefing labels that do not assume a 16:00 close on an early-close day or an open cash session on a holiday. Filings and mapped prediction-market jobs may still run on a cash-market holiday, and the briefing must say so.
4. Manual macro-event list and display of mapped events next to the relevant names, with session labels and source links, without causation claims.
5. Journal improvements: research, discipline (checklist followed or skipped), and post-mortem entry types, still with no order generation and no automatic P&L engine.
6. Operational hardening: fixture tests for timezone and calendar behavior, clearer validation flags, and confirmation that retries do not duplicate snapshots.

### Stretch (not required to complete Version 2)

- Higher-recall debt-maturity note parsing, still source-linked and flagged on low confidence.
- Richer as-reported versus restated period comparison.
- Briefing or journal export to a local file.
- Additional event sources the operator maps by hand.
- Clearly labeled extended-hours quotes, only from a permitted source, if one is later chosen.

### Version 2 acceptance gate

See `docs/ACCEPTANCE_CRITERIA.md` section “Version 2.” The same standing rule applies: no investment-performance claim is an acceptance metric.

### Version 2 backlog (planned, not started)

| ID | Item | Priority |
| --- | --- | --- |
| V2-01 | Comparable-period diagnostics for cash-flow quality, SBC, share count, and leverage, with refusal and flags when inputs are incomparable | Must-have |
| V2-02 | Debt maturity rows (manual or low-confidence parse) and a concentration view | Must-have |
| V2-03 | Snapshot history and restatement links in the UI | Must-have |
| V2-04 | NYSE-style market calendar ingest or fixture load; holiday and early-close briefing labels | Must-have |
| V2-05 | Macro-event records and mapped-event display | Must-have |
| V2-06 | Journal entry types and discipline checklist | Must-have |
| V2-07 | Fixture tests for DST transitions, holiday and early-close labels, and idempotent retries | Must-have |
| V2-08 | Deeper debt-note parsing | Stretch |
| V2-09 | Local export of briefings or journal entries | Stretch |

## Later candidates (not in Version 1 or 2)

These remain out of version scope unless a later document explicitly pulls them in:

- Automatic mapping of headlines or markets to tickers
- Universe-wide coverage of U.S. equities or all Polymarket markets
- Brokerage, wallet, or order routing of any kind
- Published track records or calibrated “true probability” claims

## Out of bounds for every version

- Trade or bet placement, or any path from a screen to an order
- Storing broker, wallet, bank, or payment credentials
- Circumventing geographic, legal, or terms-of-service controls
- Silent imputation of missing financials or prices
- Firm delivery dates or automated release promises in product docs
