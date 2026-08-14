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
   zero-based Dart string offsets, with `end` exclusive.
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

After approval, promote the exact reviewed lesson into the bundled release
catalog:

```bash
dart run tool/promote_lesson.dart \
  --source=content/drafts/lesson_01.json
```

The promotion command refuses unapproved content, replaces an older lesson with
the same stable ID, sorts lessons by order, and validates the complete release
catalog before writing it.
