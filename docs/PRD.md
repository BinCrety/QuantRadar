# QuantRadar Product Requirements Document

| Field | Value |
| --- | --- |
| Document status | Draft, planning only |
| Version | 0.1 |
| Date | 2026-11-19 |
| Product | QuantRadar |
| Stage | Requirements and schema only — **not implemented** |

This document describes a product that does not exist yet. Statements use “would,” “planned,” and “intended.” They are not claims of current capability, measured performance, or completed work. No screenshots, job histories, or research results are attached because none have been produced by this system.

## 1. Overview

QuantRadar is a planned personal research console. It would gather U.S. stock fundamentals and a limited set of Polymarket events, store them locally, and present a daily briefing in which every material number can be traced to a source.

The working hypothesis is simple and unproven: a disciplined user is less likely to miss dilution, cash-flow quality issues, clustered debt maturities, or stale event data if those items appear in one place, with timestamps and links. That is a process goal. It is not a forecast that the app would improve returns.

The product is read-only. It would not trade securities, place prediction-market orders, or hold funds.

## 2. Problem

Public company information is already available, but it is scattered across SEC filings, earnings releases, investor presentations, macro calendars, and occasional prediction markets. For a small personal watchlist, the recurring failure modes are operational, not a lack of raw headlines:

- Stock-based compensation and share issuance are easy to underweight if the user only skims headline earnings per share.
- Operating cash flow and net income can diverge for several quarters before the difference is noticed.
- Debt may be refinanced smoothly, or a maturity wall may cluster in a short window; the schedule lives in the notes, not the quote screen.
- Macro events (for example, FOMC decisions or CPI releases) are relevant to some holdings and irrelevant to others. Ad hoc mental links are easy to overfit.
- Prediction-market prices can look precise while being wide, thin, stale, or unresolved.
- When a data pull fails overnight, a briefing that still “looks complete” is worse than an explicit failure.

Separately, personal research often leaves no record of what was believed, what was ignored, and whether a pre-committed process was followed. The journal is a discipline tool, not a performance scoreboard.

## 3. Goals and non-goals

### 3.1 Planned goals

1. Maintain a local watchlist and an optional, manually entered holdings record.
2. Ingest fundamentals for those names from cited primary sources, especially 10-K, 10-Q, 8-K, and (for eligible foreign issuers) 20-F / 6-K filings and related earnings releases.
3. Compute and display a small set of diagnostic comparisons — for example, revenue and earnings changes, net income versus operating cash flow, SBC relative to cash generation, diluted share-count changes, and debt maturity concentration — only when the inputs are present and comparable.
4. Keep source URLs, filing identifiers, reporting periods, currencies, and unit scales with the numbers.
5. Track a short list of macro events and a short list of Polymarket markets that the user has **explicitly mapped** to instruments or themes.
6. Generate a daily briefing with freshness labels, validation flags, and job status.
7. Provide a research and discipline journal.
8. Make missed jobs, retries, and stale data visible instead of hiding them.

### 3.2 Non-goals (MVP and standing boundaries)

- No order entry, order routing, “one-click trade,” or betting.
- No brokerage, wallet, custodial, or exchange-account integration.
- No storage of broker, wallet, bank, or payment credentials.
- No circumvention of geographic restrictions, paywalls, or site terms.
- No attempt to cover the entire U.S. equity universe or all Polymarket markets.
- No automatic mapping of every news headline to every ticker.
- No claim that Polymarket prices are true probabilities, calibrated forecasts, or official resolutions before a market resolves.
- No silent imputation of missing financials or prices.
- No published or implied performance track record until (and unless) a later document reports actual measurements. This PRD does not contain such measurements.
- No social publishing, marketing automation, or third-party sharing of the user’s journal or holdings.

## 4. Users and usage context

The intended operator is a single individual researching a personal U.S. equity watchlist. There is no multi-tenant product, no customer onboarding flow, and no requirement to support a team in the MVP.

Assumed usage, if the app is built:

- A scheduled worker runs whether or not the browser is open.
- The user opens a local web UI to read the briefing, inspect diagnostics, follow source links, and write journal entries.
- Holdings, if any, are typed or imported by the user. The app does not “see” a broker.

This is personal research software. It is not an advisory service.

## 5. Product principles

