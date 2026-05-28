# Mudra — User Flow

> Maps every screen, tab, and action currently implemented in the app.
> Financial routes are protected by Supabase authentication; authenticated
> records are local to the current user's Isar store.

---

## Top-Level Flow

```
Splash Screen
    └── Auth Session Gate
            ├── Signed out ──► Welcome Screen
            │       ├── Create account ──► Register ──► Verify Email Link
            │       ├── Log in ──► Email / Google / Apple (iOS)
            │       └── Forgot Password ──► Reset Link ──► New Password
            │
            └── Verified account
                    ├── Legacy data found ──► Attach Existing Data / Start Fresh
                    ├── Setup incomplete ──► Setup Welcome
                    └── Setup complete ──► Protected Financial Shell
                            ├── Home        (Dashboard)
                            ├── Funds       (Accounts)
                            ├── Debts       (Debts & I Owe)
                            ├── Invests     (Investments)
                            └── Net         (Net Worth)
```

---

## 0. Authentication And Setup Entry

```
Welcome Screen
    ├── [Create account]
    │       └── Full name · Email · Password · Confirm password · Consent
    │               └── Email confirmation link → mudra://auth/callback
    ├── [Log in]
    │       ├── Email + Password
    │       ├── Google  (iOS + Android)
    │       ├── Apple   (iOS only)
    │       └── Forgot password → mudra://auth/reset-password
    └── Protected routes redirect here while signed out

After Authentication
    ├── Existing legacy local records → Attach / Start Fresh choice
    └── New account → Setup Welcome  (financial setup follows in next story)
```

---

## 1. Home — Dashboard Screen *(protected)*

### 1.1 This Month Tab *(default)*

```
Dashboard → This Month
    ├── Sticky Date Header
    │       └── [Tap Calendar Icon] → Date Picker (simulation day, current month only)
    │
    ├── Fuel Gauge Ring
    │       └── Visual spend-vs-budget arc; updates with simulation day
    │
    ├── Day Slider  (Day 1–31, locked to current month)
    │       └── Drag to simulate balance on any day
    │
    ├── Liquid / Balance Row
    │       └── Opening liquid | Current balance
    │
    ├── Runway Table  (4 collapsible sections)
    │       ├── Opening Cash     → tap to expand → account rows
    │       ├── Credits          → tap to expand → received + upcoming credit rows
    │       ├── Debits           → tap to expand → category groups + items
    │       └── Commitments      → tap to expand → CC outstanding + future debits
    │
    ├── Until End of Month  (radar — upcoming debits within 7 days)
    │       └── Each radar item: name · type · amount · urgency chip
    │
    └── FAB  [+]
            └── Quick Spend Sheet
                    ├── Amount field
                    ├── Category chips (Food / Travel / Shopping / Bills / Health / Other)
                    ├── Optional note
                    ├── Date picker (current month only)
                    └── [Save] → creates VariableExpense; updates Debits table
```

### 1.2 Overall Tab

```
Dashboard → Overall
    ├── Net Worth Hero  (tap → navigates to Net screen)
    │
    ├── Asset Allocation Donut
    │       ├── Segments: Liquid Cash · Fixed Deposits · Investments
    │       └── Tap segment → shows value; default shows percentage
    │
    ├── Stat Tiles Row
    │       ├── ASSETS   (tap → Funds screen)
    │       ├── INVESTED (tap → Investments screen)
    │       └── LIABILITIES (tap → Investments screen)
    │
    └── Breakdown Rows
            ├── Assets: Liquid Cash · Fixed Deposits · Investments
            └── Liabilities: Total Owed
```

---

## 2. Funds — Accounts Screen

```
Funds Screen
    ├── Account List  (Personal / Credit / Savings — segmented or filtered)
    │       └── AccountTile per account
    │               ├── Nickname · Bank · Category
    │               ├── LIQUID badge  (if included in liquid calculation)
    │               ├── Balance row   (tap balance → Quick Balance Update sheet)
    │               └── FD Amount row (if > 0)
    │
    ├── Swipe Left on tile → Delete account (with confirmation)
    │
    ├── Tap tile → Edit Account Sheet
    │       ├── Nickname · Bank Name
    │       ├── Account Type  (Personal / Credit Card / Savings)
    │       ├── Balance · FD Amount
    │       ├── Include in Liquid toggle
    │       └── [Save] / [Delete]
    │
    └── FAB  [+]  → Add Account Sheet  (same form as Edit, blank)

Quick Balance Update Sheet  (from tap on balance row)
    ├── Amount field  (pre-filled with current balance)
    └── [Update] → saves new balance to account
```

