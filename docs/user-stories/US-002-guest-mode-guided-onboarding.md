# US-002: Guest Mode And Guided Onboarding

## User Story

As someone curious about Mudra who is not ready to create an account, I want
to explore the app with sample data and a guided tour so I can understand its
value before committing to sign-up.

## Intent

US-001 closed the app behind authentication, which is the right privacy model
for returning users but creates friction for first-time visitors. This story
adds a no-commitment entry path — "Enter as Guest" — that lets anyone explore
the app using a pre-seeded demo profile (Rohan). The guest session is
single-use and ephemeral: the demo data lives in a separate Isar store that is
not associated with any Supabase account and is never persisted between
launches.

The story ends when the guided tour concludes and the user is presented with a
cinematic handoff screen inviting them to create an account. After sign-up, a
lightweight setup wizard (each step skippable) gets them into their own blank
app.

## Scope

### In Scope

- "Use as Guest" button on WelcomeScreen, below the primary auth buttons.
- Rohan demo profile loaded into an ephemeral named Isar store (`mudra_guest`)
  on guest entry. The existing `seedDemoData` function in `seed_data.dart` is
  reused without modification.
- A new `AppSessionStage.guest` stage that grants full read access to the main
  app shell while blocking auth-only routes.
- A persistent **DEMO MODE** banner in the navigation scaffold, visible
  throughout the guest session, with a "Sign up" shortcut.
- A five-step guided tour overlay that walks through Dashboard, Funds, Debits,
  Investments, and Net Worth with contextual callout cards.
- A cinematic full-screen handoff screen (dark gold gradient) shown after the
  tour completes or is skipped. The handoff screen presents "Create account"
  and "Log in" actions.
- A three-step setup wizard shown to newly authenticated users
  (`hasCompletedSetup == false`). Each step is individually skippable.
- After the wizard (or all skips), the user enters the main app with
  contextual empty states guiding further setup.
- Guest session is one-session only. A fresh app launch always shows the
  Welcome screen for unauthenticated users.

### Out Of Scope

- Editing or adding data during the guest session.
- Carrying guest data into an authenticated account on sign-up.
- Cloud sync, push notifications, or any network calls within the guest flow.
- Returning guest state persisted across app launches.
- Animations on the handoff screen (structure is stubbed; animations are a
  follow-up story).

## Experience Flow

### Guest Path

1. Unauthenticated user opens the app and lands on `/welcome`.
2. User taps **Use as Guest**.
3. App opens the `mudra_guest` Isar store and seeds Rohan's demo data (guards
   against double-seeding).
4. Session stage transitions to `AppSessionStage.guest`. Router redirects to
   `/`.
5. Main app shell renders with a **DEMO MODE** banner above the bottom nav.
6. Guided tour overlay appears automatically after a brief delay, starting at
   step 1 (Dashboard hero card).
7. User steps through five callout cards, navigating between tabs at steps 3–5.
   At any point, "Skip tour" jumps directly to the handoff screen.
8. After step 5, the app navigates to `/onboarding/handoff`.
9. Cinematic handoff screen: dark gold gradient, Cormorant Garamond headline
   "Your finances. Your story.", two CTAs — **Create account** and **Log in**.
10. Tapping either CTA clears guest state and navigates to the corresponding
    auth screen.
11. On app kill and relaunch: user sees Welcome screen again (no persisted guest
    state).

### Post-Auth Setup Wizard (New Users)

1. After sign-up and email confirmation, session stage is `setupRequired`.
2. Router directs to `/onboarding/setup`.
3. Setup wizard opens at step 1 of 3:
   - **Step 1 — Income**: Monthly take-home amount. Skip leaves it at 0.
   - **Step 2 — First Account**: Account nickname, type, and balance. Skip
     adds no account.
   - **Step 3 — First Expense**: Recurring expense name, amount, and day of
     month. Skip adds no expense.
4. On "Continue" (each step saves the entered data) or "Skip" (data is
   discarded for that step), the wizard advances.
5. After the final step, `hasCompletedSetup` is written to AppSettings and the
   session stage advances to `ready`.
6. User lands on `/` — the main app with contextual empty states.

## Decisions And Interfaces

- Guest Isar store name: `mudra_guest` (constant `guestDatabaseName` in
  `database.dart`).
- Demo data function: `seedDemoData(Isar)` in `lib/data/seed_data.dart` —
  unchanged.
- `AppSessionStage` gains a `guest` value between `signedOut` and
  `verificationRequired`.
- GoRouter `guest` case: blocks auth-only paths, allows all main-app paths and
  `/onboarding/handoff`.
- `setupRequired` now routes to `/onboarding/setup` (replaces the interim
  `/setup/welcome` route).
- The DEMO MODE banner lives in `ScaffoldWithNavBar` and reads `stage` from
  `appSessionControllerProvider`.
- Tour state (current step, visibility) is managed by a simple Riverpod
  `Notifier` in `lib/providers/onboarding_tour_provider.dart`.
- Setup wizard state (in-progress values) is managed by a Riverpod `Notifier`
  in `lib/providers/setup_wizard_provider.dart`.

## Implementation Notes

- The guided tour uses `PageController`-driven tab navigation via `GoRouter`
  pushes to switch between main-app tabs during the tour.
- The handoff screen stubs animation containers (`Opacity`, `Transform`) ready
  for a future animation pass; they render at full opacity by default.
- The setup wizard is a `PageView` (forward-only) inside a full-screen
  `Scaffold`, consistent with the existing auth screen shell pattern.