1. **Source first.** A figure without a period, unit, currency, and link is incomplete. Incomplete figures may be shown only with a visible gap or flag.
2. **Flag, don’t invent.** Missing, duplicate, mismatched, or suspicious values stay missing and are flagged. The app does not fill gaps with estimates unless a later, explicit, labeled formula is approved — and MVP has no such formula.
3. **Heuristics are not results.** Checks such as “SBC is large relative to operating cash flow” or “a large share of debt comes due within two years” are planned attention rules. They are not backtested signals and must not be labeled as buy, sell, or default predictions.
4. **Mappings are explicit.** A Polymarket contract or macro event appears next to a holding only if a stored mapping says so and states a rationale. The UI must not imply causation.
5. **Prices are not truth.** A prediction-market price is a snapshot of a market. Resolution criteria, spread, liquidity, and capture time travel with the price.
6. **Failure is part of the interface.** If a job did not run, retried, or went stale, the briefing says so and shows the last successful update.
7. **Read-only money path.** There is no path in the MVP from a screen to a trade or a bet.

## 6. Planned phases

Phases are a build order, not a delivery report. None of them is done.

A later, more detailed split of planned Version 1 and Version 2 scope, must-have versus stretch items, and backlog IDs is in `docs/ROADMAP.md`. Testable gates are in `docs/ACCEPTANCE_CRITERIA.md`. Those documents also do not assign release dates or delivery commitments.

### Phase 0 — Documents (current)

This repository: requirements, proposed schema, ignore rules, plus the planned Version 1 / Version 2 roadmap, acceptance criteria, and hypothetical use cases.

### Phase 1 — MVP (planned)

- Local Next.js UI and Python worker
- SQLite schema from `docs/schema.sql` (subject to migration as implementation proceeds)
- Manual watchlist and holdings entry
- SEC filing index plus snapshot capture for watched names
- Diagnostic calculations with validation
- Manual macro-event list and manual Polymarket mappings
- Public, permitted Polymarket snapshots for mapped markets only
- Daily briefing and in-app job alerts
- Journal entries
- Durable scheduler with idempotent jobs, one retry, heartbeats, and missed-run detection

### Phase 2 — Later candidates (out of MVP unless explicitly pulled forward)

- Richer as-reported versus restated period comparison
- Better debt-note parsing with higher recall (still source-linked, still flagged on low confidence)
- Optional after-hours or pre-market quotes, clearly labeled — only from permitted sources
- Export of briefings and journals
- Additional event sources the user can map by hand

None of the Phase 2 items is promised, scheduled, or implemented.

## 7. Functional requirements

### 7.1 Watchlist, instruments, and holdings

The app would store:

- **Instrument:** ticker, exchange (for example NYSE or Nasdaq), name, type (common stock, ADR, ETF), sector (optional), currency (default USD), SEC CIK when known.
- **Watchlist item:** membership in a named list, optional short thesis text.
- **Holding (optional):** share quantity, cost basis, optional local account label, optional acquisition date, notes.

Holdings are a local research ledger. They are not positions pulled from a broker and must not be presented as confirmed street-side balances.

The UI should allow add, edit, archive, and note updates without requiring any third-party account.

### 7.2 Portfolio and name-level diagnostics

For each watched instrument with enough data, the MVP would show a diagnostics panel. Planned inputs include, when present in the source snapshot:

- Reporting period and period type (fiscal year, quarter, or clearly labeled TTM)
- Revenue, operating income, net income
- Operating cash flow; free cash flow only if the method is stored and shown
- Stock-based compensation
- Basic shares, diluted shares, and/or shares outstanding, as available
- Cash paid for repurchases and cash received from issuance, when available
- Cash and equivalents, total debt, short-term and long-term debt, interest expense when available
- Debt maturity rows parsed or entered from the filing notes

Planned comparisons (computed only on comparable periods; otherwise flagged):

| Check | Intended question | How it should be labeled |
| --- | --- | --- |
| Growth / change | How did revenue, income, and cash flow change versus the prior comparable period? | Period-over-period change, with periods named |
| Earnings vs cash | Is net income diverging from operating cash flow? | Attention heuristic, not an accrual “score” with proven meaning |
| SBC load | How large is SBC versus operating cash flow or revenue? | Attention heuristic |
| Dilution / share count | Did diluted or outstanding shares rise or fall, and do buybacks and issuance help explain it? | Descriptive share-count change, not a valuation verdict |
| Leverage and maturities | Is debt large versus cash, and do maturities cluster? | Descriptive concentration; not a default model |
| Restatement / amendment | Did a later filing revise the period? | Data warning |

The user may configure coarse thresholds later (for example, a percentage of debt maturing inside a chosen window). Default thresholds, if any ship, must be described as arbitrary starting points, not optimized cutoffs.

Quarter-over-quarter and year-over-year figures must not mix incompatible unit scales, currencies, or as-reported versus restated series without a flag.