---

## 3. Debts — Debts Screen

```
Debts Screen
    ├── Upcoming in 7 Days strip + Total Committed card
    │
    ├── Fixed commitment groups
    │       └── Loans & EMIs · Insurance & Premiums · Subscriptions
    │           Utilities & Bills · Investments (SIPs) · Family & Personal
    │
    ├── Variable Spent group
    │       └── Current-month quick-spend rows, newest first
    │               └── Swipe Left → confirmation → delete
    │
    ├── Personal Debts — Add Debt action
    │       ├── I OWE group
    │       └── OWED TO ME group
    │               ├── Active debt row: tap edit · swipe right settle · swipe left delete
    │               └── SETTLED group: collapsed and dimmed; tap edit · swipe left delete
    │
    ├── Add Debt Sheet
            ├── Counterparty name
            ├── Amount
            ├── Direction toggle  (I Owe / They Owe)
            ├── Due Date picker (optional)
            ├── Notes (optional)
            └── [Save]
    │
    └── FAB  [+]  → Add fixed commitment sheet
```

---

## 4. Invests — Investments Screen

```
Investments Screen
    ├── Net Worth Hero  (tap → navigates to Net screen)
    │
    ├── Platform Filter Bar  (horizontal scroll chips)
    │       └── [All] · [Platform Name] · ...
    │               └── Tap chip → filters holdings below to that platform
    │
    ├── Timeline Filter Bar
    │       └── 1M · 3M · 6M · 1Y · All
    │               └── Filters holdings by createdAt date
    │
    ├── Asset Allocation Donut  (when holdings exist)
    │       ├── Segments per AssetType (Mutual Fund · Indian Stocks · US Stocks · PPF · EPF · NPS · Gold · Other)
    │       └── Tap segment → shows value; default shows percentage
    │
    ├── Holdings — grouped by Asset Type  (one ExpansionTile per type)
    │       └── AssetType Group  (e.g., MUTUAL FUNDS — ₹X.XX L)
    │               └── HoldingRow per holding
    │                       ├── Scheme name · Platform badge · Invested amount
    │                       ├── Current value · P&L chip (green/red %)
    │                       ├── Tap row → Edit Holding Sheet
    │                       └── Swipe Left → Delete holding
    │
    ├── Platform Summary Section
    │       └── PlatformCard per platform
    │               ├── Platform name · Asset type badge
    │               ├── Invested / Current values · P&L chip
    │               ├── Tap card → Edit Platform Sheet
    │               └── Swipe Left → Delete platform
    │
    └── FAB  [+]  → Add Choice Sheet
            ├── [Add Holding / Scheme]
            │       └── Holding Editor Sheet
            │               ├── Scheme name
            │               ├── Platform picker chips  (from existing platforms)
            │               ├── Asset type chips
            │               ├── Invested Amount · Current Value
            │               ├── Units  (optional)
            │               └── [Save] / [Delete]
            └── [Add Platform]
                    └── Platform Editor Sheet
                            ├── Platform name
                            ├── Asset type chips
                            ├── Invested Amount · Current Value
                            └── [Save] / [Delete]
```

---

## 5. Net — Net Worth Screen

```
Net Worth Screen
    ├── Net Worth Hero  ("Your Net Worth" + positive/negative label)
    │
    ├── Asset Allocation Donut
    │       └── Liquid Cash · Fixed Deposits · Investments
    │
    ├── Formula Card
    │       └── Assets  −  Liabilities  =  Net Worth
    │
    └── Expandable Sections
            ├── MONEY IN BANKS
            │       ├── Liquid Accounts  → account rows (name · bank · balance)
            │       └── Fixed Deposits   → account rows (name · FD amount)
            │
            ├── INVESTMENTS
            │       └── PlatformCard per platform  (read-only view)
            │
            ├── CC OUTSTANDING
            │       └── Credit card account rows (name · bank · balance)
            │
            ├── LOANS & I OWE
            │       ├── Personal debts  (counterparty · due date · amount)
            │       └── Committed this month (active outgoings due ≤ today)
            │
            └── OWED TO ME  (only shown when entries exist)
                    └── Debt rows (counterparty · due date · amount)
```

