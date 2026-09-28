#!/usr/bin/env python3
"""Export the app curriculum to an editable Arabic teacher-review document.

The export mirrors the learner experience: every label is Arabic, and tables
carry only the fields the app actually renders. Fields that exist in the
curriculum JSON but are never shown to a learner (token spans, unvocalized
forms, option and source identifiers, license metadata) are deliberately
omitted so reviewers assess exactly what ships.
"""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = REPO_ROOT / "content" / "drafts" / "lesson_01.json"
DEFAULT_OUTPUT = (
    REPO_ROOT / "docs" / "review" / "arabic-grammar-curriculum-review.docx"
)

ARABIC_FONT = "Arial"

# Mirrors _TokenCard._grammarState in lesson_detail_screen.dart.
GRAMMAR_STATE_AR = {
    "raf": "رفع",
    "nasb": "نصب",
    "jarr": "جر",
    "jazm": "جزم",
    "indeclinable": "مبني",
}

EXERCISE_TYPE_AR = {
    "addTashkeel": "إضافة التشكيل",
    "chooseEnding": "اختيار العلامة",
    "identifyRole": "تحديد الوظيفة",
    "identifyState": "تحديد الحالة",
    "matchRule": "مطابقة القاعدة",
}

SECTION_TYPE_AR = {
    "introduction": "تمهيد",
    "ruleSummary": "ملخّص القاعدة",
    "workedExample": "مثال محلول",
}

REVIEW_STATUS_AR = {
    "pendingReview": "بانتظار المراجعة",
    "approved": "معتمد",
}

_ARABIC_DIGITS = str.maketrans("0123456789", "٠١٢٣٤٥٦٧٨٩")


def ar_num(value: Any) -> str:
    """Render a number with Arabic-Indic digits, matching the app."""
    return str(value).translate(_ARABIC_DIGITS)


def ar_content_version(value: str) -> str:
    return ar_num(value.replace("-draft.", " — مسودة "))


def ar(value: dict[str, str]) -> str:
    return value["ar"]


def _append_once(properties: Any, tag: str) -> None:
    if properties.find(qn(tag)) is None:
        properties.append(OxmlElement(tag))


def set_rtl(paragraph: Any) -> None:
    paragraph.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    _append_once(paragraph._p.get_or_add_pPr(), "w:bidi")


def style_run(run: Any, *, bold: bool = False, size: Any = None) -> None:
    run.bold = bold
    run.font.name = ARABIC_FONT
    if size is not None:
        run.font.size = size
    properties = run._element.get_or_add_rPr()
    properties.rFonts.set(qn("w:cs"), ARABIC_FONT)
    _append_once(properties, "w:rtl")


def add_paragraph_ar(
    container: Any,
    text: str,
    *,
    style: str | None = None,
    bold: bool = False,
    size: Any = None,
) -> Any:
    paragraph = container.add_paragraph(style=style)
    set_rtl(paragraph)
    style_run(paragraph.add_run(text), bold=bold, size=size)
    return paragraph


def add_heading_ar(document: Document, text: str, level: int) -> Any:
    heading = document.add_heading("", level=level)
    set_rtl(heading)
    style_run(heading.add_run(text))
    return heading


def shade_cell(cell: Any, fill: str) -> None:
    shading = OxmlElement("w:shd")
    shading.set(qn("w:fill"), fill)
    cell._tc.get_or_add_tcPr().append(shading)


def set_cell_text(
    cell: Any,
    text: str,
    *,
    bold: bool = False,
    size: Any = Pt(9),
) -> None:
    cell.text = ""
    paragraph = cell.paragraphs[0]
    set_rtl(paragraph)
    style_run(paragraph.add_run(text), bold=bold, size=size)
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER


def set_table_rtl(table: Any) -> None:
    """Make columns flow right-to-left so column 0 renders rightmost."""
    _append_once(table._tbl.tblPr, "w:bidiVisual")


def add_rtl_table(document: Document, headers: list[str], fill: str) -> Any:
    table = document.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    set_table_rtl(table)
    for index, header in enumerate(headers):
        set_cell_text(table.rows[0].cells[index], header, bold=True)
        shade_cell(table.rows[0].cells[index], fill)
    return table


def add_example(document: Document, example: dict[str, Any]) -> None:
    add_heading_ar(document, "مثال", level=4)
    add_paragraph_ar(document, example["vocalized"], size=Pt(16))

    add_heading_ar(document, "تحليل الكلمات", level=5)
    table = add_rtl_table(
        document,
        ["الكلمة", "الوظيفة", "الحالة", "العلامة", "السبب"],
        fill="FFF2CC",
    )
    for token in example["tokens"]:
        indeclinable = token["grammarState"] == "indeclinable"
        sign = ar(token["grammaticalSign"])
        cells = table.add_row().cells
        values = [
            f"{token['text']}{token['ending']}",
            ar(token["role"]),
            sign if indeclinable else GRAMMAR_STATE_AR[token["grammarState"]],
            "—" if indeclinable else f"{sign} ({token['ending']})",
            ar(token["reason"]),
        ]
        for index, value in enumerate(values):
            set_cell_text(cells[index], value)


