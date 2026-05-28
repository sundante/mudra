# Mudra Design System v2

> Master reference for all UI decisions. Every screen, component, and future feature must conform to this document. When in doubt, refer here first.

---

## 1. Design Philosophy

Mudra is a **professional personal finance app** for adults who take money seriously. The visual language should feel like a premium fintech tool — Bloomberg terminal meets modern mobile banking — not a cheerful consumer app.

**Core principles:**
- **Density over whitespace** — show more, scroll less. Every pixel earns its place.
- **Numbers first** — financial data is the hero. Typography carries the weight; decoration does not.
- **Restraint on colour** — white background, black text, one accent. Gold is sacred and rare.
- **No decoration for its own sake** — no gradients, no filled coloured tiles, no ornamental elements. If it doesn't carry information, remove it.
- **Honest states** — never hide bad news behind a visual that only looks good with positive numbers.

---

## 2. Colour Grammar

### Palette

| Token | Hex | Name | Role |
|---|---|---|---|
| `AppColors.background` | `#FFFFFF` | Pure White | Screen background — always |
| `AppColors.surface` | `#FFFFFF` | White | Card background — always |
| `AppColors.border` | `#E6E2DA` | Warm Grey | Card borders, dividers |
| `AppColors.ink` | `#1A1714` | Near Black | Primary text |
| `AppColors.inkMid` | `#4A4642` | Dark Grey | Secondary text, subheadings |
| `AppColors.inkDim` | `#8C8480` | Mid Grey | Tertiary text, placeholders, dates |
| `AppColors.gold` | `#8A6520` | Brand Gold | Accents only — see Gold Rules |
| `AppColors.goldLight` | `#F5EDD9` | Gold Wash | Section label bg when needed |
| `AppColors.green` | `#1E6B44` | Forest Green | Income, positive balance, assets |
| `AppColors.greenLight` | `#E8F5EE` | Green Wash | Green badge background |
| `AppColors.red` | `#A83226` | Deep Red | Expense, debt, negative runway |
| `AppColors.redLight` | `#FAEAE9` | Red Wash | Red badge background, swipe delete |
| `AppColors.amber` | `#9A5510` | Amber | Investments, FD, committed items |
| `AppColors.amberLight` | `#FEF0E0` | Amber Wash | Amber badge background |
| `AppColors.blue` | `#1A5F8A` | Navy Blue | Info, fixed deposits (secondary) |
| `AppColors.blueLight` | `#E6F2FA` | Blue Wash | Blue badge background |

### Colour Rules (non-negotiable)

- **Background is always `#FFFFFF`** — no cream, no warm tints, no surface variations on screens
- **Green = income / positive / assets only** — never decorative
- **Red = expense / debt / negative only** — never decorative
- **Amber = investment / committed / FD only** — never decorative
- **Gold = brand accent only** — see Gold Rules section below
- **Colour washes** (`*Light` variants) are used only as badge/chip backgrounds, never as card fill

---

## 3. Gold Rules

Gold (`#8A6520`) is the single brand accent. Overuse destroys its signal.

