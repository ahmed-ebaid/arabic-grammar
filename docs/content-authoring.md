# Content Authoring Guide

Lesson source files live in `content/drafts/`. They are not loaded in normal
release builds until a qualified Arabic grammar teacher approves them.
Release-ready lessons are copied into the generated
`assets/content/catalog.json` only after their review metadata is complete.

## Authoring Rules

1. Start from `content/schema/catalog.schema.json`.
2. Use stable IDs. Lesson IDs follow `lesson_01`, `lesson_02`, and so on.
3. Write the Arabic and English versions together. Neither locale is optional.
4. Write original explanations, examples, exercises, and translations.
5. Record every consulted source and its license status.
6. Use modern copyrighted books only as conceptual references unless written
   commercial permission permits more.
7. Annotate the unvocalized example. Token `start` and `end` values are
   zero-based Dart string offsets, with `end` exclusive. Where internal
   vowels are essential, specify the optional token `vocalized` exactly as it
   appears in the vocalized example; it replaces the token's display text.
8. Give every answer option bilingual feedback that teaches why it is right or
   wrong.
9. Keep review status at `draft` or `pendingReview` until a qualified teacher
   completes the review checklist.
10. Do not reveal the requested answer in the question, including through a
    vocalized equivalent word or an inflection already written in the context.
    Preserve the grammatical clues needed to choose the answer.

Interactive exercises use the same answer and feedback structure as other
exercises. For `selectWord`, list the words of the sentence as options in
reading order, including incorrect words, and identify one correct option.
For `placeVowel`, provide an unvocalized single `targetWord`; use the option IDs
`damma`, `fatha`, `kasra` or `sukun` for the available marks. The prompt must
give the sentence and ask for the final mark. Both kinds require bilingual
feedback for every selection.

## Validation

Validate draft structure during authoring:

```bash
dart run tool/validate_content.dart
```

Validate teacher approval before preparing a release:

```bash
dart run tool/validate_content.dart --release
```

Release validation intentionally fails if any source lesson is unapproved or
approved without a reviewer and ISO-8601 review timestamp.

## Review Metadata

An approved lesson must contain:

```json
{
  "status": "approved",
  "contentVersion": "1.0.0",
  "reviewer": "Teacher's name",
  "reviewedAt": "2026-08-14T20:00:00Z",
  "notes": "Scope of review and any limitations."
}
```

Changing grammar content, a canonical answer, or an explanation after approval
requires a new content version and a new teacher review.

The app fingerprints each lesson's content separately from review metadata.
Learners who have started a lesson see an update badge when its content changes;
opening it clears the badge without changing their completion or score. On the
first rollout, previously studied pending-review preview lessons are marked
updated because older installs did not record content fingerprints.

Lesson 08 version `1.0.1` expands the bilingual explanation of definiteness,
the definite-article test, and the example with «رُبَّ أَخٍ». The owner
confirmed teacher approval by Dr. Sherif Mohamed El-Sadek on 2026-11-16;
version `1.0.1` is included in the 0.9.1 release catalog.

Catalog version `1.0.1` revises question context and wording in 20 lessons.
The owner confirmed teacher approval on 2026-11-19, and those revisions are
included in the release catalog. See the academic review protocol for scope.

For explicitly requested internal testing only, build with
`--dart-define=PREVIEW_UNREVIEWED_CONTENT=true`. This loads the draft
and enables the optional Alfiyya readings; it does not change approval metadata.
The TestFlight workflow currently uses this flag. Such builds must not be
promoted to a production store release until teacher review is complete.
The preview also loads `content/drafts/glossary/catalog.json`. Without the
flag, the app loads the approved lesson catalog and
`assets/content/glossary.json`.

On 2026-11-26 the owner confirmed that the current draft lessons, draft grammar
glossary, and Alfiyya readings had been reviewed and approved. The identified
snapshots were, respectively:

- `content/drafts/lesson_01.json`: `d7bb93e1c266f92f421d1cbe3cfe50ee4683dd9f62334c0b83a066efacfd8cc6`
- `content/drafts/glossary/catalog.json`: `20b95f3262ce91d48b3797e6a138975b310e066b6dc5df42ae981cd2666dfa2b`
- `lib/features/lessons/alfiyya_readings.dart`: `213b513b0c2b0f5b38d2b7634c599a70e804c8c674b263127669c641eaf0d2fc`

This records the owner's confirmation, not an independently verified review
date or reviewer attribution. The draft review metadata has not been promoted
to production. The separate Alfiyya glossary was created after this confirmation;
its new explanations remain pending review and are available only in the preview.

### Optional Alfiyya readings

`lib/features/lessons/alfiyya_readings.dart` contains the preview
selections shown after each level's final review. The reading route does not
add lesson steps, record answers, award XP, or change completion/unlocks.
Each selection has a stable related lesson ID, bilingual topic and explanation,
an Arabic example, and optional bilingual advanced notes.

The expanded selections follow the topic suggestions in the supplied
`ibnmalek.docx`, not its older lesson numbering. In levels five and six,
the app's lesson numbers are one lower after removal of the headlines lesson.
The source document is a selection aid, not evidence of teacher approval.
Verse references are Ibn Malik's public-domain *Alfiyya*; original modern
explanations and examples remain pending review. Consult the corresponding
chapters, not isolated lines:

- [Alfiyya text](https://ar.wikisource.org/wiki/ألفية_ابن_مالك)
- [Ibn Aqil: demonstratives](https://ar.wikisource.org/wiki/شرح_ابن_عقيل/المجلد_الأول/اسم_الإشارة)
- [Ibn Aqil: relatives](https://ar.wikisource.org/wiki/شرح_ابن_عقيل/المجلد_الأول/الموصول)

The shorter Alfiyya transcription omits `تي` in the demonstrative verse;
the Ibn Aqil transcription includes it. Do not copy merged lines or misplaced
diacritics from the supplied document. Advanced pronoun references, dialectal
prepositions, exception rules, and pause exceptions belong in expandable notes.
Do not treat `والثان منهما كثاني اثني كسا` as a standalone rule for all
two-object verbs: it refers back to the `أعلم وأرى` discussion.
The document's weak-noun passage (`المصطفى والمرتقي`) is not a weak-verb rule.
No new verse is invented for the document's empty headings (such as present
prefixes or derived-verb patterns), or for punctuation/context lessons without
a directly relevant selection.

### Promoting reviewed lessons

After approval, promote the exact reviewed lesson into the bundled release
catalog:

```bash
dart run tool/promote_lesson.dart \
  --source=content/drafts/lesson_01.json \
  --lesson=lesson_08
```

When the source contains the full draft catalog, specify the lesson ID so only
that lesson is promoted. The command refuses unapproved draft catalogs,
replaces the selected lesson with the same stable ID, sorts lessons by order,
and validates the complete release catalog before writing it. A single-lesson
source may omit `--lesson` when its catalog also satisfies release validation.
