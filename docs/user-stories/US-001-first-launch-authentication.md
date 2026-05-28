# US-001: First Launch Authentication And Account Entry

## User Story

As a new user, I want to securely create or access my Mudra account when I
first launch the app, so my financial information is private and associated
only with my identity.

## Intent

Mudra currently opens directly into a locally seeded Dashboard with no
authentication. This story changes the product boundary: signed-out users see
only authentication entry points, and financial records are available only
inside an authenticated user's private local store.

The story ends once an authenticated new user reaches a setup handoff screen.
Financial onboarding and cloud synchronisation are separate stories.

## Scope

### In Scope

- Pure-white native splash followed by a branded Welcome screen.
- Supabase Auth for email/password, Google on iOS and Android, and Apple on iOS.
- Mandatory email confirmation for email/password registration.
- Forgotten-password and reset-password deep-link flow.
- Protected financial routes and sign-out.
- Separate Isar data stores for each authenticated user.
- One-time choice to attach or discard legacy local-only data.
- An authenticated `Setup Welcome` handoff destination.

### Out Of Scope

- Cloud synchronisation of financial records.
- Account, income, or budget setup after authentication.
- New insights, recommendations, charts, or budget behavior.

## Experience Flow

1. Native splash displays the Mudra brand on `#FFFFFF`.
2. Mudra initializes authentication and determines whether a valid session
   exists.
3. A signed-out user lands on `/welcome`, with `Create account`, `Log in`,
   Google sign-in, and Apple sign-in on iOS.
4. Registration collects full name, email, password, password confirmation,
   and Terms/Privacy consent.
5. Email registration sends a confirmation link to
   `mudra://auth/callback`; access remains blocked on `/auth/verify-email`
   until confirmation succeeds.
6. Login supports email/password and the platform-appropriate social methods.
7. `Forgot password?` sends a reset link returning to
   `mudra://auth/reset-password`, where the user chooses a new password.
8. On first authenticated access, a device with legacy local data asks the
   user to either attach it to this account or start fresh.
9. A new or incomplete account enters `/setup/welcome`.
10. A returning account with completed setup enters the existing five-tab app.
11. Sign-out closes local financial access and returns to `/welcome`.

## Decisions And Interfaces

- Authentication provider: Supabase Auth.
- Mobile app identifier: `com.mastermudra.mudra`.
- Callback URLs: `mudra://auth/callback` and
  `mudra://auth/reset-password`.
- Google sign-in is offered on iOS and Android; Apple sign-in is offered on
  iOS only.
- Email confirmation is required before application access.
- Supabase stores identity; Isar continues to store finances locally.
- Isar stores are scoped by authenticated Supabase user id.
- `AppSettings` gains `hasCompletedSetup`, defaulting to `false`.
- Production first launch no longer creates fictitious demo finance records.

## Implementation Plan

### Authentication And Configuration

- Add Supabase, Google sign-in, Apple sign-in, and cryptographic nonce
  dependencies.
- Configure iOS and Android IDs and deep-link handling using
  `com.mastermudra.mudra` and the `mudra` URL scheme.
- Initialize Supabase from `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`
  build-time configuration.
- Implement an auth repository and app-session controller that expose session,
  verification, password recovery, social sign-in, and sign-out behavior.

### Routing And Screens

- Gate the current app shell behind authenticated, verified, setup-complete
  session state.
- Add `/welcome`, `/auth/login`, `/auth/register`, `/auth/verify-email`,
  `/auth/forgot-password`, `/auth/new-password`, `/legacy-data`, and
  `/setup/welcome`.
- Build each screen with the white/gold Mudra visual grammar and existing form
  primitives.

### Data Isolation And Migration

- Stop opening the financial Isar database or seeding demo data before login.
- Open a user-specific Isar database only after authentication.
- Detect legacy `mudra_db` contents after login, then migrate on attach or
  delete on start-fresh.
- Close the active user database and invalidate financial state on sign-out.

## Acceptance Criteria

- Fresh install displays Welcome after splash, not Dashboard.
- Signed-out users cannot access any financial route.
- Registration validates fields and consent, requires email verification, and
  proceeds only after confirmation.
- Verified email, Google, and iOS Apple authentication reach setup handoff.
- Password-reset deep linking completes successfully.
- Newly registered users do not receive seeded demo finance data.
- Different accounts on one device cannot access one another's local records.
- Legacy users see attach-or-start-fresh once after authentication.
- Sign-out returns to Welcome and hides all financial content.

## Verification Plan

- Unit-test auth routing state, user-store lifecycle, setup state, and legacy
  migration choices.
- Widget-test auth form validation, social-button platform visibility, and
  protected-route redirects.
- Manually verify registration confirmation, login, Google, password reset,
  migration, and sign-out on iOS and Android; verify Apple sign-in on iOS.
- Run `flutter analyze` and `flutter test` clean before completion.

## Post-Implementation Documentation

After implementation and verification, update `docs/PLAN.md`,
`docs/STATUS.md`, `docs/USER_FLOW.md`, and `docs/APP_MAP.html` so launch
routing, authenticated storage, and completed verification are represented
consistently.
