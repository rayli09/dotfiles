---
name: public-market-signal-research
description: Use when researching public-market tickers, market regime, fundamentals, ETF/fund exposure, yfinance news, upcoming earnings context, or agent-assisted buy/sell/watch judgment. Guides agents to use signal-cli and browser/web evidence as inputs while reserving final investment judgment for the agent/user.
---

# Public Market Signal Research

## Overview

Use this skill to turn public market information into structured evidence for an agent’s judgment. The skill does not make automatic trading decisions; it gathers and weighs evidence from `signal-cli`, yfinance, browser-visible sources, and cited public context.

## Core Rule

Treat all scores and setup labels as evidence, not instructions. Say “constructive setup”, “watch setup”, or “risk setup”; avoid claiming “buy” or “sell” unless the user explicitly asks for a discretionary recommendation and you explain the judgment, uncertainty, and risks.

## Workflow

1. Clarify scope only if needed: ticker list, horizon, benchmark, sector, and whether this is screening, deep dive, or monitoring.
2. Run `signal-cli` first for structured evidence. See `references/signal-cli.md` for commands and field meanings.
3. Use Browser or web reading for qualitative evidence that yfinance cannot fully answer: latest news, earnings-call pages, company IR pages, SEC pages, fund holdings pages, headlines, and source-level context.
4. Separate evidence types:
   - Technical: price, momentum, volatility, volume, relative performance.
   - Market regime: index/ETF trend, VIX proxy, risk-on/risk-off.
   - Fundamentals: growth, margins, cash flow, debt, valuation.
   - Ownership/funds: current ETF/fund exposure.
   - News/events: current news, upcoming earnings, guidance, analyst actions, filings.
5. Identify conflicts explicitly. Example: “fundamentals healthy, but technical breakdown flag is active.”
6. Deliver a judgment as an agent conclusion only after evidence review. Include assumptions, caveats, and what would change the view.

## Evidence Standard

- Prefer exact command outputs, CSV paths, source URLs, and dates.
- Do not mix current fundamentals into historical backtests as if they were point-in-time.
- For latest news, include article/source timestamp and whether the item arrived before or after market close.
- For upcoming earnings, note the date source and whether it is confirmed or inferred.
- For funds/ETF holdings, distinguish current exposure from historical ownership.

## Browser/Web Use

Use Browser or web search when:

- The user asks about “latest”, “today”, “upcoming”, “current news”, “earnings call”, “fund holdings”, or current company events.
- `signal-cli` output is stale, ambiguous, or missing context.
- You need source-level confirmation from company IR, SEC, Yahoo Finance pages, ETF issuer pages, or reputable news pages.

When Browser evidence conflicts with `signal-cli`, trust the more direct/current source and state the discrepancy.

## Output Shape

Prefer:

```text
View:
Evidence:
Risks:
What would change my mind:
Commands/sources:
```

Keep financial disclaimers short and practical: “This is research evidence, not financial advice.”

## Reference

Read `references/signal-cli.md` when you need exact commands, field semantics, or data caveats.