def add_exercise(
    document: Document,
    exercise: dict[str, Any],
    number: int,
) -> None:
    add_heading_ar(
        document,
        f"{ar_num(number)}. {EXERCISE_TYPE_AR[exercise['type']]}",
        level=4,
    )
    add_paragraph_ar(document, ar(exercise["prompt"]))
    table = add_rtl_table(
        document,
        ["الإجابة الصحيحة", "الخيار", "التغذية الراجعة"],
        fill="E2F0D9",
    )
    for option in exercise["options"]:
        cells = table.add_row().cells
        values = [
            "✔" if option["isCorrect"] else "",
            ar(option["label"]),
            ar(option["feedback"]),
        ]
        for index, value in enumerate(values):
            set_cell_text(cells[index], value)
        if option["isCorrect"]:
            for cell in cells:
                shade_cell(cell, "E2F0D9")


def add_sources(document: Document, sources: list[dict[str, Any]]) -> None:
    add_heading_ar(document, "المصادر", level=3)
    table = add_rtl_table(
        document,
        ["العنوان", "المؤلف", "الاقتباس"],
        fill="D9EAF7",
    )
    for source in sources:
        cells = table.add_row().cells
        values = [
            ar(source["title"]),
            ar(source["author"]),
            ar(source["citation"]),
        ]
        for index, value in enumerate(values):
            set_cell_text(cells[index], value)


def add_review_worksheet(document: Document, lesson: dict[str, Any]) -> None:
    add_heading_ar(document, "استمارة مراجعة المعلّم", level=3)
    review = lesson["review"]
    status = REVIEW_STATUS_AR.get(review["status"], review["status"])
    add_paragraph_ar(
        document,
        f"الحالة الحالية في التطبيق: {status} | "
        f"إصدار المحتوى: {ar_content_version(review['contentVersion'])}",
    )
    table = document.add_table(rows=0, cols=2)
    table.style = "Table Grid"
    set_table_rtl(table)
    fields = [
        ("القرار", "اعتماد / اعتماد مع تعديلات / إعادة للمراجعة"),
        ("اسم المراجع ومؤهلاته", ""),
        ("تاريخ المراجعة", ""),
        ("التصويبات المطلوبة", ""),
        ("التوصيات الاختيارية", ""),
        ("التوقيع أو الأحرف الأولى للاعتماد", ""),
    ]
    for label, value in fields:
        row = table.add_row()
        set_cell_text(row.cells[0], label, bold=True)
        set_cell_text(row.cells[1], value)
        row.height = Inches(1.0 if label == "التصويبات المطلوبة" else 0.45)


def add_lesson(
    document: Document,
    lesson: dict[str, Any],
    level: dict[str, Any],
    lessons_by_id: dict[str, dict[str, Any]],
) -> None:
    add_heading_ar(
        document,
        f"الدرس {ar_num(lesson['order'])}: {ar(lesson['title'])}",
        level=1,
    )
    prerequisites = (
        "، ".join(
            ar(lessons_by_id[lesson_id]["title"])
            for lesson_id in lesson["prerequisites"]
        )
        or "لا يوجد"
    )
    add_paragraph_ar(
        document,
        f"المستوى: {ar(level['title'])} | "
        f"الزمن التقديري: {ar_num(lesson['estimatedMinutes'])} دقيقة | "
        f"المتطلبات السابقة: {prerequisites}",
    )

    add_heading_ar(document, "الأهداف", level=3)
    for objective in lesson["objectives"]:
        add_paragraph_ar(document, ar(objective), style="List Bullet")

    add_heading_ar(document, "الشرح والأمثلة", level=2)
    for section in lesson["sections"]:
        add_heading_ar(
            document,
            f"{ar(section['title'])} ({SECTION_TYPE_AR[section['type']]})",
            level=3,
        )
        add_paragraph_ar(document, ar(section["body"]))
        for example in section["examples"]:
            add_example(document, example)

    add_heading_ar(document, "التمارين الأساسية", level=2)
    for number, exercise in enumerate(lesson["exercises"], start=1):
        add_exercise(document, exercise, number)

    add_heading_ar(document, "تمارين المراجعة البديلة", level=2)
    for number, exercise in enumerate(lesson["repeatExercises"], start=1):
        add_exercise(document, exercise, number)

    add_sources(document, lesson["sources"])
    add_review_worksheet(document, lesson)


