# Content Authoring Guide

Lesson source files live in `content/drafts/`. They are not bundled into the
mobile application until a qualified Arabic grammar teacher approves them.
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

For explicitly requested internal testing only, build with
`--dart-define=PREVIEW_UNREVIEWED_CONTENT=true`. This loads the pending draft
and enables the optional Alfiyya readings; it does not mark them approved.
The TestFlight workflow currently uses this flag. Such builds must not be
promoted to a production store release until teacher review is complete.
Without the flag, the app loads and validates the approved bundled catalog.

### Optional Alfiyya readings

`lib/features/lessons/alfiyya_readings.dart` contains the pending-review
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
  --source=content/drafts/lesson_01.json
```

The promotion command refuses unapproved content, replaces an older lesson with
the same stable ID, sorts lessons by order, and validates the complete release
catalog before writing it.
