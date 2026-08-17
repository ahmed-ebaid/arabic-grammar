import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/glossary_models.dart';

class GlossaryRepository {
  const GlossaryRepository();

  Future<GlossaryCatalog> load() async {
    final source = await rootBundle.loadString('assets/content/glossary.json');
    return GlossaryCatalog.fromJson(jsonDecode(source));
  }
}
