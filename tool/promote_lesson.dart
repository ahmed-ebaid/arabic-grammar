import 'dart:convert';
import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/content/content_validator.dart';

Future<void> main(List<String> arguments) async {
  final sourceArgument = arguments
      .where((argument) => argument.startsWith('--source='))
      .firstOrNull;
  if (sourceArgument == null) {
    stderr.writeln(
      'Usage: dart run tool/promote_lesson.dart '
      '--source=content/drafts/lesson_01.json',
    );
    exitCode = 64;
    return;
  }

  final sourceFile = File(sourceArgument.substring('--source='.length));
  if (!sourceFile.existsSync()) {
    stderr.writeln('Lesson source does not exist: ${sourceFile.path}');
    exitCode = 66;
    return;
  }

  final sourceText = await sourceFile.readAsString();
  final sourceCatalog = ContentDecoder.decode(sourceText);
  final issues = ContentValidator.validate(
    sourceCatalog,
    requireReleaseApproval: true,
  );
  if (issues.isNotEmpty) {
    stderr.writeln('Lesson cannot be promoted:');
    for (final issue in issues) {
      stderr.writeln('  $issue');
    }
    exitCode = 1;
    return;
  }
  if (sourceCatalog.lessons.length != 1) {
    stderr.writeln('A promotion source must contain exactly one lesson.');
    exitCode = 1;
    return;
  }

  final releaseFile = File('assets/content/catalog.json');
  final releaseJson =
      jsonDecode(await releaseFile.readAsString()) as Map<String, Object?>;
  final sourceJson = jsonDecode(sourceText) as Map<String, Object?>;
  final sourceLesson =
      (sourceJson['lessons'] as List<Object?>).single as Map<String, Object?>;
  final sourceId = sourceLesson['id'];
  final releaseLessons = (releaseJson['lessons'] as List<Object?>)
      .cast<Map<String, Object?>>();

  releaseLessons.removeWhere((lesson) => lesson['id'] == sourceId);
  releaseLessons.add(sourceLesson);
  releaseLessons.sort(
    (first, second) =>
        (first['order'] as int).compareTo(second['order'] as int),
  );
  releaseJson['contentVersion'] = sourceJson['contentVersion'];
  releaseJson['lessons'] = releaseLessons;

  final promotedCatalog = ContentDecoder.decode(jsonEncode(releaseJson));
  final promotedIssues = ContentValidator.validate(
    promotedCatalog,
    requireReleaseApproval: true,
  );
  if (promotedIssues.isNotEmpty) {
    stderr.writeln('Resulting release catalog is invalid:');
    for (final issue in promotedIssues) {
      stderr.writeln('  $issue');
    }
    exitCode = 1;
    return;
  }

  const encoder = JsonEncoder.withIndent('  ');
  await releaseFile.writeAsString('${encoder.convert(releaseJson)}\n');
  stdout.writeln('PROMOTED $sourceId to ${releaseFile.path}');
}