def configure_document(document: Document) -> None:
    styles = document.styles
    headings = ["Heading 1", "Heading 2", "Heading 3", "Heading 4", "Heading 5"]
    for name in ["Normal", "Title", *headings]:
        style = styles[name]
        style.font.name = ARABIC_FONT
        style.element.get_or_add_rPr().get_or_add_rFonts().set(
            qn("w:cs"), ARABIC_FONT
        )
    styles["Normal"].font.size = Pt(10)
    styles["Title"].font.size = Pt(26)
    styles["Title"].font.color.rgb = RGBColor(20, 75, 110)
    for name in headings:
        styles[name].font.color.rgb = RGBColor(20, 75, 110)

    for section in document.sections:
        section.top_margin = Inches(0.65)
        section.bottom_margin = Inches(0.65)
        section.left_margin = Inches(0.65)
        section.right_margin = Inches(0.65)


def add_front_matter(
    document: Document,
    catalog: dict[str, Any],
    generated_at: datetime,
) -> None:
    add_heading_ar(document, "وثيقة مراجعة منهج إعراب", level=0)
    add_paragraph_ar(
        document,
        "نسخة قابلة للتحرير لمراجعة المعلّمين، مُولّدة مباشرة من ملف المنهج "
        "نفسه المضمَّن في التطبيق. تقتصر هذه الوثيقة على ما يظهر للمتعلّم "
        "داخل التطبيق.",
    )
    metadata = [
        ("إصدار المنهج", ar_content_version(catalog["contentVersion"])),
        ("إصدار المخطط", ar_num(catalog["schemaVersion"])),
        ("عدد المستويات", ar_num(len(catalog["levels"]))),
        ("عدد الدروس", ar_num(len(catalog["lessons"]))),
        (
            "تاريخ التوليد",
            ar_num(generated_at.strftime("%Y-%m-%d %H:%M"))
            + " بالتوقيت العالمي المنسق",
        ),
    ]
    table = document.add_table(rows=0, cols=2)
    table.style = "Table Grid"
    set_table_rtl(table)
    for label, value in metadata:
        cells = table.add_row().cells
        set_cell_text(cells[0], label, bold=True)
        set_cell_text(cells[1], value)

    add_heading_ar(document, "إرشادات المراجعة", level=1)
    for instruction in [
        "استخدم تعليقات مايكروسوفت وورد لإبداء الملاحظات المرتبطة بصياغة بعينها.",
        "استخدم خاصية تتبّع التغييرات لاقتراح النص البديل.",
        "راجع التمارين الأساسية وتمارين المراجعة معًا؛ فكلاهما يظهر في التطبيق.",
        "تحقّق من كل إجابة مُعلَّمة بأنها صحيحة، ومن جميع رسائل التغذية الراجعة "
        "بما فيها رسائل الإجابات الخاطئة.",
        "سجّل التصويبات المطلوبة وقرار الاعتماد في استمارة المراجعة لكل درس.",
        "لا يجوز اعتماد محتوى التطبيق للنشر قبل اكتمال مراجعة مختص.",
    ]:
        add_paragraph_ar(document, instruction, style="List Bullet")

    add_heading_ar(document, "فهرس المنهج", level=1)
    lessons_by_id = {lesson["id"]: lesson for lesson in catalog["lessons"]}
    for level in catalog["levels"]:
        add_heading_ar(document, ar(level["title"]), level=2)
        add_paragraph_ar(document, ar(level["description"]))
        for lesson_id in level["lessonIds"]:
            lesson = lessons_by_id[lesson_id]
            add_paragraph_ar(
                document,
                f"{ar_num(lesson['order'])}. {ar(lesson['title'])}",
            )
    document.add_page_break()


def add_header(document: Document, content_version: str) -> None:
    header = document.sections[0].header.paragraphs[0]
    header.text = ""
    set_rtl(header)
    header.alignment = WD_ALIGN_PARAGRAPH.CENTER
    style_run(
        header.add_run(
            f"مراجعة منهج إعراب — {ar_content_version(content_version)}"
        )
    )


def apply_section_rtl(document: Document) -> None:
    """Every lesson starts a new section; all of them must be RTL."""
    for section in document.sections:
        _append_once(section._sectPr, "w:bidi")


def export(source_path: Path, output_path: Path) -> None:
    source_bytes = source_path.read_bytes()
    catalog = json.loads(source_bytes)
    generated_at = datetime.now(timezone.utc)
    levels_by_lesson = {
        lesson_id: level
        for level in catalog["levels"]
        for lesson_id in level["lessonIds"]
    }
    lessons_by_id = {lesson["id"]: lesson for lesson in catalog["lessons"]}

    document = Document()
    configure_document(document)
    add_front_matter(document, catalog, generated_at)
    for index, lesson in enumerate(catalog["lessons"]):
        add_lesson(
            document,
            lesson,
            levels_by_lesson[lesson["id"]],
            lessons_by_id,
        )
        if index < len(catalog["lessons"]) - 1:
            document.add_section(WD_SECTION.NEW_PAGE)
    add_header(document, catalog["contentVersion"])
    apply_section_rtl(document)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    document.save(output_path)
    print(
        f"Exported {len(catalog['lessons'])} lessons from "
        f"{catalog['contentVersion']} to {output_path}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    export(args.source.resolve(), args.output.resolve())