**Allowed uses:**
1. App wordmark / logo
2. Active bottom nav icon + label
3. Active `TabBar` indicator + selected tab label
4. `SectionLabel` text (the ALL CAPS mono labels)
5. Primary number on the Home projection block (this month's key figure)
6. Left border stripe (3px) on `MudraCard.primary` — the most important card per screen
7. Gold border on any card in its focused/tapped state
8. FAB (floating action button) background — centered in nav bar
9. Outlined button foreground when it is the primary CTA on a screen

**Banned uses:**
- Card fill / background colour
- Tile background colour
- Text on body copy or subheadings
- List row accents or left borders on individual rows (use coloured dot instead)
- Any decorative graphic, icon, or illustration

---

## 4. Typography Scale

### Families

| Family | Usage |
|---|---|
| **Cormorant Garamond** | Hero numbers, screen headings, display figures |
| **IBM Plex Sans** | All UI text — labels, body, buttons, descriptions |
| **IBM Plex Mono** | Every currency amount without exception, section labels, codes |

### Scale (v2 — compact)

| Token | Family | Size | Weight | Line Height | Use |
|---|---|---|---|---|---|
| `displayLarge` | Cormorant | 64 | 600 | — | Rare large hero number |
| `displayMedium` | Cormorant | 48 | 600 | — | Hero card primary number |
| `displaySmall` | Cormorant | 36 | 600 | — | Screen-level key number |
| `headingLarge` | Cormorant | 28 | 600 | — | Screen title (large) |
| `headingMedium` | Cormorant | 22 | 600 | — | Screen title, app bar |
| `headingSmall` | Cormorant | 18 | 600 | — | Month label, card heading |
| `bodyLarge` | IBM Plex Sans | 14 | 400 | 1.6 | Primary body text |
| `bodyMedium` | IBM Plex Sans | 13 | 400 | 1.6 | Secondary body, tile names |
| `bodySmall` | IBM Plex Sans | 11 | 400 | — | Dates, subtitles, hints |
| `labelLarge` | IBM Plex Sans | 13 | 600 | — | Button text, emphasis |
| `labelMedium` | IBM Plex Sans | 12 | 500 | — | Tab labels, filter chips |
| `labelSmall` | IBM Plex Sans | 10 | 500 | — | Micro labels, nav labels |
| `monoHero` | IBM Plex Mono | 48 | 600 | — | Net worth hero |
| `monoLarge` | IBM Plex Mono | 28 | 600 | — | Account balance, large amount |
| `monoMedium` | IBM Plex Mono | 14 | 500 | — | Card total, section total |
| `monoSmall` | IBM Plex Mono | 12 | 400 | — | Row amount, list item value |
| `monoXSmall` | IBM Plex Mono | 9.5 | 400 | — | Badge text, small chips |
| `sectionLabel` | IBM Plex Mono | 9.5 | 400 | — | ALL CAPS section labels |

**Currency amounts use IBM Plex Mono on every surface — no exceptions.**

---

## 5. Spacing System

### Constants (`lib/core/constants/spacing.dart`)

| Token | Value | Use |
|---|---|---|
| `AppSpacing.xs` | 4px | Inline gap, icon-to-text |
| `AppSpacing.sm` | 8px | Between rows in a card, between cards |
| `AppSpacing.md` | 16px | Internal section gap, between components |
| `AppSpacing.lg` | 24px | Between major sections |
| `AppSpacing.xl` | 32px | Screen-level section breaks |
| `AppSpacing.xxl` | 48px | Bottom scroll padding |
| `AppSpacing.screenH` | 16px | Horizontal screen margin |
| `AppSpacing.screenV` | 16px | Top scroll padding |
| `AppSpacing.cardPad` | 12px | Default card inner padding |

### Card Padding Rules

- **Standard card inner padding**: 12px all sides (`AppSpacing.cardPad`)
- **Tile row vertical padding**: 8px top + 8px bottom
- **Between cards in a list**: `SizedBox(height: 8)` — `AppSpacing.sm`
- **Between major sections**: `SizedBox(height: 16)` — `AppSpacing.md`
- **Screen top/bottom scroll inset**: 16px top, 72px bottom (clears FAB)

---

## 6. Component Catalog

### MudraCard variants

All cards: white background, rounded corners (`AppRadius.md` = 10px), no shadow.

| Variant | Border | Left Accent | Padding | Use |
|---|---|---|---|---|
| `MudraCard()` | 1px `AppColors.border` | none | 12px | Standard content card |
| `MudraCard.stat()` | 1px `AppColors.border` | none | 12px | Stat grid cell (side-by-side) |
| `MudraCard.primary()` | 1px `AppColors.border` | 3px `AppColors.gold` | 12px | Most important card on screen |
| On tap (any) | 1px `AppColors.gold` | — | — | Focus/active state |

**Never** use a coloured fill as card background. Cards are always white.

### SectionLabel

- Font: IBM Plex Mono, 9.5px, weight 400
- Letter spacing: 1.8
- Color: `AppColors.gold` (v2 — was inkDim)
- Text: ALWAYS uppercase — enforced via `toUpperCase()` in widget

```dart
SectionLabel('cash in hand')  // renders as: CASH IN HAND
```

### AmountDisplay

- Font: IBM Plex Mono (always)
- Color: `AppColors.ink` by default; pass `coloured: true` to use green/red semantics
- Positive → `AppColors.green`, Negative → `AppColors.red`, Zero → `AppColors.inkDim`

### Badge / Chip

Small pill label for category tags, status indicators.

```
background: *Light colour  (e.g. AppColors.greenLight)
text: semantic colour       (e.g. AppColors.green)
font: monoXSmall (9.5px, weight 600)
padding: horizontal 8px, vertical 4px
radius: AppRadius.full
```

### OutgoingRow

- No left border accent
- 6×6px coloured dot prefix before name text
- Vertical padding: 8px (compact)
- Amount: `monoSmall`, coloured by category

### ProjectionBlock (Home screen hero replacement)

Replaces the fuel gauge. A `MudraCard.primary` with:

```
┌─ 3px gold left border ──────────────────────┐
│  PROJECTED MONTH END          [section label] │
│  ₹ 9,500                      [displaySmall]  │
│  green if positive · red if negative          │
│  23 days remaining · May 2026  [bodySmall]    │
└──────────────────────────────────────────────┘
```

Colour logic: `projectedMonthEnd >= 0 ? AppColors.green : AppColors.red`

---

## 7. Screen Layouts

### Home (Dashboard)

```
AppBar: "Mudra" wordmark (gold) + profile icon
TabBar: "This Month" | "Overall"  (gold active indicator)

── This Month ──────────────────────────────────
[ProjectionBlock — MudraCard.primary]
  PROJECTED MONTH END
  ₹ X,XXX  (green or red)
  N days remaining · Month Year

[Row of 3 MudraCard.stat]
  NET WORTH | COMMITTED | ACCOUNTS

[MudraCard] Cash section
[MudraCard] Credits section
[MudraCard] Debits section
[MudraCard.primary] Results — Balance on Day / Month End

── Overall ─────────────────────────────────────
[MudraCard] Stat tiles (income vs expense totals)
[AssetAllocationDonut inside MudraCard]
[Breakdown rows — no dividers, 8px gap]
```

### Funds

```
AppBar: "Funds"
[Row: MudraCard.stat(LIQUID) | MudraCard.stat(FIXED DEPOSITS)]
SegmentedControl: All | Savings | CC | ...
[AccountTile list — 8px between tiles]
```

### Debts

```
AppBar: "Debts"
[MudraCard.primary — next due item + count]
[MudraCard per group — always-visible rows]
[MudraCard for variable expenses]
[MudraCard per debt counterparty]
```

### Investments

```
AppBar: "Investments"
Filter chip bar
[MudraCard wrapping AssetAllocationDonut — height 200]
[MudraCard per asset type — always-visible platform cards]
```

### Net Worth

```
AppBar: "Net Worth" (back button — not a tab)
[Flat white hero card — gold number, gold label]
[Row: MudraCard.stat(ASSETS) | operator | MudraCard.stat(LIABILITIES) | operator | MudraCard.stat(NET)]
[MudraCard.primary — highest value section]
[MudraCard — remaining sections, always visible]
```

---

## 8. Navigation Pattern

```
Bottom bar: 4 items + centered FAB
Left:  Home (house icon) · Funds (wallet icon)
Center: [+] FAB — gold circle, 56px
Right: Debts (receipt icon) · Investments (chart icon)

Active state: gold icon + gold label text
Inactive state: inkDim icon + inkDim label text

FAB action by tab:
  Home (0)   → Quick Spend sheet
  Funds (1)  → Add Account sheet
  Debts (2)  → Add Expense/Debit sheet
  Invests (3)→ Add Investment sheet
```

Net Worth is not a tab. Navigate via tapping the net worth figure on Home or Investments screens.

---

## 9. State Feedback

| State | Treatment |
|---|---|
| Tap / press | Card border → gold 1px; ripple ink |
| Loading | Shimmer on amount text (grey pulse) |
| Empty section | `EmptyState` widget: inkDim icon + message, no CTA button |
| Error | `EmptyState` with red icon + short message |
| Negative amount | `AppColors.red` text via `AmountDisplay(coloured: true)` |
| Positive amount | `AppColors.green` text via `AmountDisplay(coloured: true)` |
| Delete swipe | `AppColors.redLight` background + `Icons.delete_outline` in red |

---

## 10. Anti-Patterns (Banned)

| Pattern | Why Banned |
|---|---|
| Fuel gauge / radial visualisation | Breaks visually when runway is negative |
| Filled gold card background | Overuses the gold signal; kills its meaning |
| Gradient hero card | Decorative; inconsistent on white-heavy screens |
| Horizontal divider between rows | Cards provide separation; dividers add noise |
| `ExpansionTile` with collapsed default | Hides information; use always-visible card with "N more" |
| Left border on individual list rows | Use a coloured dot prefix instead |
| Hardcoded font sizes | Always use `AppTypography` tokens |
| `Color(0xFF...)` inline in widgets | Always use `AppColors` tokens |
| Multiple hero cards on one screen | Max 1 primary card per screen |
| `#FAF8F4` cream background | Background is pure white only |