---

## 6. Profile Screen

```
Profile Screen  (accessible via profile icon in app bar on all protected tabs)
    ├── User Name  (display name, used for initials avatar)
    ├── Base Currency  (7 options: INR · USD · EUR · GBP · JPY · AED · SGD)
    ├── Pay Date  (grid 1–31, day salary/income is expected)
    ├── App Map
    ├── [Sign Out]  → closes current user store → Welcome
    │
    └── Danger Zone
            └── [Clear All Data]  (double-confirmation dialog → wipes current user store)
```

---

## Cross-Screen Navigation Map

```
                        ┌─────────────────┐
                        │   App Bar       │
                        │  [Avatar] ──────┼──► Profile Screen
                        └─────────────────┘

Bottom Nav
    ┌──────┬──────────┬──────────┬──────────┬──────┐
    │ Home │  Funds   │  Debts   │ Invests  │  Net │
    └──┬───┴────┬─────┴────┬─────┴────┬─────┴──┬───┘
       │        │           │          │         │
       │        │           │          │         └── Net Worth Screen
       │        │           │          │                └── taps on heroes in other screens → here
       │        │           │          │
       │        │           │          └── Investments Screen
       │        │           │                └── Net Worth hero tap → /net
       │        │           │
       │        │           └── Debts Screen
       │        │
       │        └── Funds Screen
       │
       └── Dashboard Screen
               ├── Overall tab: Net Worth tap → /net
               ├── Overall tab: ASSETS tile → /accounts
               ├── Overall tab: INVESTED tile → /portfolio
               └── This Month: FAB → Quick Spend Sheet
```

---

## Data Flow Summary

| Screen | Reads from | Writes to |
|--------|-----------|-----------|
| Authentication | Supabase session, active user-store readiness | session lifecycle, password recovery, sign-out |
| Dashboard | accounts, outgoings, credits, variableExpenses, platforms, debts, appSettings | variableExpenses (Quick Spend) |
| Funds | accounts, appSettings | accounts |
| Debts | debts, appSettings | debts |
| Investments | investmentHoldings, investmentPlatforms, appSettings | investmentHoldings, investmentPlatforms |
| Net Worth | accounts, platforms, debts, outgoings, appSettings | — (read-only) |
| Profile | appSettings | appSettings |

---

## Feature Status

| Feature | Screen | Status |
|---------|--------|--------|
| Day simulation slider | Home → This Month | ✅ Live |
| Fuel gauge ring | Home → This Month | ✅ Live |
| Quick spend logging | Home → This Month (FAB) | ✅ Live |
| Runway table (4 sections) | Home → This Month | ✅ Live |
| Net worth + asset breakdown | Home → Overall | ✅ Live |
| Asset allocation donut | Home → Overall, Net, Investments | ✅ Live |
| Account management | Funds | ✅ Live |
| Quick balance update | Funds | ✅ Live |
| Debt tracking (I Owe / Owed To Me) | Debts | ✅ Live |
| Debt settlement | Debts | ✅ Live |
| Investment holdings (by scheme) | Investments | ✅ Live |
| Platform filter chips | Investments | ✅ Live |
| Timeline filter (1M–1Y) | Investments | ✅ Live |
| Asset type donut | Investments | ✅ Live |
| Net worth formula + breakdown | Net | ✅ Live |
| User name + currency + pay date | Profile | ✅ Live |
| Clear all data | Profile | ✅ Live |
| First-launch authentication gate | Welcome / Auth / Setup | ✅ Code complete; provider/device verification pending |
| Per-user local financial storage | App session / Database | ✅ Code complete; migration device verification pending |
| Page fade transitions | All screens | ✅ Live |
