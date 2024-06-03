import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]
/// Generates paths for keys
class AppLangKeyGenerator {
  AppLangKeyGenerator({required this.fieldTree, this.className = "AppLang"});

  final FieldTree fieldTree;
  final String className;

  String build() {
    var library = Library(
      (library) => library
        ..body.addAll(
          [
            refer("// region [p] \n\n"),
            Class(
              (c) => c
                ..name = className
                ..fields.addAll(_buildField()),
            ),
            refer("\n // [endregion]")
          ],
        ),
    );

    return Formatter.format(library);
  }

  ///Builds Record type fields
  List<Field> _buildField() {
    return fieldTree.fields.map((field) {
      return Field(
        (p0) => p0
          ..modifier = FieldModifier.constant
          ..static = true
          ..name = field.name
          ..assignment = literalRecord([], _buildSubField(field.children)).code,
      );
    }).toList();
  }

  ///Builds fields children
  Map<String, dynamic> _buildSubField(List<FieldNode> children) {
    var map = <String, dynamic>{};

    var test = children.map((field) {
      if (field.children.isEmpty) {
        return MapEntry(field.name, field.path);
      } else {
        return MapEntry(field.name, literalRecord([], _buildSubField(field.children)));
      }
    });

    map.addEntries(test);

    return map;
  }
}

// endregion
