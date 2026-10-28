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

For a new review, export the current curriculum to a separate file:

```bash
python3 -m pip install python-docx
python3 tool/export_curriculum_docx.py --output /path/to/new-curriculum-review.docx
```

The document records the curriculum version and SHA-256 hash of its source JSON,
so reviewers can confirm which app content they reviewed.

## Reviewed-copy merge

The repository DOCX is retained as the comparison baseline. Sherif's reviewed
Desktop copy was merged selectively into the current app JSON, not imported over
newer lessons. Clear corrections were applied together with their related answer
choices, feedback, and English explanations. The newer imperative and basic
triliteral-pattern material, exercise IDs, and review-approval status are retained.

`curriculum-comment-responses-ar.csv` preserves the previous 235 responses and
adds all 142 new comments: 136 addressed in revised wording, five duration-wording
requests already covered by the app/exporter, and one awaiting clarification.
These are comment counts, not counts of distinct content edits.

At the user's direction, the article is written without a hamza above the alif
in explanatory text. Existing «الـ» notation is retained; only «أل» becomes «ال».
Quoted verses and their source-token spelling are preserved.

The five previously disputed passages remain unchanged: the pronoun definition
in lesson 14, the unfinished exercise in lesson 15, the description of «ضرب» in
lesson 40, the incomplete objective and coupled example in lesson 49, and the
analysis of quoted «أل» in lesson 53. Comment 376 about advancing the object before
the verb versus before the subject in lesson 43 is also deferred. The rest of
these lessons may contain independent, unambiguous corrections.

Token rendering now avoids repeating letters already present in an inflection,
including dual/plural endings and inflections before attached pronouns. The app
and future DOCX exports use the same composition rule; neither reference DOCX is
overwritten by this merge.