### 7.3 SEC evidence

Each financial snapshot should point at a filing or release: form type, accession number when available, filing date, period end, and URL (EDGAR or the issuer’s investor-relations page if that is the actual source).

The worker would poll for new filings on watched CIKs or tickers using **permitted** public SEC or official data access methods. Implementation must follow the source’s published terms and rate limits. If a source is unavailable, the job fails visibly; the product must not scrape a blocked or disallowed path as a fallback.

Users should be able to open the cited document from the UI. The app does not need to be a full EDGAR reader in MVP, but it should store enough metadata to find the exhibit later.

### 7.4 Macro events

A small, curated table of macro or scheduled events (for example, FOMC announcements, CPI, or company earnings dates for watched names) would be maintained. MVP may rely on manual entry plus optional ingestion from a permitted public calendar.

Each event needs a name, type, scheduled time stored in UTC, display in `America/New_York`, and an official or cited source URL when one exists.

Earnings “before the open” / “after the close” must be retained as session context. A timestamp alone is not enough if the session label is known.

### 7.5 Selected Polymarket markets (read-only)

QuantRadar would **not** browse or ingest the entire Polymarket site. It would snapshot only markets the user has selected and mapped.

For each selected market, store and display at least:

- Market identifier, question, and URL
- Outcomes
- Resolution criteria and, if published, the resolution source
- Whether the market is open, closed, or resolved, and the resolved outcome when there is one
- Outcome prices at capture time
- Bid–ask spread if available from the permitted public data
- Liquidity and/or volume fields if available from the same permitted feed
- Capture timestamp and a staleness indicator

Display rules:

- Show spread and liquidity next to price so a mid or last price cannot be mistaken for a tight, deep market.
- If data is older than the configured freshness window, mark it stale and keep the last snapshot. Do not interpolate prices.
- If spread is unusually wide or liquidity is thin, show a warning. The warning is qualitative unless a documented threshold is configured.
- Copy must describe prices as market-implied snapshots, not as “the probability that X will happen” in an unqualified voice.
- Resolved markets should show the official market resolution and stop looking like live forecasts.

Data access:

- Use only public interfaces or pages that the operator is allowed to use.
- Respect terms of use, authentication requirements, and geographic eligibility. If the operator is not permitted to access the data, the app must not bypass that restriction (no VPN-or-proxy feature, no hidden client spoofing).
- No wallet connect, no order book trading, no deposit or withdrawal flows, no private account data.

### 7.6 Event-to-instrument mappings

A mapping row is required before a macro event or Polymarket market is shown in a name’s context or in a holdings-centric briefing section.

Each mapping would include:

- The event or market
- The instrument or a theme that instruments can belong to
- A relationship type (for example, “policy rate sensitivity,” “inflation print,” “company earnings,” “regulatory decision”)
- A short human-written rationale
- An active flag

The UI should show the rationale whenever the link is shown. It must not say that the event caused a price move, or that a correlated history will repeat. No automatic text such as “this market predicts the stock” is allowed.

MVP mappings are manual. Automatic suggestion of mappings is out of scope until a later design explains precision, review, and error handling. Even then, suggestions would need explicit acceptance.

### 7.7 Daily briefing

Once per intended briefing day, the app would assemble:

- Job health: last success, failures, retries, missed runs
- New or updated filings for watched names
- Diagnostic changes that pass validation
- Upcoming mapped macro events, with New York dates and session labels
- Mapped Polymarket snapshots, with staleness / spread / liquidity warnings
- Open data-quality flags
- Optional journal prompts (for example, an unresolved thesis note)

If some sources fail, the briefing is **partial**, not silently complete. Each section should indicate whether it is current.

The briefing date is a New York calendar date. Generation may occur before the cash-equity open, after the close, or both; the chosen schedule must be stored and shown. Market holidays do not automatically mean “no briefing,” because filings and prediction markets can still update. The briefing should state whether U.S. cash equities are scheduled to be open, closed, or early-close that day.

### 7.8 Research and discipline journal

The journal is a first-class MVP feature, not a notepad afterthought.

Planned entry types:

- **Research:** thesis, evidence, disconfirming evidence, open questions, links to instruments or filings.
- **Discipline:** whether a planned checklist was followed (for example, “read the cash-flow statement,” “checked diluted shares,” “checked mapped event freshness”) and what was skipped.
- **Post-mortem:** what was expected, what was observed, and what process change, if any, the user wants. This is a written reflection. It is not an automatic P&L attribution engine.

