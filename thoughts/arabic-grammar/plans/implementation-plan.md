# Arabic Grammar App Implementation Plan

## Overview

Create a new Flutter application for iOS and Android that teaches beginners to
infer Arabic word endings and read unvocalized Arabic correctly. The MVP will
provide a bilingual Arabic/English curriculum, guided examples, quizzes, and
local-only progress. AI-powered إعراب will be delivered separately after the
curriculum MVP is validated.

The product is intended for learners who already recognize Arabic letters,
including the product owner. Lessons must therefore teach rather than assume
knowledge of grammatical terminology.

## Confirmed Product Decisions

- Repository name: `arabic-grammar`
- Public app name: `إعراب` in both interface languages
- Platforms: iOS and Android
- Client stack: Flutter, following the useful patterns in `tajweed_app`
- MVP audience: beginners who can read Arabic letters
- MVP languages: Arabic and English
- MVP content: one polished beginner module containing 10 lessons
- Learning model: structured lessons, examples, practice, and quizzes
- Accounts: none in the MVP
- Progress storage: local device storage only
- AI إعراب: post-MVP phase, not required for the initial release
- Content review: every lesson and canonical answer requires qualified Arabic
  teacher approval
- Source approach: an original synthesis informed by public-domain
  الآجرومية, the concepts taught in Madinah Arabic Book 1, and other
  established beginner references
- User-submitted AI text: one sentence, at most 300 Arabic characters,
  processed transiently and not retained

## Current State Analysis

The sibling Tajweed application provides a proven Flutter baseline:

- `../tajweed-app/pubspec.yaml:6-42` uses Flutter, Provider, Hive, Dio,
  connectivity monitoring, and localization support.
- `../tajweed-app/lib/main.dart:41-88` initializes Hive and injects application
  state with `MultiProvider`.
- `../tajweed-app/lib/root_scaffold.dart:117-148` uses a persistent tab shell
  with RTL-aware directionality.
- `../tajweed-app/lib/core/models/tajweed_models.dart:273-321` models
  multilingual rule definitions and quiz explanations.
- `../tajweed-app/lib/core/providers/quiz_progress_provider.dart:33-88`
  persists quiz progress locally and unlocks later levels after a passing
  score.
- `../tajweed-app/lib/features/home/home_screen.dart:15-53` presents current
  progress and direct entry points into learning activities.
- `../tajweed-app/README.md:144-188` documents localization, offline content,
  and local progress patterns.

These patterns should be reused conceptually, not copied wholesale. The new app
needs a lesson-first domain model rather than Quran-reader and tajweed-rule
models. It should also use generated ARB localization instead of a single large
hand-maintained localization map.

## Desired End State

### MVP

A beginner can install the app, choose Arabic or English, complete a sequenced
10-lesson module, inspect why words take fatha, damma, kasra, sukun, or their
substitute grammatical signs, practice on original examples, complete quizzes,
and resume progress without an account or network connection.

### Post-MVP AI

A learner can submit one Arabic sentence and receive:

1. The sentence with proposed tashkeel.
2. A word-by-word إعراب.
3. The governing grammatical rule.
4. Arabic and English explanations.
5. An explicit ambiguity warning when the unvocalized input permits more than
   one defensible reading.

The submitted text is processed transiently, is not stored by the app backend,
and is subject to a server-configurable daily per-device limit.

## What We Are Not Doing

- No AI analysis in the curriculum MVP.
- No user accounts, cloud sync, social features, or leaderboards.
- No complete Arabic grammar curriculum in the first release.
- No speech recognition or pronunciation scoring.
- No copying of modern textbook prose, translations, lesson layouts, or
  exercises without written permission.
- No claim that AI output replaces a qualified teacher.
- No unrestricted paragraph or document analysis.
- No direct AI-provider credentials in the mobile application.
- No dependency on a network connection for lessons or quizzes.

## Architecture

### Mobile Application

- Flutter application targeting current supported iOS and Android releases.
- Feature-first structure:
  - `lib/core/`: localization, theme, storage, shared models, validation
  - `lib/features/home/`
  - `lib/features/lessons/`
  - `lib/features/practice/`
  - `lib/features/progress/`
  - `lib/features/settings/`
  - post-MVP: `lib/features/analysis/`
- Provider for state management, avoiding simultaneous Provider and Riverpod
  usage.
