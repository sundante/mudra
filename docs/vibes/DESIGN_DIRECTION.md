# Mudra — Design Direction

> Where the app is heading visually. This file captures aspirational targets, screen patterns to adopt, and a log of design decisions. Update it as the product evolves.

---

## Component Catalogue

Reference specs for every recurring UI pattern. All token names map to `AppColors` and `AppTypography` constants.

---

### 1. Greeting Header

```
Good morning,          ← IBM Plex Sans 16px w400, AppColors.inkMid
[User name].           ← Cormorant Garamond italic 22px w400, AppColors.red  (AppTypography.displayItalic, color overridden)
FRI · 23 MAY           ← IBM Plex Mono 9.5px ALL CAPS inkDim, tracked  (sectionLabel style, inkDim)
```

Currency switcher pill (top-right): dark `AppColors.ink` background pill; ₹ $ £ options in IBM Plex Mono 11px; active option = white text, inactive = `inkDim`.

---

### 2. Section Label + Count Row

Two-column header above every list section:

- **Left**: IBM Plex Mono 9.5px ALL CAPS `inkDim`, letterSpacing 1.8 — e.g. `NEXT 7 DAYS`
- **Right**: same size/tracking, `AppColors.red` — e.g. `3 DEBITS`

Use `inkDim` for neutral counts, `red` for debt/outflow counts, `amber` for investment counts.

---

### 3. Hero Tile (Home — replaces FuelGaugeRing)

Numbers-only compact tile. No arcs, rings, dials, or progress indicators.

```
┌──────────────────────────────────────┐
│  SPENDABLE THIS MONTH   ← sectionLabel, inkDim
│                                      │
│  ₹ 84,320               ← IBM Plex Mono 36px w600; green if >0, red if <0
│                                      │
│  14 days left · Projected +₹ 12,400  ← IBM Plex Sans 12px inkDim;
│                                         surplus inline green, deficit inline red
└──────────────────────────────────────┘
```

- Background: `AppColors.surface` white
- Border: 1px `AppColors.border`, 12px radius
- Padding: 20px horizontal, 18px vertical
- Max 1 per screen

---

### 4. Summary Tile (stat tiles, all screens)

Consistent spec — every paired tile must match in height and structure.

```
┌──────────────────────┐
│  ACCOUNTS            ← IBM Plex Mono 9.5px ALL CAPS inkDim
│  ₹ 2.14L             ← IBM Plex Mono ~20px w600, ink
│  +12.4K this wk      ← IBM Plex Sans 11px, semantic color
└──────────────────────┘
```