The journal must not be used to generate trade orders. Optional mood or trigger notes, if present, are private self-review fields, not medical or psychological claims.

### 7.9 Data quality and operations UI

The operator should be able to see:

- Job runs, statuses, attempt counts, error summaries, and heartbeats
- Unacknowledged alerts
- Data-quality flags by instrument and by field
- Source cursors and last successful ingestion times

Acknowledging an alert does not delete the underlying job record.

## 8. Architecture (planned)

```
[Next.js / TypeScript UI]  --->  [SQLite]
                                    ^
[Durable Python worker]  -----------+
        |
        |  permitted public sources
        |  (SEC / official filings, optional calendars,
        |   selected Polymarket public data)
```

- The UI is a local or self-hosted web app. MVP does not require a public internet-facing deployment.
- The worker is a long-running process (or a supervised process started by a real operating-system scheduler such as systemd/launchd) that records work in `job_run` rows. **Do not rely on a fire-and-forget serverless cron alone.** Those environments can skip runs, hide timeouts, and lose in-memory state. If a cloud timer is used later to wake the machine, the source of truth for “did the job run?” remains the database.
- SQLite is sufficient for a single-operator MVP. Writes from the worker and occasional UI actions must be serialized safely (one writer discipline or an equivalent busy-timeout/queue approach to be chosen at implementation).
- Configuration lives in environment variables or a local, uncommitted config file. Secrets never go in the repository.

### 8.1 Role split: application jobs versus development sessions

| Work | Who / what | Rule |
| --- | --- | --- |
| Scheduled fetches, validation, briefing assembly, alert creation | The application worker | Repeatable jobs with idempotency keys and stored results |
| New features, schema migrations, connector implementation, bug fixes, test writing | A developer or a coding agent (including Devin) in a **development session** | Changes are reviewed, tested, and then applied. No unattended patch of production code mid-job without a gate |
| Routine “fix the data and republish the briefing” after a normal source failure | The worker’s retry and the operator’s next run | Not an automatic agent session |
| Credentials and personal holdings | Operator only | Development sessions must not be given broker, wallet, or bank credentials |

“Gated, tested patches” means: automated tests that exist for the change should pass, the diff should be inspectable, and the operator (or a later documented review step) accepts the change before it becomes the running worker or UI. A coding agent may propose a patch; it may not silently overwrite the running app or the database schema on a live data file without that gate.

## 9. Scheduling, retries, idempotency, and time

### 9.1 Job contract (planned)

For each job name (examples: `sec_filings_pull`, `financials_refresh`, `polymarket_snapshot`, `briefing_generate`, `calendar_sync`):

- Create a `job_run` row with a unique **idempotency key** (for example, job name + intended New York date + interval slot). A retry of the same key must not insert a second logical run’s side effects.
- Set status to running, then heartbeat on a fixed interval while work proceeds.
- On failure, retry **once**, with backoff. After the second failure, mark failed and raise an alert. Do not loop indefinitely.
- On success, store finished time and light stats (counts fetched, flagged, skipped).
- If a scheduled slot has no start within a grace period, mark the run missed (or create a missed alert if the row was never created) so a silent skip cannot go unnoticed.
- If a heartbeat is older than a timeout while status is running, treat the job as stuck, alert, and allow a safe retry only if idempotency makes that safe.

Failed jobs must not delete the last good snapshots. Stale data remains visible and labeled stale.

### 9.2 Validation (planned)

Before a snapshot is used in diagnostics or briefings, check at least:

- Required identifiers present (instrument, period, source URL as applicable)
- Period end and period type consistent with the filing metadata
- Unit scale and currency known; do not add “1,200” and “1.2 million” as if they were the same
- Duplicate periods for the same instrument
- Numeric outliers against the name’s own history (flag, do not auto-correct)
- Freshness versus the per-source SLA
- Polymarket: missing criteria, missing prices, zero or unknown liquidity, unresolved close time, capture lag

Validation failures produce `data_quality_flag` rows and, when they affect a briefing section, in-briefing warnings.

### 9.3 Time zones, DST, and market holidays

- Persist timestamps in UTC (ISO-8601).
- Use `America/New_York` for trading-day boundaries, briefing dates, and equity session labels.
- DST transitions must use a real timezone database, not a fixed UTC−5 offset.
- Maintain or import an NYSE-style calendar: regular session, full holiday close, and early close. Nasdaq U.S. cash equities generally follow the same holiday pattern; if a difference is ever material, record it rather than assuming.
- U.S. cash regular session is 09:30–16:00 New York time on a regular trading day. The app may mention pre-market and after-hours as context but should not treat those prints as official close data unless a later phase adds a clearly labeled source.
- Scheduler examples: a pre-open briefing on a full holiday may still run for filings and Polymarket, but must say the cash session is closed. An early-close day must not assume a 16:00 close.
- Company reports filed after 16:00 New York time belong to that calendar date with an after-close label; they should not be quietly bucketed into the next morning without that label.