- Hive for settings, lesson completion, attempts, mastery, and streak data.
- Bundled, versioned JSON lesson content for offline use.
- Flutter `gen-l10n` with English and Arabic ARB files.
- RTL directionality for Arabic UI and all Arabic learning examples.

### Content Model

Each lesson will contain:

- Stable ID, order, title, learning objectives, prerequisites, and estimated
  duration.
- Arabic and English explanations.
- Fully vocalized examples and an unvocalized comparison form.
- Token-level annotations identifying grammatical role, state or mood,
  grammatical sign, visible ending, and concise reason.
- Guided practice and quiz questions with canonical answers and explanations.
- Source records containing title, edition or URL, public-domain/license
  status, citation note, and the concepts consulted.
- Review metadata containing reviewer identity, review date, content version,
  and approval state.

Only approved content may be included in release builds.

### Local Progress Model

- Lesson state: locked, available, in progress, completed.
- Exercise attempts and most recent answer.
- Per-concept mastery score.
- Module completion percentage.
- Optional local streak.
- Content-version migration so lesson revisions do not corrupt saved progress.

## Curriculum Scope

The first module will contain these 10 lessons:

1. **Why endings change** — tashkeel versus grammatical endings and the ideas
   of رفع, نصب, جر, and جزم.
2. **Kinds of words** — اسم, فعل, and حرف, with beginner-friendly recognition
   clues.
3. **The nominal sentence** — مبتدأ and خبر, both normally مرفوع.
4. **The verbal sentence and subject** — فعل and فاعل, with the فاعل مرفوع.
5. **The direct object** — مفعول به and why it is منصوب.
6. **Prepositions** — حروف الجر and the following اسم مجرور.
7. **The possessive construction** — مضاف and مضاف إليه مجرور.
8. **Adjectives** — نعت agreement in definiteness, gender, number, and case.
9. **Case signs beyond short vowels** — introductory dual and sound-plural
   signs without attempting full morphology.
10. **Present verb moods** — introductory مرفوع, منصوب, and مجزوم forms,
    followed by a cumulative module assessment.

Each lesson must introduce no more than the terminology needed for its
objectives and must link every technical term to a plain-language explanation.

## Phase 0: Repository and Product Foundation

### Implementation Progress

- [x] Flutter repository and iOS/Android targets scaffolded
- [x] Feature-first bilingual application shell implemented
- [x] Local settings storage, themes, environment handling, and CI added
- [x] Analyzer, tests, and iOS simulator build completed
- [x] Android build confirmed in CI or an environment with the Android SDK
- [x] Manual application-shell verification

### Changes Required

- Initialize `arabic-grammar` as a standalone Git repository on `main`.
- Create the Flutter application with iOS and Android targets.
- Establish feature-first directories, analysis rules, test directories, and
  CI.
- Configure package identifiers, display names, minimum platform versions, and
  environment handling.
- Add generated Arabic/English localization and RTL-aware application shell.
- Add light/dark themes with accessible contrast and an Arabic-readable font
  whose license permits redistribution.
- Document development setup and release commands.

### Success Criteria

- Clean checkout can restore dependencies, analyze, test, and build both mobile
  targets.
- Arabic locale flips navigation and UI direction correctly.
- Arabic examples remain RTL when the English interface is active.
- No Tajweed-specific identifiers, assets, services, or Quran API assumptions
  remain.

**Implementation note:** Pause for manual confirmation of the empty application
shell before curriculum work.

## Phase 1: Content System and Review Workflow

### Implementation Progress

- [x] Typed bilingual content models and versioned JSON schema added
- [x] Strict structural, cross-reference, token-span, answer, and provenance
      validation added
- [x] Release gate rejects unapproved lessons and incomplete reviewer metadata
- [x] Authoring guide and teacher review checklist added
- [x] Original bilingual lesson 1 draft prepared and structurally validated
- [ ] Qualified Arabic grammar teacher reviews and approves lesson 1
- [ ] Approved lesson 1 is promoted into the bundled release catalog

### Changes Required

- Define typed lesson, section, example, annotation, exercise, source, and
  review-status models.
