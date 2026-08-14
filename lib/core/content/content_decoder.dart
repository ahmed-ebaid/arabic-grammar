import 'dart:convert';

import '../models/content_models.dart';

abstract final class ContentDecoder {
  static ContentCatalog decode(String source) {
    final value = jsonDecode(source);
    return ContentCatalog.fromJson(value);
  }
}
