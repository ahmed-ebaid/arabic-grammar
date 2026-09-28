# Curriculum review export

`arabic-grammar-curriculum-review.docx` is generated directly from
`content/drafts/lesson_01.json`. It contains every app lesson, teaching section,
example, token analysis, primary exercise, alternate exercise, answer, feedback
message, source, and review worksheet.

The export is **Arabic-only** and right-to-left throughout: labels, headings, and
worksheet fields are all in Arabic. Tables carry only the fields the app actually
renders to a learner, so reviewers assess exactly what ships. Curriculum fields
that never reach the UI — unvocalized example forms, token character spans, and
option, source, and license metadata — are intentionally omitted.

Regenerate it after curriculum changes:

```bash
python3 -m pip install python-docx
python3 tool/export_curriculum_docx.py
```

The document records the curriculum version and SHA-256 hash of its source JSON,
so reviewers can confirm which app content they reviewed.
