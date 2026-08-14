import 'package:flutter/services.dart';

import '../models/content_models.dart';
import 'content_decoder.dart';
import 'content_validator.dart';

class ContentRepository {
  const ContentRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/content/catalog.json';

  final String assetPath;

  Future<ContentCatalog> load() async {
    final source = await rootBundle.loadString(assetPath);
    final catalog = ContentDecoder.decode(source);
    final issues = ContentValidator.validate(
      catalog,
      requireReleaseApproval: true,
    );
    if (issues.isNotEmpty) {
      throw FormatException('Invalid bundled content:\n${issues.join('\n')}');
    }
    return catalog;
  }
}
