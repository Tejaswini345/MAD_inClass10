# MAD 4360 – In-Class Activity 10: Flutter Signup Form Quest

## Name
- Tejaswini Kolliboni (graduate track) - 003037935


## Track and tasks
- **Track:** Graduate
- **Task A (required):** Local signup tip simulation
- **Extension:** Task C – Confirm & Celebrate

## App theme
"Snack Club" signup screen 

## How the local tip feature works
- **Fixed category:** `password_help`. This is the only thing that selects a tip.
- **Preset tips:** Three short tips are stored in a hardcoded list in the app (all under 240 characters).
- **Selection:** The tip is chosen by `requestCount % number of tips`, so it is deterministic and rotates on each tap.
- **States:** idle → loading (about 0.9 s simulated delay) → success or error. The error state has a Retry button.
- **Label:** Every tip is shown with "Preset demo tip—not live AI."
- **Test mode dropdown:** Normal, Local error, and Missing tip data, so every state can be demonstrated without editing code.
- **No server, credentials, or live AI service is used.** Nothing in the tip feature makes a network call.

## Task C
- A Confirm Password field blocks submission when it doesn't match the password.
- On success, a green SnackBar shows "Welcome, [entered name]!"

## Tests run
Form and tip tests were run in Android emulator. APK built with `flutter build apk` (release).

| # | Test | Result |
|---|------|--------|
| 1 | All fields empty, tap Sign Up | Four error messages shown – pass |
| 2 | Email without "@" | Email error – pass |
| 3 | Password under 6 characters | Length error – pass |
| 4 | Confirm password differs | "Passwords do not match", no success – pass |
| 5 | All valid | Green "Welcome, [Name]!" SnackBar – pass |
| 6 | Normal mode tip | Spinner, then tip with demo label; tapping again changes tip – pass |
| 7 | Local error mode | Error + Retry shown; Retry fails again; after switching to Normal, Retry recovers – pass |
| 8 | Missing tip data mode | Same error and retry behavior – pass |
| 9 | Tip button during loading | Button disabled – pass |
| 10 | Typing in form fields, then getting a tip | Tip unchanged by form contents – pass |
| 11 | Getting a tip with empty form, then Sign Up | Validation still blocks signup – pass |
| 12 | Airplane mode on, then get a tip | Tip loaded and displayed normally – pass |


## Contribution
- Tejaswini: Set up the project, implemented the form, local tip feature, and Task C, chose the theme and color, ran all tests, built the APK, and wrote this README.

## Reflection – Tejaswini Kolliboni (graduate, 3 questions)

**1. Identify one privacy boundary in the local tip feature. What information does it keep out of the feature, and why?**
The tip feature never receives the name, email, or password. The `_getTip` method calls the tip service with only a tap counter and the test mode, and it never reads the text controllers. This matters because even a local demo should model the habit of not sending personal data to a helper feature, which would be critical if the tips later came from a real AI service. The boundary also keeps the feature simple to audit, since you can verify it by checking that no controller appears in the tip code path. In testing, changing what I typed in the fields did not change the tip.

**2. What should the UI do when local tip data is empty or missing? Explain your error and retry behavior.**
When the tip list is empty, the service throws an error, and the UI moves to the error state instead of showing blank text or crashing. The user sees a red message saying the tip could not be loaded, plus a Retry button that runs the same loading flow again. I tested this with the "Missing tip data" mode: it showed the error, retrying kept failing, and switching back to Normal let Retry recover with a tip. A possible improvement is a more specific message for "no tips available" versus a temporary failure, since retrying cannot fix missing data.

**3. Describe one trade-off in your local design and a practical improvement.**
The main trade-off is reliability and privacy versus variety. Because tips come from a small fixed list selected by a tap counter, the feature works offline, is fully predictable, and is easy to test, but users see the same three tips repeating and the tips cannot adapt to what the user needs. Another trade-off is that the test-mode dropdown is visible in the UI, which is useful for demonstrating errors but would not belong in a production app. A practical improvement is to add more categories and tips, keeping them stored locally, and hide the test controls behind a debug-only flag.