# Student Buddy – Phase 1 Setup Guide (beginner friendly)

Do the parts **in order**. Each part says what you should see when it worked.
If anything differs, copy the exact error and send it to me.

---------------------------------------------------------------------------
## What you need to provide

| # | What | Cost | Where |
|---|------|------|-------|
| 1 | Supabase account + 1 project | Free tier | https://supabase.com |
| 2 | AI provider account + API key | Pay per use (add a few dollars credit) | Anthropic: https://console.anthropic.com  (or OpenAI) |
| 3 | A computer (Windows / macOS / Linux) with ~10 GB free | – | – |
| 4 | An Android phone with USB cable, or an Android emulator | – | – |
| (Later) | Google Play developer account | $25 one-time | Phase 5 |

**Secrets rule:** Only the Supabase *URL* and *anon key* go into the app.
The AI key and the Supabase *service_role* key must NEVER be put in the app or in env.json.

---------------------------------------------------------------------------
## Part A – Install tools (one time)

1. **Flutter SDK** – follow https://docs.flutter.dev/get-started/install (choose your OS, target: Android).
2. **Android Studio** – https://developer.android.com/studio . Open it once, let it install the Android SDK.
   Then: Settings > Languages & Frameworks > Android SDK > SDK Tools > tick *Android SDK Command-line Tools* > Apply.
3. **Node.js (LTS)** – https://nodejs.org (needed to run the Supabase command-line tool).
4. In a terminal run: `flutter doctor --android-licenses` (press `y` to accept), then `flutter doctor`.
   ✅ You want green ticks for Flutter and Android toolchain.

---------------------------------------------------------------------------
## Part B – Create the Supabase project

1. Sign up at supabase.com > **New project**. Pick a name (e.g. `student-buddy`), a strong database password (save it!), and the region nearest you.
2. Wait ~2 minutes until the project is ready.
3. Open **Project Settings > API**. Copy two values:
   - **Project URL** (looks like `https://abcdxyz.supabase.co`)  → the part `abcdxyz` is your **project ref**
   - **anon public** key (long text)  ← safe for the app
   Do **not** copy `service_role` anywhere.

---------------------------------------------------------------------------
## Part C – Create the database tables and security rules

1. In Supabase: **SQL Editor > New query**.
2. Open `supabase/migrations/0001_foundation.sql` from this project, copy everything, paste, press **Run**.
   ✅ "Success. No rows returned."
3. Check **Table Editor**: you should see `profiles` and `ai_usage`, each with a "RLS enabled" badge.

## Part D – Authentication settings

1. **Authentication > Providers > Email**: make sure Email is enabled.
2. For *testing*, turn **OFF** "Confirm email" so sign-up logs you in immediately.
   (Turn it back ON before public release; the app already handles the "check your email" case.)

---------------------------------------------------------------------------
## Part E – Get an AI API key

**Anthropic:** console.anthropic.com > sign up > Billing (add credit) > API Keys > Create key. Copy it (shown once).
Pick a model name from https://docs.claude.com (a small, fast, cheap model is best for students, e.g. `claude-haiku-5-5`).

(OpenAI works too: set AI_PROVIDER=openai and a model name from platform.openai.com.)

## Part F – Deploy the secure AI backend

In a terminal, inside this project folder:

```bash
npx supabase@latest login
npx supabase@latest link --project-ref YOUR_PROJECT_REF   # asks for the DB password from Part B

npx supabase@latest secrets set AI_PROVIDER=anthropic AI_API_KEY=PASTE_KEY AI_MODEL=claude-haiku-5-5
npx supabase@latest secrets set DAILY_FREE_LIMIT=30 DAILY_PREMIUM_LIMIT=300

npx supabase@latest functions deploy ai-proxy
npx supabase@latest functions deploy delete-account
```
✅ Supabase Dashboard > Edge Functions lists `ai-proxy` and `delete-account`.

**Changing the AI model later** = run the `secrets set` line again with a new `AI_MODEL` (or `AI_PROVIDER`). No app rebuild needed.

---------------------------------------------------------------------------
## Part G – Create the Android project and add Student Buddy's code

