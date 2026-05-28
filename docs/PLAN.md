# Mudra — Product & Data Reference
**Flutter MVP · Authenticated Local-first · Supabase Identity · Device-local Finances**
Version 2.0 · May 2026

> Build status and feature inventory: `docs/STATUS.md`
> Architecture, conventions, and agent rules: `CLAUDE.md`
> This file contains the product-level reference that isn't derivable from code: data model field definitions, DashboardData formulas, design grammar, user stories, and edge cases.

---

## Design System Grammar

### Colour Grammar
- Positive / income → `AppColors.green` (#1E6B44)
- Expense / negative / debt → `AppColors.red` (#A83226)
- Investment / neutral → `AppColors.amber` (#9A5510)
- Primary CTA / accent → `AppColors.gold` (#8A6520)
- Background → `AppColors.background` (#FFFFFF) — pure white across scaffolds

### Typography Grammar
- **Hero numbers / display headings** → Cormorant Garamond (`AppTypography.displayLarge` etc.)
- **All UI text** → IBM Plex Sans (`AppTypography.bodyLarge` etc.)
- **ALL currency amounts** → IBM Plex Mono (`AppTypography.monoMedium` etc.) — **zero exceptions**
- **Section labels** → IBM Plex Mono, 9.5px, 1.8 letterSpacing, ALL CAPS, `AppColors.inkDim`

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
| US-08 | Set monthly income to anchor the fuel gauge | Settings |

### P1 — Strong MVP
| # | Story |
|---|---|
| US-09 | Add investment platforms with invested + current value |
| US-10 | See net worth (assets − liabilities) |
| US-11 | Add personal debts (what I owe, what others owe me) |
| US-12 | Delete / edit any account, outgoing, or investment |
| US-13 | Choose base currency (INR/USD/GBP/AED/SGD/AUD/EUR) |

All P0 and P1 finance stories are implemented. US-001 introduces the
authenticated entry gate before those protected experiences.

---

## Edge Cases

| Case | Implemented behaviour |
|---|---|
| `liquidTotal == 0` | Fuel gauge shows 0%, no divide-by-zero |
| `balanceForMonth < 0` | Gauge shows 0%, amount displayed in red |
| No outgoings | `fixedCommitted = 0`, gauge full |
| Very large numbers (₹ 10 Cr) | Compact lakh/crore formatting, no overflow |
| Empty debit radar | "All clear" empty state |
| Fresh install | Welcome/authentication gate; after verification an empty private user store routes to setup welcome |
| Existing local-only install | After login, user chooses to attach legacy data to their private store or start fresh |
| Signed-out protected route | Redirected to Welcome; no financial database is opened |
| DB hydration crash | Recovery bootstrap applies to the authenticated user's private Isar store |

---

*Build status and feature inventory: `docs/STATUS.md`*
*Conventions and agent rules: `CLAUDE.md`*
