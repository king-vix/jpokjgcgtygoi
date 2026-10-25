# StudyVix

StudyVix is a mobile-first study companion for Nigerian JAMB and IJMB candidates. This starter includes a React dashboard, practice quiz flow, offline-readable notes, a timetable, dark mode, Supabase Auth integration, a database schema with Row Level Security, and a secure Supabase Edge Function for the OpenAI-powered tutor.

## Important status

This is a working starter, not a live production service yet. Authentication, cloud-saved progress, verified content, and AI replies require your own Supabase project and secrets. Demo questions and notes in the interface are labelled as examples, not official past questions. The interface currently keeps progress locally; connect the supplied database tables before claiming cross-device sync.

## Run locally

1. Install Node.js on a computer, or use a cloud development environment.
2. Copy `.env.example` to `.env` and enter your Supabase project URL and publishable/anon key.
3. Run `npm install`, then `npm run dev`.
4. Run `npm run build` to check the production build.

Never put `OPENAI_API_KEY` or the Supabase service-role key in a `VITE_` variable or browser code.

## Supabase setup

1. Create a project at https://supabase.com.
2. In SQL Editor, run `supabase/schema.sql`.
3. Copy your project URL and publishable/anon key into `.env` as `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
4. In Authentication settings, configure email sign-in and your production redirect URLs.
5. Deploy the Edge Function `studyvix-tutor` from `supabase/functions/studyvix-tutor`.
6. Set Edge Function secrets using the Supabase CLI or dashboard:
   - `OPENAI_API_KEY`: your OpenAI API key
   - `OPENAI_MODEL`: a model available to your API project, e.g. `gpt-4.1-mini`
7. Redeploy and test with a signed-in account.

OpenAI API billing is separate from a ChatGPT subscription. The AI tutor uses the site owner's API account, so set budget/usage limits and rate limiting before public launch. The function validates the user's Supabase session and keeps the API key server-side. Before launch, also add rate limiting, abuse monitoring, privacy/terms pages, and appropriate data retention controls.

## Official content policy

- Start syllabus review from the official JAMB IBASS portal: https://ibass.jamb.gov.ng/
- Verify the current syllabus and topic scope before publishing each unit.
- IJMB content needs verification against the current IJMB programme/centre guidance and qualified subject reviewers; do not assume JAMB content is equivalent.
- Mark content as `verified` only after a human review records the source and date.
- Do not republish copyrighted past-question compilations without permission/licensing. Keep original practice questions distinct from verified official questions.
- Do not use AI output alone as proof that a question, answer, or syllabus detail is official.

## Current starter limitations / production checklist

- The sample questions are a demo set and loop for requested counts. Replace this with a reviewed database question bank before real exam practice.
- The app's local progress and notes use browser local storage. Add database read/write functions for profile, progress, sessions, notes and quiz attempts to enable cross-device sync.
- Service worker caches the app shell and same-origin GET requests. For robust offline use, add a content download manager, versioned cache invalidation, storage quota handling and explicit download status.
- Add a trusted admin workflow to create/review/publish `content_items`; public users have read-only access to reviewed/verified rows.
- Add server-side rate limiting and request quotas to the AI Edge Function before opening access to many users.
- Test keyboard navigation, screen readers, small screens, weak connections, email confirmation, password reset and session expiry.

## Suggested build order

1. Configure Supabase and verify authentication.
2. Connect profile/progress/timetable/notes to the database with RLS.
3. Build the admin content-review workflow and seed verified syllabus topics.
4. Replace demo quiz pool with database-driven questions and store attempts.
5. Deploy the AI Edge Function, add rate limits and test retrieval.
6. Improve offline downloads and run Android browser/install tests.
