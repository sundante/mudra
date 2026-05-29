# Mudra — Product & Data Reference
**Flutter MVP · Authenticated Local-first · Supabase Identity · Device-local Finances**
Version 2.0 · May 2026

> Build status and feature inventory: `docs/STATUS.md`
> Architecture, conventions, and agent rules: `CLAUDE.md`
> This file contains the product-level reference that isn't derivable from code: data model field definitions, DashboardData formulas, design grammar, user stories, and edge cases.

---

## Design System Grammar

### Colour Grammar

- Surplus / income / positive balance → `AppColors.green` (#1E6B44)
- Outflows / brand primary / negative amounts / debt → `AppColors.red` (#A83226) — active nav, CTAs, brand italic text, debit accent bars
- Promises / investments / SIPs not yet executed → `AppColors.amber` (#9A5510)
- Hero gradient only (never UI text, CTAs, or labels) → `AppColors.gold` (#8A6520)
- Negative amounts always red regardless of row type
- Background → `AppColors.background` (#FFFFFF) — pure white across scaffolds
- Section labels → `AppColors.inkDim` (#8C8480) — IBM Plex Mono 9.5px ALL CAPS; count label on right uses same style in red
- Dashboard projected month end → `AppColors.green` when > 0, `AppColors.inkDim` at 0, `AppColors.red` when < 0

### Typography Grammar
- **Hero numbers / display headings** → Cormorant Garamond (`AppTypography.displayLarge` etc.)
- **All UI text** → IBM Plex Sans (`AppTypography.bodyLarge` etc.)
- **ALL currency amounts** → IBM Plex Mono (`AppTypography.monoMedium` etc.) — **zero exceptions**
- **Section labels** → IBM Plex Mono, 9.5px, 1.8 letterSpacing, ALL CAPS, `AppColors.inkDim`
- **Font loading** → All three families are bundled as local assets (`assets/fonts/`). `google_fonts` package is kept but `allowRuntimeFetching = false` — zero CDN calls at runtime.

### Interaction Grammar
- Save / create → `HapticFeedback.lightImpact()`
- Delete → `HapticFeedback.mediumImpact()`
- Balance updated → `HapticFeedback.mediumImpact()`
- Error / validation fail → `HapticFeedback.vibrate()`
- Loading → skeleton shimmer, never a spinner on content areas

---

## Data Models

### Account
```
id, uid, nickname, bankName
accountType: personal | joint | business
isCreditCard, balance, fdAmount
includeInLiquid, balanceUpdatedAt, sortOrder, isDeleted, createdAt
```

### Outgoing
```
id, uid, name
outgoingType: expense | investment
category: loan | insurance | utility | subscription | sip | ppf | epf | nps | other
amount, debitDate (1–31), isActive, createdAt
```

### InvestmentPlatform
```
id, uid, platformName
assetType: indianStocks | usStocks | mutualFund | ppf | epf | nps | gold | other
investedAmount, currentValue, valueUpdatedAt, isDeleted, createdAt
```

### Debt
```
id, uid, counterpartyName
direction: iOwe | theyOwe
amount, dueDate?, notes?, isSettled, createdAt
```

### Credit
```
id, uid, name, amount, creditDate (1–31), isActive, createdAt
```

### AppSettings (singleton, id=1)
```
baseCurrency, monthlyIncome, payDate (1–31), userName, hasCompletedSetup
```
> Profile currently exposes only `userName`, App Map, sign-out, and local data
> actions. Finance settings remain in `AppSettings` for setup/dashboard logic,
> but are not shown on the Profile page.

### VariableExpense
```
id, uid, amount
category: food | transport | shopping | health | entertainment | misc
note?, spentAt (DateTime), createdAt
```

---

## Key Computed Values (DashboardData)

```
liquidTotal                = SUM(balance) WHERE personal + includeInLiquid + NOT creditCard
fdTotal                    = SUM(fdAmount) across ALL accounts
ccOutstanding              = SUM(balance) WHERE isCreditCard
creditsReceivedToDay       = SUM(credits WHERE creditDate <= selectedDay AND isActive)
debitsFiredToDay           = SUM(outgoings WHERE debitDate <= selectedDay AND isActive)
remainingCommittedAfterDay = SUM(outgoings WHERE debitDate > selectedDay AND isActive)
openingLiquidBalance       = liquidTotal - creditsReceivedToDay + debitsFiredToDay
variableSpentToDay         = SUM(variableExpenses WHERE spentAt.day <= selectedDay, current month)
simulatedBalanceOnDay      = openingLiquidBalance + creditsReceivedToDay - debitsFiredToDay - variableSpentToDay
projectedMonthEnd          = simulatedBalanceOnDay - remainingCommittedAfterDay - ccOutstanding
dayBalancePercent          = (simulatedBalanceOnDay / openingLiquidBalance * 100).clamp(0, 100)
gaugeColor                 = projectedMonthEnd > 0 ? green : projectedMonthEnd < 0 ? red : grey
investmentsTotal           = SUM(platform.currentValue)
totalAssets                = liquidTotal + fdTotal + investmentsTotal
debtsIOwe                  = SUM(debt.amount WHERE iOwe + !settled)
totalLiabilities           = ccOutstanding + debtsIOwe
netWorth                   = totalAssets - totalLiabilities
debitRadar                 = outgoings due later this month, sorted by debitDate
```

---

## User Stories

### Authentication Foundation
| # | Story | Status |
|---|---|---|
| US-001 | First launch authentication and account entry: Welcome, Supabase registration/login, email verification, password reset, social sign-in, per-user local data, setup handoff | Implemented; live provider/device verification pending |
| US-002 | Guest mode and guided onboarding: "Use as Guest" entry, ephemeral demo data (Rohan profile), DEMO MODE banner, 5-step guided tour overlay, handoff screen, 3-step setup wizard for new users | Router bug fixed; in verification |

### P0 — Must Ship
| # | Story | Screen |
|---|---|---|
| US-01 | Add a bank account with name, balance, type | Funds |
| US-02 | Update an account balance quickly | Funds |
| US-03 | See total liquid balance across personal accounts | Dashboard |
| US-04 | Add a fixed monthly expense with debit date | Debits |
| US-05 | Add a fixed monthly investment (SIP, PPF) with debit date | Debits |
| US-06 | See BalanceForTheMonth — what I can actually spend | Dashboard |
| US-07 | See which debits are still coming this month | Dashboard |
| US-08 | Set monthly income to anchor the fuel gauge | Onboarding / future settings |

### P1 — Strong MVP
| # | Story |
|---|---|
| US-09 | Add investment platforms with invested + current value |
| US-10 | See net worth (assets − liabilities) |
| US-11 | Add personal debts (what I owe, what others owe me) |
| US-12 | Delete / edit any account, outgoing, or investment |
| US-13 | Choose base currency (INR/USD/GBP/AED/SGD/AUD/EUR) in setup/future settings |

All P0 and P1 finance stories are implemented. US-001 introduces the
authenticated entry gate before those protected experiences.

---

## Edge Cases

| Case | Implemented behaviour |
|---|---|
| `liquidTotal == 0` | Fuel gauge shows 0%, no divide-by-zero |
| `projectedMonthEnd == 0` | Gauge amount and slider accents are grey |
| `projectedMonthEnd > 0` | Gauge amount and slider accents are green |
| `projectedMonthEnd < 0` | Gauge amount and slider accents are red |
| No outgoings | `fixedCommitted = 0`, gauge full |
| Very large numbers (₹ 10 Cr) | Compact lakh/crore formatting, no overflow |
| Empty debit radar | "All clear" empty state |
| Fresh install | Welcome/authentication gate; after verification an empty private user store routes to setup welcome |
| Existing local-only install | After login, user chooses to attach legacy data to their private store or start fresh |
| Signed-out protected route | Redirected to Welcome; no financial database is opened |
| DB hydration crash | Recovery bootstrap applies to the authenticated user's private Isar store |

---

---

## Dev Build & Security

### Running in Dev Mode (no backend required)
```bash
# No --dart-define flags needed — Supabase is skipped, dev bypass is active
flutter run -d <device-id>
```
On the Welcome screen (debug build only):
- **Dev: Skip auth** — opens a local `mudra_user_developer` Isar DB, bypasses Supabase entirely
- **Dev Tools** — opens the data management screen

### Dev Tools Screen (`/dev-tools`)
Accessible via the "Dev Tools" link on the Welcome screen. Debug builds only.
- Shows dev DB name, file status, and per-collection record counts
- **Open dev DB** — signs in as developer and opens the dashboard
- **Clear all data** — wipes all collections with confirmation (keeps the DB file)
- **Delete DB + reset** — permanently removes the `.isar` file and returns to Welcome

### Security Posture (dev build)
| Concern | Status |
|---|---|
| Phone data access (contacts, camera, location, mic) | Not declared — impossible |
| Outbound network from app code | Zero — fonts bundled, Supabase skipped, social buttons hidden |
| iCloud backup of Isar DB | Excluded — using `getApplicationSupportDirectory()` |
| Hardcoded secrets | None — all `--dart-define` injected |
| Debug bypass in release builds | Not possible — `kDebugMode` only |

### Deferred to Production Hardening
- Database encryption at rest (Isar v3 limitation)
- Certificate pinning for Supabase connections
- Session timeout policies
- Biometric unlock

---

*Build status and feature inventory: `docs/STATUS.md`*
*Conventions and agent rules: `CLAUDE.md`*
