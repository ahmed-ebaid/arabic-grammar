import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_repository.dart';
import '../models/glossary_models.dart';

class GlossaryRepository {
  const GlossaryRepository({this.previewUnreviewed = previewUnreviewedContent});

  final bool previewUnreviewed;

  Future<GlossaryCatalog> load() async {
    final source = await rootBundle.loadString(
      previewUnreviewed
          ? 'content/drafts/glossary/catalog.json'
          : 'assets/content/glossary.json',
    );
    return GlossaryCatalog.fromJson(jsonDecode(source));
  }
}
