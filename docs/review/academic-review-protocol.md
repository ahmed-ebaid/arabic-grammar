# Academic curriculum review

## Review unit

Review the exact curriculum export generated from `content/drafts/lesson_01.json`.
Each review copy records the source version and SHA-256 hash; keep that copy
unchanged and record its hash with the review. A correction produces a new
version and a new export rather than silently replacing the reviewed copy.

## Reviewer checklist

For each lesson and exercise, check:

- Accuracy of grammatical rules, terminology, and i'rab.
- Vocalization, spelling, examples, answer choices, answers, and feedback.
- Whether each explanation follows from the stated rule and sentence context.
- Attribution and wording of quoted poetry or other source material.
- Clarity, sequencing, and suitability for the intended learner.

Record each finding with the lesson and exercise ID, page or section, the
current wording, the proposed correction, and a short rationale or source
reference. Mark it as a blocking correction, a recommended improvement, or a
question for discussion.

## Approval record

Use one record per reviewed export:

| Field | Record |
| --- | --- |
| Reviewer name and qualifications | |
| Institutional affiliation, if applicable and authorized to publish | |
| Review date | |
| Curriculum version and SHA-256 | |
| Lessons reviewed | |
| Blocking findings remaining | |
| Decision: approved, revise and resubmit, or not approved | |
| Permission to identify the reviewer publicly | |

Approval applies only to the recorded content version and scope. Resolve every
blocking finding, regenerate the export, and obtain confirmation on the new hash
before marking changed content approved. Do not describe the app or curriculum
as Al-Azhar-approved, or imply institutional endorsement, without explicit
written authorization covering that claim.

## Release gate

Only content with a recorded approval for the exact shipped version may be
promoted into `assets/content/catalog.json` for production. Keep unresolved
lessons in the draft catalog, and require
`dart run tool/validate_content.dart --release` before App Store submission.

## Release confirmation recorded on 2026-11-13

The project owner confirmed that Sherif's approval includes the current revised
Arabic wording of Lessons 1 and 13 (lesson content version `1.0.1`), not only the
earlier Desktop Word document. The owner also directed that their aligned English
translations be included in the public release.

Both catalogs record this confirmation and the corresponding lesson snapshot
hashes in their review notes. `reviewedAt` records when the owner confirmed the
approval; it is not an independently verified date of Sherif's review. This record
does not claim a separate English-language academic review or institutional
endorsement.
