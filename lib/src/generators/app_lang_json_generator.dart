import 'dart:convert';

import 'package:app_lang/src/models/field_tree.dart';
// region [p]

///Generates JSON files from the given FieldTree
class AppLangJsonGenerator {
  AppLangJsonGenerator({
    required this.fieldTree,
    required this.root,
    required this.prefix,
  });

  final FieldTree fieldTree;
  final String root;
  final String prefix;

  Set<String> get locales => fieldTree.locales;

  ///Builds JSON files from the given FieldTree
  Map<String, String> build() {
    var files = <String, String>{};

    for (var locale in locales) {
      var filePath = '$root/$prefix.$locale.json';

      var map = _buildField(locale);

      var formatted = prettyJson(map);

      files[filePath] = formatted;
    }

    return files;
  }

  ///Builds Root fields
  Map<String, dynamic> _buildField(String locale) {
    var map = <String, dynamic>{};

    var mapEntries = fieldTree.fields.map((field) {
      return MapEntry(
        field.name,
        _buildSubField(field.children, locale),
      );
    }).toList();

    map.addEntries(mapEntries);

    return map;
  }

  ///Builds Children fields
  dynamic _buildSubField(List<FieldNode> children, String locale) {
    var map = <String, dynamic>{};

    for (var field in children) {
      if (field.valueNode && field.name == locale) {
        return field.value;
      } else {
        MapEntry<String, Object?> mapEntry;
        mapEntry = MapEntry(field.name, _buildSubField(field.children, locale));
        map.addEntries([mapEntry]);
      }
    }

    return map;
  }

  /// Formats the given JSON object with indentation for better readability.
  String prettyJson(dynamic json, {int indent = 2}) {
    var spaces = ' ' * indent;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }
}

// endregion