- Background tint: `greenLight` (#E8F5EE) for liquid/account tiles · `amberLight` (#FEF0E0) for investment tiles · `surfaceAlt` for neutral/net worth
- Corner radius 10px, padding 14px
- Delta row: omit if not applicable
- No gauges, bars, or progress indicators — numbers only

---

### 5. Outgoing / Debit Row

Core list cell used across Home, Radar, Spend, and Debts screens.

```
│▌ Title (IBM Plex Sans 14px w500, ink)          [Category chip]
│  DAY · DATE (mono 10px inkDim) · IN X DAYS     ₹ AMOUNT (mono 14px w500)
```

- Left accent bar: 3–4px, semantic color — red for outflow/debt, amber for investment/SIP, green for income
- Amount always right-aligned
- `IN X DAYS` only shown on upcoming/scheduled rows; omit on past transactions

---

### 6. Category Chip Pill

Small inline label attached to the row title.

| Category | Background | Text color |
|---|---|---|
| EMI / CC / Bill / Expense | `AppColors.redLight` | `AppColors.red` |
| SIP / Investment | `AppColors.amberLight` | `AppColors.amber` |
| Income / Salary | `AppColors.greenLight` | `AppColors.green` |

- Shape: 4px border radius, no border
- Font: IBM Plex Mono 9px ALL CAPS
- Padding: 2px vertical, 6px horizontal

---

### 7. Day Picker Strip (Radar screen)

Horizontal 7-column week strip.

- Each column: abbreviated day label (MON) above date number
- Active day with items: red outline pill (1.5px `AppColors.red` border), date number in `red`
- Dot indicator below date for days with scheduled items — `AppColors.red` dot
- Inactive days: plain `inkDim` text, no border
- Scroll: horizontal, snaps to selected day

---

### 8. Total Footer Card

Full-width summary card at the bottom of a list section.

- Background: `AppColors.redLight` (#FAEAE9), 12px radius
- Label: sectionLabel style — `TOTAL THIS WEEK`
- Amount: IBM Plex Mono 28px w600, `AppColors.red`
- Padding: 16px horizontal, 14px vertical

Use `amberLight` bg + `amber` text when summarising investment outflows.

---

### 9. Inline Semantic Highlighting (Morning Briefing)

Inline tinted pills within prose text to draw attention to key figures.

- Positive amounts: `greenLight` bg pill, `green` text, IBM Plex Mono
- Debt labels / category names: `redLight` bg inline highlight, `red` text
- % gains: `greenLight` pill, `green` text
- Investment amounts: `amberLight` pill, `amber` text
- All inline highlights: IBM Plex Mono, same size as surrounding text, 4px radius

---

### 10. CTA Button Variants

| Variant | Spec |
|---|---|
| Primary | Full-width, `AppColors.red` bg, white label, IBM Plex Sans 14px w600, 12px radius, 52px height |
| Secondary | Full-width, outlined (1.5px `AppColors.ink` border), white bg, `ink` label, same radius/height |

Never use gold as a CTA color.

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
- Current Home quick actions are a compact shortcut grid for financial work:
  Spending, Funds, Debts, Invests, Net Worth
- App Map is intentionally not in Quick Actions; it lives only in Profile
- "Ask Suguna" AI assistant entry point
- **Status**: partially built — shortcut grid exists; assistant entry pending

---

## Chart Roadmap

| # | Type | Use case | Status |
|---|------|----------|--------|
| 1 | Semi-donut (half ring) | Asset allocation | ✅ Built (`AssetAllocationDonut`) |
| 2 | Fuel gauge ring (240°) | Month runway | ✅ Built (`FuelGaugeRing`) |
| 3 | Monthly bar chart | Spend / income trends | ⬜ Pending |
| 4 | Flow board | App/user-flow map | ✅ Built (`MapScreen` + generated `APP_MAP.html`) |
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
| Quick Actions | Home shortcut grid for core finance destinations | ✅ Built |
| Profile Settings | Identity-first profile page with app map/account actions; finance settings deferred | ✅ Built |
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
| 2026-05-28 | Rebuilt App Map as a compact horizontal flow board with shared JSON source and generated HTML map |
| 2026-05-28 | Profile simplified to identity/navigation/account/data actions; income, pay date, and currency removed from Profile |
| 2026-05-28 | Home This Month now leads with the fuel gauge only; the gold Month Runway hero was removed and gauge colour is value-based (0 grey, positive green, negative red) |
| 2026-05-30 | Color grammar sharpened: Red `#A83226` is now primary brand signal AND semantic outflow color (active nav, CTAs, brand italic text, debit rows). Gold `#8A6520` retired from UI — hero gradient only. Amber = promises (future investment commitments). Green = surplus/income |
| 2026-05-30 | Fuel gauge ring replaced with compact hero tile on Home — numbers only (spendable + days left + projected month-end surplus/deficit); no arcs, rings, or dials anywhere in the app |
| 2026-05-30 | Section labels switched from gold to `inkDim` — neutral mono label; count on right stays red |
| 2026-05-30 | Component Catalogue added to this file — 10 component specs with exact token references for row anatomy, tiles, chips, day picker, footer card, briefing highlights, and CTA buttons |
