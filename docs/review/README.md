# Curriculum review export

`arabic-grammar-curriculum-review.docx` is generated directly from
`content/drafts/lesson_01.json`. It contains every app lesson, teaching section,
example, token analysis, primary exercise, alternate exercise, answer, feedback
message, source, and review worksheet.

Regenerate it after curriculum changes:

```bash
python3 tool/export_curriculum_docx.py
```

The document records the curriculum version and SHA-256 hash of its source JSON,
so reviewers can confirm which app content they reviewed.
