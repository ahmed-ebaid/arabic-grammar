import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/content/content_validator.dart';

Future<void> main(List<String> arguments) async {
  final requireReleaseApproval = arguments.contains('--release');
  final directory = Directory('content/drafts');
  if (!directory.existsSync()) {
    stderr.writeln('Missing content directory: ${directory.path}');
    exitCode = 1;
    return;
  }

  final files =
      directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((first, second) => first.path.compareTo(second.path));
  if (files.isEmpty) {
    stderr.writeln('No lesson JSON files found in ${directory.path}');
    exitCode = 1;
    return;
  }

  var hasErrors = false;
  for (final file in files) {
    try {
      final catalog = ContentDecoder.decode(await file.readAsString());
      final issues = ContentValidator.validate(
        catalog,
        requireReleaseApproval: requireReleaseApproval,
      );
      if (issues.isEmpty) {
        stdout.writeln('VALID ${file.path}');
        continue;
      }

      hasErrors = true;
      stderr.writeln('INVALID ${file.path}');
      for (final issue in issues) {
        stderr.writeln('  $issue');
      }
    } on FormatException catch (error) {
      hasErrors = true;
      stderr.writeln('INVALID ${file.path}');
      stderr.writeln('  ${error.message}');
    }
  }

  if (hasErrors) {
    exitCode = 1;
  }
}
