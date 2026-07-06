# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Epoque Suraksha is a Flutter app for security/gate staff at an event ("Epoque"). The primary flow: scan attendee QR codes to verify entry eligibility and view a profile sheet, plus a reports/gate-pass-count tab. Backend is the live API at `https://epoque.kiet.edu/api/`.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run on a connected device/emulator
flutter analyze                 # static analysis / lint (flutter_lints)
flutter test                    # run all tests
flutter test test/widget_test.dart   # run a single test file
dart format .                   # format

flutter pub run flutter_launcher_icons   # regenerate app icons from assets/images/Epoque.png
```

## Architecture

**State management is Riverpod throughout.** There is no `ProviderScope` in `main()` — instead `main()` builds a `ProviderContainer` manually, `await`s `apiClientProvider.future` so the HTTP client (and its persisted cookie jar) is ready before first frame, then injects it via `UncontrolledProviderScope`. Anything needing the network must wait on this provider.

**Networking — session/cookie based, not token based.**
- `ApiClient` (`lib/core/network/api_client.dart`) wraps a single `Dio` instance with `baseUrl` `https://epoque.kiet.edu/api/`. It exposes `get/post/put/delete` plus a `_resolvePath` helper that substitutes `{key}` path params.
- Auth is **HTTP Basic on login** (`Authorization: Basic <base64(user:pass)>` to `POST /v1/core/auth/`), after which the server sets a **session cookie**. Cookies are persisted to disk via `PersistCookieJar` (`getApplicationDocumentsDirectory()/.cookies/`) so sessions survive restarts. Subsequent requests authenticate by cookie, not bearer token.
- `validateStatus` accepts anything `< 500`, so 4xx responses do NOT throw — callers must check `res.statusCode` explicitly (e.g. login expects `201`, getCurrentUser expects `200`).
- `apiClientProvider` is the async source of truth; `dioProvider` exposes the raw `Dio`. Service providers read `ref.watch(apiClientProvider).value` and assume it is non-null (already awaited in `main`).

**Auth flow:** `AuthRepository` (login/logout/getCurrentUser/isLoggedIn) → `AuthNotifier` (`StateNotifier<AuthState>`, from `flutter_riverpod/legacy.dart`) → `authNotifierProvider`. `SplashScreen` calls `checkAuth()` on launch and routes to `/home` or `/login` based on `isAuthenticated`.

**Routing** is plain named routes in `AppRouter.routes` keyed off `AppRoutes` constants (`/splash`, `/login`, `/home`). Navigation uses `Navigator.pushReplacementNamed`.

**Screen structure:** `MainScreen` is a 2-tab shell using `IndexedStack` + a custom bottom nav (tabs are kept alive, not rebuilt). Tab 0 = `QrScannerPage`, tab 1 = `ProfilePage`. Each page receives an `isActive` flag tied to the selected index — `QrScannerPage` uses it to pause the camera ("Scanner paused") when not the active tab, since `IndexedStack` keeps it mounted.

**QR verification:** `QrScannerPage` uses `mobile_scanner`. On detect it sets `_isScanning = false`, vibrates, then calls `QrService.verifyQr` (`POST /v1/master/generate-qr/` with `{"qr_code": data}`, expects `201`). The response map drives a profile bottom sheet — key fields: `allowed` (string, `"Allowed"` vs anything else), `name`, `username`, `type`, `member_*` labels, `profile_image_url`, `count`. Errors show an error sheet. `_scanAgain()` re-enables scanning after a sheet closes.

## Conventions

- **Theme:** All colors/styling come from `AppTheme` (`lib/theme/theme.dart`) — a luxury dark navy + gold palette (`bgDeep`, `navyCard`, `gold`, `snowWhite`, `ashGrey`, semantic `errorRed`/`successGreen`/`warningYellow`). Do not hardcode colors; reuse these constants. Typography uses `google_fonts` (`GoogleFonts.lora` for headings/labels, `GoogleFonts.dmSans` for body).
- Service classes follow a fixed shape: a plain class taking `ApiClient` in its constructor, paired with a Riverpod `Provider` at the bottom of the same file.
- `lib/` layout: `core/` (network, routes, services), `screens/` (top-level screens + `screens/pages/` for tab pages), `theme/`.
