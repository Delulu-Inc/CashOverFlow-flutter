# Cash Overflow

AI-powered cash-flow forecasting for businesses: KPIs, a confidence fan
chart, risk detection, AI recommendations, what-if simulations, team &
subscription management. Built with Flutter (web first).

## Getting started

```bash
flutter pub get
flutter run -d chrome
```

The API host defaults to `https://cashoverflow-api.runasp.net/v1` and can be
overridden at build time:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://staging.example.com/v1
```

## Project structure

Feature-first layout. Each feature owns its data layer and its UI; shared
code lives in `core/`, app wiring in `app/`.

```
lib/
├── main.dart                     # bootstrap only
├── app/
│   ├── app.dart                  # MaterialApp + DI + session cubit
│   ├── app_dependencies.dart     # composition root (creates repositories)
│   └── router/                   # URL → page (hash, path & GitHub Pages URLs)
├── core/
│   ├── config/                   # API base URL, timeouts, demo constants
│   ├── network/                  # ApiClient (auth header, timeout, errors), ApiException
│   ├── storage/                  # SessionStorage (token, role, pending invite)
│   ├── responsive/               # Breakpoints & helpers
│   ├── theme/                    # Shared colors & ThemeData
│   ├── utils/                    # Validators, formatters, logger
│   └── widgets/                  # Shared widgets (auth background, glass card)
└── features/
    ├── landing/                  # public marketing page
    ├── auth/                     # login, set password, session cubit, route guard
    ├── onboarding/               # "Register" demo request, invitations
    ├── checkout/                 # activate plan (Stripe), payment result pages
    ├── dashboard/                # shell + sidebar, KPIs, fan chart, risks, recommendations
    ├── ai_support/               # AI chat & simulations
    ├── team/                     # members & invitations (owner only)
    ├── subscription/             # plan, payment method, billing (owner only)
    ├── profile/                  # profile & password
    └── admin/                    # demo requests management (admin)
```

Every feature follows the same split:

```
features/<name>/
├── data/
│   ├── models/          # JSON ⇄ Dart, tolerant parsing
│   └── repositories/    # the only place that talks to ApiClient
└── presentation/
    ├── pages/
    ├── widgets/
    └── cubit/           # when state is shared across widgets
```

Rules of thumb:

* Widgets never call `http` directly — they use a repository obtained with
  `context.read<XRepository>()`.
* Repositories throw `ApiException` whose `message` is safe to show.
* `SessionCubit` is the single source of truth for the signed-in user (sidebar
  name, role based access to owner-only pages, logout).

## Routes

| URL | Page |
| --- | --- |
| `/` | Landing page |
| `/login` | Sign in |
| `/register` | Demo request form |
| `/accept-invite?token=` | Activate plan → Stripe checkout |
| `/payment-success` · `/payment-failed` · `/payment-cancel` | Stripe redirects |
| `/set-password?token=&type=team` | Choose a password (owner or invited member) |
| `/dashboard` · `/ai-support` · `/profile-settings` | Dashboard shell |
| `/team-management` · `/subscription` | Dashboard shell, owners only |
| `/admin-dashboard` | Demo requests (requires a session) |

## Responsive design

The approved Figma frames are desktop (1440px). Every screen renders the
original desktop layout from its desktop breakpoint upwards and only adapts
below it (`lib/core/responsive/responsive.dart`):

| Width | Behavior |
| --- | --- |
| `< 600` | Phone: stacked layouts, drawers instead of the sidebar / nav bar |
| `600 – 1023` | Tablet: stacked layouts, sidebar in a drawer |
| `≥ 1024` | Permanent dashboard sidebar |
| `≥ 1200` | Original landing page layout |

## Tests

```bash
flutter analyze
flutter test
```

`test/widget/responsive_layout_test.dart` renders every route at 360, 768,
1024, 1280, 1366, 1440 and 1920px with the production font (Roboto) against a
fake API (`test/helpers/fake_backend.dart`); any overflow fails the build.

## Deployment (GitHub Pages)

```bash
flutter build web --release --base-href /CashOverFlow-flutter/
# then copy build/web/* into docs/ and push
```
