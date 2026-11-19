# QuantRadar

**Status: planning stage. Not implemented.**

QuantRadar is a planned personal, read-only research app. The intended product brings U.S. equity fundamentals and a small set of related [Polymarket](https://polymarket.com) events into one source-linked daily briefing.

This repository currently contains design documents only:

- `README.md` — orientation and boundaries
- `docs/PRD.md` — product requirements (planned)
- `docs/schema.sql` — proposed SQLite schema (not applied to a live database)
- `docs/ROADMAP.md` — Version 1 and Version 2 planned scope, gates, and backlog (no release dates)
- `docs/ACCEPTANCE_CRITERIA.md` — testable checks for those versions (not test results)
- `docs/USE_CASES.md` — hypothetical operator scenarios
- `.gitignore` — ignore rules for a later implementation

There is no application code, no running service, no live data connector, and no track record in this repository. Nothing here should be read as a completed product, a backtest, a delivery schedule, or evidence that any heuristic works.

## Planned versions

Scope is ordered, not scheduled. There are no target ship dates in these documents.

- **Version 1** is a usable minimum: manual watchlist and optional holdings, limited source-linked U.S. equity snapshots, a durable daily briefing that shows freshness and job status, and read-only snapshots of a few **explicitly mapped** Polymarket markets (resolution criteria, spread, liquidity, and as-of time).
- **Version 2** would add deeper filing metrics and comparisons, historical snapshots, U.S. market-calendar and event context, journal improvements, and operational hardening.

Must-have versus stretch items and entry/acceptance gates are in `docs/ROADMAP.md` and `docs/ACCEPTANCE_CRITERIA.md`. What actually lands depends on permitted data access and tests. Missing data is flagged, not invented.

## What the product is meant to do

If built as specified, QuantRadar would help a single user:

- Keep a local watchlist and optional manual holdings record
- Pull company fundamentals from primary sources, with emphasis on earnings quality, operating cash flow, stock-based compensation, share-count dilution, and debt maturity concentration
- Attach those figures to SEC filings and other cited evidence
- Overlay scheduled macro events and a few explicitly mapped Polymarket markets
- Produce a daily briefing that labels freshness, missing data, and failed jobs
- Keep a research and discipline journal

The design treats prediction-market prices as noisy, incomplete reference signals, not as truth and not as trading instructions.

## What it is not

QuantRadar is not a broker, robo-advisor, hedge-fund tool, or betting client. The planned product will not:

- Place, route, or recommend trades or bets
- Connect to a brokerage, wallet, exchange account, or payment rail
- Store broker, wallet, or bank credentials
- Bypass geographic, legal, or terms-of-service controls on any data source
- Silently invent missing numbers
- Claim that a flag, mapping, or implied probability has measured predictive power

Planned screening rules are attention heuristics. They are not validated alpha, default probabilities, or investment advice.

## Planned stack

These choices are design intent, not a running architecture:

| Area | Planned choice |
| --- | --- |
| Web app | Next.js and TypeScript |
| Data collection and scheduled work | Python worker process |
| Storage | SQLite |
| Scheduling | A durable process on a machine that stays up, with persisted job state — not a best-effort serverless cron as the only scheduler |
| Market clock | `America/New_York`, including DST and the NYSE holiday / early-close calendar |

Routine collection and briefing generation would be application jobs. Feature work, connector changes, and bug fixes would happen in separate development sessions and would be reviewed and tested before being applied. See `docs/PRD.md` for that split.

## Reading the documents

1. Start with the goals, non-goals, and principles in `docs/PRD.md`.
2. Use `docs/ROADMAP.md` for Version 1 and Version 2 scope and backlog, then `docs/ACCEPTANCE_CRITERIA.md` for the gates that would mark a version complete.
3. Read `docs/USE_CASES.md` as hypothetical walk-throughs only.
4. Use `docs/schema.sql` as the proposed data shape. Comments in that file matter; several tables exist to record uncertainty, staleness, and job health rather than “answers.”
5. Treat every UI label, formula, and mapping described in these documents as planned behavior.

Do not commit `.env` files, credentials, local SQLite databases, or personal holdings. Those paths are listed in `.gitignore`.

## Privacy

No personal contact details, account identifiers, or private holdings belong in these documents. Implementation must keep local portfolio data on the operator’s machine unless the operator later chooses a different, explicit arrangement.
