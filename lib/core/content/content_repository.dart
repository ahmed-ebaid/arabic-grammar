import 'package:flutter/services.dart';

import '../models/content_models.dart';
import 'content_decoder.dart';
import 'content_validator.dart';

const previewUnreviewedContent = bool.fromEnvironment(
  'PREVIEW_UNREVIEWED_CONTENT',
  defaultValue: false,
);

class ContentRepository {
  const ContentRepository({
    this.previewUnreviewed = previewUnreviewedContent,
    this.assetPath,
  });

  static const _defaultAssetPath = 'assets/content/catalog.json';
  static const _draftAssetPath = 'content/drafts/lesson_01.json';

  final bool previewUnreviewed;
  final String? assetPath;

  Future<ContentCatalog> load() async {
    final source = await rootBundle.loadString(
      assetPath ?? (previewUnreviewed ? _draftAssetPath : _defaultAssetPath),
    );
    final catalog = ContentDecoder.decode(source);
    final issues = ContentValidator.validate(
      catalog,
      requireReleaseApproval: !previewUnreviewed,
    );
    if (issues.isNotEmpty) {
      throw FormatException('Invalid bundled content:\n${issues.join('\n')}');
    }

    return catalog;
  }
}