- Define and document the versioned JSON schema.
- Add strict content decoding and actionable validation failures.
- Add validation for:
  - unique IDs and valid lesson ordering
  - prerequisite references
  - required Arabic and English fields
  - valid token spans and annotation references
  - exactly one canonical answer where appropriate
  - explanations for every graded response
  - source and license/provenance metadata
  - teacher approval for release content
- Add a content-authoring guide and teacher review checklist.
- Add CI validation that rejects malformed or unapproved release content.

### Success Criteria

- A sample lesson loads from bundled JSON in both languages.
- Invalid annotations, missing translations, duplicate IDs, or unapproved
  content fail automated validation.
- A reviewer can determine the origin and approval status of every lesson.

**Implementation note:** Pause for teacher review of the schema and sample
lesson before writing the full module.

## Phase 2: Lesson Experience

### Changes Required

- Build module overview and lesson sequence screens.
- Build lesson sections for concept introduction, worked examples, rule
  summaries, and checkpoints.
- Render Arabic examples with selectable annotated words.
- On word selection, show:
  - grammatical role
  - حالة الإعراب or verb mood
  - علامة الإعراب
  - expected ending
  - plain-language Arabic and English reason
- Show vocalized and unvocalized forms without presenting unvocalized text as a
  unique parse when context is insufficient.
- Add next/previous navigation and automatic local resume.
- Author the 10 lessons using original wording and original examples.
- Obtain teacher approval before marking each lesson releasable.

### Success Criteria

- All lessons are usable offline.
- A beginner can move from an explanation to a worked example and identify why
  each target ending is used.
- Switching languages preserves lesson position.
- Every shipped statement and canonical parse has teacher approval and source
  provenance.

**Implementation note:** Pause for a full teacher and beginner usability review
of lessons 1–3 before authoring lessons 4–10.

## Phase 3: Practice, Quizzes, and Progress

### Changes Required

- Implement practice types:
  - choose the correct final haraka
  - identify the grammatical role
  - identify رفع, نصب, جر, or جزم
  - match a word to the rule governing its ending
  - progressively add tashkeel to an unvocalized sentence
- Provide immediate bilingual feedback explaining both correct and incorrect
  choices.
- Randomize option order without changing canonical answers.
- Require a 70% lesson checkpoint score to mark mastery while allowing lessons
  to be revisited freely.
- Add cumulative assessment for lesson 10.
- Persist attempts, completion, mastery, and streak locally.
- Add reset-progress controls with explicit confirmation.

### Success Criteria

- Exercises are deterministic under test and never grade by display position.
- Closing and reopening the app preserves progress.
- Content-version migrations preserve valid progress and safely invalidate only
  changed exercise attempts.
- Every incorrect answer provides a useful explanation rather than only a
  failure state.

**Implementation note:** Pause for learner testing of difficulty, pacing, and
feedback before release hardening.

## Phase 4: MVP Quality, Legal, and Release Readiness

### Changes Required

- Add unit tests for content parsing, validation, progression, grading,
  localization fallback, and migrations.
- Add widget tests for RTL/LTR layouts, lesson rendering, annotations, quizzes,
  and reset behavior.
- Add integration coverage for completing and resuming the module.
- Test dynamic text sizing, screen readers, touch targets, contrast, and Arabic
  shaping on representative iOS and Android devices.
- Prepare privacy policy, terms, support page, content attributions, and
  third-party license notices.
- Document that the MVP stores progress only on-device and does not require an
  account.
- Perform legal review of branding and all non-public-domain source usage.
- Complete store metadata, screenshots, internal beta, and teacher sign-off.

### Success Criteria

- Analyzer, unit, widget, and integration suites pass in CI.
- All 10 lessons have signed-off review metadata.
- No release artifact contains unapproved or incompatibly licensed material.
- The complete module works offline after installation.
- Internal testers can finish the module without a blocking usability issue.

## Phase 5: Post-MVP AI إعراب

### Overview

Add AI only after curriculum feedback establishes the app's terminology,
explanation style, and canonical grammar model.

### Provider Evaluation

- Build a teacher-authored benchmark set covering all MVP concepts, common
  ambiguities, malformed input, and sentences outside the beginner scope.
- Compare candidate models for:
  - final-vowel accuracy
  - grammatical-role accuracy
  - rule/explanation accuracy
  - Arabic and English clarity
  - consistent structured JSON output
  - latency and cost
  - zero-retention or enterprise data-control terms
