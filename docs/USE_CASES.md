# QuantRadar Use Cases

| Field | Value |
| --- | --- |
| Document status | Draft, planning only |
| Product | QuantRadar |
| Stage | **Not implemented.** Every scenario below is **hypothetical.** None is a record of a real user, a real portfolio, a live briefing, or observed product behavior. |

These cases describe how a future operator might use the planned app, and how the app is intended to respond. Names such as `TICKER-A` and market labels such as `MARKET-FOMC` are fixtures, not research calls and not descriptions of actual positions.

Standing product boundaries still apply: read-only U.S. equity research, selected lawful public Polymarket data, no trading or betting, no access-control bypass, and no invented numbers. See `docs/PRD.md`, `docs/ROADMAP.md`, and `docs/ACCEPTANCE_CRITERIA.md`.

## UC-01 — First watchlist, no broker

**Version:** 1  
**Situation:** An operator wants to follow a small set of U.S. names and optionally type a share count and cost basis for one of them.

**Intended behavior:** The operator adds `TICKER-A` and `TICKER-B` to a local watchlist, enters optional holding fields for `TICKER-A` by hand, and sees those records after restarting the app. There is no broker login and no imported street-side balance.

**Must not happen:** The app must not present manual holdings as confirmed custodian positions, and it must not request brokerage credentials.

## UC-02 — New filing appears in the briefing

**Version:** 1  
**Situation:** A permitted filing pull finds a new 10-Q fixture for `TICKER-A` with revenue, operating cash flow, and a source URL. Some other fields are absent.

**Intended behavior:** The next briefing lists the filing with form type, period, and a working source link. Present fields are shown with currency and unit scale. Absent fields are blank or flagged, not estimated. The briefing shows when the pull last succeeded.

**Must not happen:** The app must not invent the missing fields, and it must not hide the source.

## UC-03 — Mapped prediction market, wide or thin book

**Version:** 1  
**Situation:** The operator has manually mapped a public fixture market, `MARKET-FOMC`, to a theme that includes `TICKER-B`, with a written rationale such as “policy-rate context for a rate-sensitive name.” The snapshot has outcome prices, a wide spread, low liquidity, resolution criteria, and a recent capture time.

**Intended behavior:** The briefing or theme view shows the question, outcomes, prices, spread, liquidity, resolution criteria, as-of time, and the mapping rationale. Copy describes the prices as a market snapshot, not as “the” probability of the event. The wide spread and thin liquidity are visible so the prices are not mistaken for a tight market.

**Must not happen:** The app must not imply that the market causes moves in `TICKER-B`, must not offer a bet or wallet connect, and must not drop spread or liquidity without an “unavailable” label if those fields are missing instead.

## UC-04 — Overnight job failure

**Version:** 1  
**Situation:** The scheduled Polymarket snapshot job fails its first attempt and its one retry. An earlier snapshot from a previous successful run still exists and is now older than the freshness window. The equity filing pull succeeded.

**Intended behavior:** The briefing status is partial. Equity sections can be current. The prediction-market section shows the last snapshot, marks it stale, and surfaces an alert for the failed job after retry. The old snapshot is not deleted.

**Must not happen:** The briefing must not look complete. The app must not interpolate newer prices to fill the gap.

## UC-05 — Unmapped market stays out of the name view

**Version:** 1  
**Situation:** A public market fixture exists in the local database because it was inspected earlier, but the operator has not created an active mapping to `TICKER-A`.

**Intended behavior:** `TICKER-A`’s page and any holdings-centric briefing section omit that market. The operator may later add a mapping with a rationale; only then does it appear in that context.

**Must not happen:** The app must not auto-attach the market because the question text happens to mention a related word.

## UC-06 — Incomparable periods

**Version:** 2 (stretch if comparable-period math appears earlier)  
**Situation:** `TICKER-A` has a current-quarter snapshot in millions of USD and a prior-period fixture whose unit scale is unknown, or the prior period is missing.

**Intended behavior:** The diagnostic view refuses the change calculation and shows a flag (unit anomaly, missing prior period, or similar). The raw snapshots remain visible with their provenance.

**Must not happen:** The app must not add or divide the two series as if they were comparable, and it must not quietly rescale without a recorded, visible method.

## UC-07 — Attention flags on cash flow, dilution, and debt

**Version:** 2  
**Situation:** Comparable fixtures for `TICKER-A` show net income diverging from operating cash flow, a rise in diluted shares, and a cluster of debt maturities inside a configured window. Each figure has a source.

**Intended behavior:** The name view highlights these as attention heuristics, with periods, amounts, and links. Labels stay descriptive (“share count increased,” “portion of listed maturities falls in this window”).

**Must not happen:** The UI must not call these a buy or sell signal, a default probability, or a proven edge.

## UC-08 — Cash-market holiday, other data still move

**Version:** 2  
**Situation:** The New York calendar date is a fixture full holiday for U.S. cash equities. A filing still arrives, and a mapped prediction market still has a new permitted snapshot.

**Intended behavior:** The briefing for that date still runs, states that the cash session is closed, and may include the filing and the market snapshot with normal freshness rules.

**Must not happen:** The app must not skip the briefing solely because the cash market is closed, and it must not label the cash session as a regular 09:30–16:00 day.

## UC-09 — Early close and after-close filing time

**Version:** 2  
**Situation:** A fixture early-close date has a regular open and a 13:00 New York close. A company filing fixture is timestamped after the regular 16:00 close on a different, regular session date.

**Intended behavior:** On the early-close date, labels do not assume a 16:00 close. On the regular date, the after-close filing keeps that calendar date and an after-close label rather than being moved silently to the next morning.

**Must not happen:** The app must not use a fixed UTC offset that breaks on a DST transition, and it must not treat pre-market or after-hours prints as official closes unless a later, separate, labeled source is added.

## UC-10 — Discipline journal after a review

**Version:** 2  
**Situation:** After reading a 10-Q fixture for `TICKER-A`, the operator wants a record of what was checked.

**Intended behavior:** The operator writes a discipline entry, ticks or skips checklist items (for example, cash-flow statement, diluted shares, mapped-event freshness), and can reopen the entry later. A research thesis and a disconfirming note can be stored in a research entry.

**Must not happen:** The journal must not place orders, compute an official P&L scoreboard, or publish the entry anywhere off the local app.

## UC-11 — Source access denied

**Version:** 1  
**Situation:** A planned connector cannot lawfully reach a data source (terms, geography, or authentication the operator is not permitted to use).

**Intended behavior:** The job fails visibly, the briefing is partial if that source was required, and last good data, if any, stays labeled appropriately.

**Must not happen:** The app must not offer a VPN, proxy, or spoofing feature to bypass the restriction, and it must not scrape a disallowed path as a “fallback.”

## UC-12 — Development change versus routine job

**Version:** 1 (process), reinforced in Version 2 hardening  
**Situation:** A data connector needs a logic change after repeated validation failures.

**Intended behavior:** Routine retries stay in the application worker. The connector change is made in a development session, reviewed, and tested before it becomes the running worker. The running job does not silently self-patch mid-flight.

**Must not happen:** A coding agent or developer session must not receive broker or wallet credentials, and unreviewed patches must not be treated as the live app.