I can't generate the `android/` folder for you, so Flutter creates it:

```bash
flutter create --org com.studentbuddy --project-name student_buddy --platforms android student_buddy_app
```
(`com.studentbuddy.student_buddy` becomes your Play Store application ID and **cannot be changed after you publish**.
If you want your own, change `--org` now, e.g. `--org com.yourname`.)

Now copy **everything** from this zip into `student_buddy_app`, choosing **Replace** when asked
(`lib/`, `test/`, `pubspec.yaml`, `supabase/`, `assets/`, `docs/`, `env.example.json`, `analysis_options.yaml`, `.gitignore`).
Make sure the old default `test/widget_test.dart` is gone.

### Android permissions and name
Open `android/app/src/main/AndroidManifest.xml`. Directly above the `<application` line add:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```
And change `android:label="student_buddy"` to `android:label="Student Buddy"`.
(The release build needs INTERNET explicitly, otherwise the app cannot reach Supabase.)

## Part H – Configure and build

```bash
cd student_buddy_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates the Drift database code
dart run flutter_launcher_icons                             # app icon
dart run flutter_native_splash:create                       # splash screen
```
Create `env.json` (copy `env.example.json`) and fill in your two values from Part B:
```json
{ "SUPABASE_URL": "https://abcdxyz.supabase.co", "SUPABASE_ANON_KEY": "eyJ..." }
```
Connect your phone (USB debugging on) or start an emulator, then:
```bash
flutter run --dart-define-from-file=env.json
```

---------------------------------------------------------------------------
## Part I – Phase 1 test checklist (tick each one)

1. App opens to the **Sign in** screen (blue, logo, tagline). If env.json is missing you see "not configured" instead.
2. **Sign up** with name/email/password (min 8 chars) → lands on Home with "Hello, <your first name>".
   In Supabase Table Editor > profiles, your row exists.
3. Bottom bar: Home, AI Tutor, Notes, Planner, Profile all switch; tab state is kept. (AI Tutor/Notes/Planner show an honest "Coming soon – Phase N" screen.)
4. **Profile > Edit profile**: change name, class, answer language, subjects → Save → values persist after restarting the app.
5. **Profile > Appearance**: System / Light / Dark switch instantly and persist.
6. **Profile > App language**: English / اردو (right-to-left) / Roman Urdu switch instantly and persist.
7. **Profile > Test AI connection** → snackbar "AI is connected (anthropic · model)". If not, the message says why (not configured / function not deployed / no internet).
8. Turn on airplane mode → grey **offline banner** appears; Profile still opens (cached). Turn it off → banner disappears.
9. **Sign out** → back at Sign in. **Sign in** again works.
10. **Continue as guest** → Home shows guest card; Profile shows "Create account / sign in"; AI test is disabled.
11. **Security check:** In Supabase SQL Editor run
    `select id, full_name from profiles;` → shows all rows (admin view). Then sign up a second user on the phone and confirm the app only ever shows that user's own data.
12. **Delete account** (use a throwaway account) → confirmation dialog → account removed; row disappears from `auth.users` and `profiles`.
13. `flutter test` passes (2 tests).

## Known limits of Phase 1 (by design)
- No "forgot password" yet (needs deep-link setup; planned with release work in Phase 5).
- Home dashboard, AI Tutor, Notes, Planner are placeholders until Phases 2, 3 and 5.
- Guests cannot use AI (AI needs an account for rate limiting and cost control).
- No bundled Urdu font yet; Android's system Urdu font is used.
- Code was written without access to Flutter/Android tooling, so **it has not been compiled or run by me.** Send me any error from Part H and I will fix it before we start Phase 2.

## Troubleshooting
- `pub get` version conflict → send me the message; I will adjust versions.
- `app_database.g.dart not found` → run the build_runner command again.
- Sign-up says "Email not confirmed" → Part D step 2 or check your inbox.
- "AI is not configured" → Part F secrets; "function not found" → deploy again.
- Test AI says "Invalid API key"/provider error → check the key and billing; see Dashboard > Edge Functions > ai-proxy > Logs.