- Require at least 90% accuracy on beginner concepts and no critical
  teacher-identified misinformation in the launch benchmark.
- Select a provider only after results and terms are documented.

### Backend

- Add a Cloudflare Worker AI gateway with a provider-neutral adapter.
- Store API credentials only in Worker secrets.
- Validate Arabic input, reject empty or over-300-character requests, and
  enforce one-sentence scope.
- Use schema-constrained output and reject malformed provider responses.
- Do not log request text or model response text.
- Record only privacy-safe operational metrics such as latency, status,
  provider, model version, and token counts.
- Apply abuse protection and a server-configurable per-device beta limit,
  initially five analyses per day.
- Publish an updated privacy policy before enabling the feature.

### Mobile Experience

- Add text entry, character counter, submission state, and clear retry/error
  messages.
- Render proposed tashkeel and token-level results using the same grammatical
  vocabulary as the curriculum.
- Distinguish grammatical case/mood, sign, surface ending, governing relation,
  and explanation.
- Display ambiguity explicitly rather than inventing certainty.
- Show an educational disclaimer and a correction/report mechanism.
- Do not save analysis history in the MVP version of this feature.

### AI Success Criteria

- Provider credentials cannot be recovered from the mobile binary.
- Submitted text is absent from application and Worker logs.
- Invalid, oversized, non-Arabic, rate-limited, timed-out, and malformed-model
  cases produce localized, actionable errors.
- Benchmark quality meets the launch threshold and is re-run for every model or
  prompt version.
- A qualified teacher approves the prompt, response schema, benchmark, and
  learner-facing disclaimer.

## Testing Strategy

### Unit Tests

- JSON schema decoding and all content validation rules.
- Token boundaries across Arabic combining marks and punctuation.
- Exercise grading independent of randomized option order.
- Lesson unlocking, mastery calculation, progress reset, and data migration.
- Arabic/English fallback behavior.
- Post-MVP AI request validation, response decoding, rate limits, and redacted
  logging.

### Widget Tests

- RTL and LTR navigation.
- Arabic word annotation selection.
- Dynamic text size and overflow.
- Quiz feedback and completion states.
- Offline startup and progress resume.
- Post-MVP AI loading, ambiguity, limit, and error states.

### Integration Tests

- First launch through completion of lesson 1.
- Complete lessons, restart the app, and resume at the correct location.
- Switch language mid-lesson without losing state.
- Complete the cumulative assessment and reset local progress.
- Post-MVP: submit a valid sentence through the gateway and verify structured
  rendering without persisted history.

## Performance and Reliability

- Keep curriculum content bundled and small enough for immediate local loading.
- Parse and validate content once, then expose immutable lesson models.
- Avoid rebuilding full annotated passages when one token is selected.
- Treat Unicode grapheme clusters correctly so Arabic combining marks are not
  split.
- AI calls must have explicit connect/receive timeouts, cancellation, and
  bounded retries for transient failures only.
- Backend provider failures must never be presented as successful analysis.

## Legal and Content Safety

- Use the original classical text of الآجرومية only from a verified
  public-domain source.
- Treat modern editions, commentaries, and translations as separately
  copyrighted unless their license states otherwise.
- Use Madinah Book 1 only as a conceptual reference unless written commercial
  permission is obtained.
- Write original explanations, examples, exercises, translations, and lesson
  sequencing.
- Maintain a machine-readable provenance record for every lesson.
- Avoid branding that implies endorsement by an author, university, publisher,
  or existing course.
- Obtain legal review before commercial release; this plan is a risk-reduction
  strategy, not legal advice.

## Delivery Order

1. Repository and bilingual application shell.
2. Content schema plus one teacher-reviewed sample lesson.
3. Lessons 1–3 and beginner usability validation.
4. Lessons 4–10.
5. Exercises, progress, and cumulative assessment.
6. Accessibility, legal review, beta, and MVP release.
7. AI benchmark and provider selection.
8. Cloudflare gateway and mobile AI experience.
9. AI beta followed by a separately gated public release.

## References

- Similar Flutter application: `../tajweed-app/`
- Tajweed architecture summary: `../tajweed-app/README.md`
- U.S. Copyright Office Fair Use Index:
  https://www.copyright.gov/fair-use/
- Flutter internationalization:
  https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Unicode Arabic character guidance:
  https://www.unicode.org/versions/latest/
