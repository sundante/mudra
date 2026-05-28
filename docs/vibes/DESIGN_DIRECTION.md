# Mudra — Design Direction

> Where the app is heading visually. This file captures aspirational targets, screen patterns to adopt, and a log of design decisions. Update it as the product evolves.

---

## Vision

**"The richness of a premium fintech dashboard — but warmer, gold-first, and more personal."**

Reference: an 8-screen blue/purple fintech UI (shared 2026-05-27). We want the same density of information and chart variety, recoloured in the Mudra gold palette — warm white base, gold heroes, semantic green/red/amber data, no blue gradients.

Key differentiators vs the reference:
- **Gold hero gradient** instead of blue/purple — feels premium Indian finance, not generic
- **Cormorant Garamond** for large numbers — authoritative and elegant, not just bold sans
- **Warm semantic grammar** — green = good, red = bad, amber = investment — universally readable

---

## Reference Screen Patterns (to adopt)

### Screen 1 — Earning Insights
- Bar histogram of variable spend/income over time (monthly, animated on load)
- "Earning this month" display number in Cormorant
- Month-over-month comparison chip
- **Status**: not yet built — Chart Type 3 (bar chart)

### Screen 2 — Account + Net Worth Overview
- Credit card visual (gradient card with card number style)
- Net Worth below with assets/liabilities breakdown
- Timeline filter chips (1M / 3M / 6M / All)
- **Status**: partially built — net worth hero exists; card visual pending

### Screen 3 — Reports / Transfers
- Monthly grouped bar chart (income vs expense side-by-side, two colours)
- "View Transaction" CTA below chart
- Monthly budget progress bar
- **Status**: not built

### Screen 4 — Breakdown & Budget (left)
- Category donut (full ring) with % labels on segments
- Income / Expenses / Budget tab filter
- Per-category progress rows with colour-coded % bars
- **Status**: donut partially built; progress rows not built

### Screen 5 — Spending Insights
- "Spending this month" Cormorant hero number (red)
- Sparkline area chart — 4-week spend trend with area fill
- Recurring Transactions list (icon · name · amount · frequency chip)
- **Status**: not built — needs Chart Type 6 (sparkline) + new screen

### Screen 6 — Breakdown & Budget (right)
- Stacked category bar (horizontal, multi-segment)
- Category chips as filter above bars
- **Status**: not built — Chart Type 5 (stacked bar)

### Screen 7 — Income Source Breakdown
- Salary / Freelance / Rental income rows
- Horizontal progress bars per source scaled to %
- Donut on right showing allocation
- **Status**: not built — Chart Type 4 (income flow tree)

### Screen 8 — Quick Actions
- 2×3 grid of action tiles (icon + label + optional sublabel)
- Actions: Track Spending, Future Savings, Invest Extra, Track Score, Understand Money
- "Ask Suguna" AI assistant entry point
- **Status**: not built

---

## Chart Roadmap

| # | Type | Use case | Status |
|---|------|----------|--------|
| 1 | Semi-donut (half ring) | Asset allocation | ✅ Built (`AssetAllocationDonut`) |
| 2 | Fuel gauge ring (240°) | Month runway | ✅ Built (`FuelGaugeRing`) |
| 3 | Monthly bar chart | Spend / income trends | ⬜ Pending |
| 4 | Income flow tree | Income source breakdown | ⬜ Pending |
| 5 | Stacked horizontal bar | Budget split | ⬜ Pending |
| 6 | Sparkline (area fill) | Net worth / spend trend | ⬜ Pending |
| 7 | Full donut (55% hole) | Category breakdown | ✅ Built (same widget, full ring mode) |
| 8 | Progress rows | Budget vs actual per category | ⬜ Pending |

---

## Screen Roadmap

| Screen | Description | Status |
|--------|-------------|--------|
| Spending Insights | Dedicated spend tracking screen with sparkline + category breakdown | ⬜ Pending |
| Reports / Transfers | Monthly bar chart + transaction history | ⬜ Pending |
| Quick Actions | 2×3 grid of shortcuts from home screen | ⬜ Pending |
| Budget Categories | Per-category progress bars + spend limits | ⬜ Pending |

---

## Design Decisions Log

| Date | Decision |
|------|----------|
| 2026-05-27 | Switched app background from cream `#FAF8F4` to pure white `#FFFFFF` — aligns with design system doc rule, matches premium white-base reference app |
| 2026-05-27 | Established design principles storage: hard rules in `CLAUDE.md`, direction in this file, visual master in `mudra_design_system.html` |
| 2026-05-27 | Added asset allocation donut to Dashboard (Overall), Net, and Investments screens |
| 2026-05-27 | Added timeline filter bar (1M/3M/6M/1Y/All) to Investments screen |
| 2026-05-27 | Compacted all list rows (account tiles, holding rows, outgoing rows, platform cards) |
| 2026-05-27 | Added fade page transitions (220ms) across all routes |