## 10. Data storage

The proposed schema is `docs/schema.sql`. It is a design file. It has not been applied, migrated, or tested against production data.

Implementation may add migrations, but should preserve the following ideas:

- Snapshots are append-friendly; corrections are new rows or explicit restatement flags, not silent overwrites of history without a trail.
- Evidence URLs live with the data.
- Jobs, heartbeats, and alerts are durable.
- Mappings are data, not hard-coded folklore in UI text.
- Personal holdings and the SQLite file stay local and uncommitted.

## 11. Security, privacy, and compliance boundaries

- No personal names, phone numbers, emails, addresses, or account numbers belong in public repository files.
- No promotion, coupon, or vendor-negotiation notes belong in product docs.
- Default-deny for secrets: environment files, API keys, cookies, and session tokens are outside git.
- The MVP has no user-authentication product surface beyond optional local access control the operator may later add; if added, credentials still do not go in the repo.
- Do not log secrets. Do not paste filing cookies or private API keys into journal examples.
- Geographic and terms-of-service limits are respected, not treated as bugs to work around.
- This software, if built, would be a research aid. It would not be a registered investment adviser, broker-dealer, or gambling product.

## 12. User interface notes (planned)

Keep the UI quiet and literal:

- Prefer “attention flag,” “stale,” “missing,” “partial briefing,” and “mapped event” over “signal,” “alpha,” or “prediction.”
- Show last successful source update next to any chart or table.
- Link out to SEC and Polymarket pages rather than implying the app is the official record.
- Do not use green/red price language on a heuristic that is not itself a return.

MVP screens (planned, not designed in high fidelity here): briefing, instrument diagnostic, filings list, events and mappings, jobs/alerts, journal, watchlist/holdings.

## 13. Planned acceptance checks

These are acceptance checks for a future implementation. They are not test results, and passing them would still not prove investment efficacy.

The expanded, version-scoped criteria are in `docs/ACCEPTANCE_CRITERIA.md`. Hypothetical walk-throughs are in `docs/USE_CASES.md`.

1. A new watchlist name can be added without any broker login.
2. A filing snapshot stores period, units, currency, and a working source URL.
3. Diagnostics refuse to compute a change when the prior period is missing or incomparable, and a flag is visible.
4. A mapped Polymarket market shows price, spread or an explicit “spread unavailable,” liquidity or “liquidity unavailable,” resolution criteria, and capture time.
5. An unmapped market does not appear on a holding’s page.
6. Copy near prediction-market prices describes them as market snapshots, not as established fact.
7. Killing the worker mid-job leaves a stale heartbeat that surfaces as an alert; a retry does not duplicate snapshots for the same idempotency key.
8. One forced source failure is retried once, then alerts, while last good data remains and is marked stale if out of date.
9. A New York DST transition and an NYSE holiday are handled with correct session labels in a fixture test, not by a hardcoded offset.
10. The test suite and a review step are required before a sample patch is accepted into the worker.
11. A repository clone of the public docs and later code would not contain credentials or personal holdings if `.gitignore` is honored.

Explicitly **not** an acceptance metric for MVP: portfolio return, win rate, or calibration of Polymarket prices.

## 14. Open questions (to resolve during implementation)

- Which permitted SEC or official market-data interfaces will be used, and what are their rate limits?
- Which permitted Polymarket public data path will be used, and what fields are reliably present (especially spread and liquidity)?
- What exact freshness windows apply per source?
- Is holdings import limited to a local CSV, or UI-only in MVP?
- Alerting: in-app only for MVP, or also a local desktop/OS notification? (No third-party marketing or unofficial SMS gateway is required.)
- How much debt-maturity structure can be parsed reliably versus entered by hand?

## 15. Glossary

- **Attention heuristic:** a planned rule that highlights a condition for human review. Not a measured predictor.
- **Briefing date:** the New York calendar date the briefing belongs to.
- **Idempotency key:** a unique key that makes a job safe to retry without double-applying effects.
- **Mapping:** a stored, reasoned link between an event or market and an instrument or theme.
- **Read-only:** the app does not submit trades or bets or move funds.
- **Stale:** the last snapshot is older than the freshness window, or a later job failed; the old value may still be shown with a label.
