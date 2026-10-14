# signal-cli Reference

Use from `~/dev/signals/packages/python` unless a caller supplies another path.

## Commands

```sh
uv run signal-cli --help
uv run signal-cli analyze AAPL MSFT NVDA --period 1y --top 10 --out runs/<slug>
uv run signal-cli regime --period 1y
uv run signal-cli fundamentals AAPL MSFT NVDA
uv run signal-cli collect-news AAPL NVDA --out runs/<slug>/news.csv
```

Root repo equivalents:

```sh
bun run py
bun run py:check
bun run py:test
```

## Output Semantics

Setup labels are evidence states, not trading instructions:

- `constructive_setup`: measured evidence is broadly favorable.
- `watch_setup`: evidence is mixed or a technical gate blocks confidence.
- `risk_setup`: measured evidence is materially unfavorable.

Important fields:

- `market_regime`, `market_regime_score`, `market_notes`
- `fundamental_health`, `fundamental_score`, `fundamental_notes`, `fundamental_risks`
- `ret_5d`, `ret_20d`, `momentum_20d_vs_benchmark`, `rsi_14`, `volume_z`
- `target_upside`, `recommendation_mean`
- `fund_count`, `fund_weight_total`, `funds`
- `reasons`, `risk_flags`

## Data Caveats

- yfinance price history is useful for research, but Yahoo data can revise or fail.
- yfinance news is a current snapshot, not full historical point-in-time news.
- yfinance fundamentals and analyst snapshots are current-state data; do not use them as historical labels.
- Treat generated CSVs under `runs/` as disposable evidence unless the user asks to preserve them.

