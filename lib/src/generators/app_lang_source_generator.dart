import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]
/// Regenerate the source file after importing or remove a locale
class AppLangSourceGenerator {
  AppLangSourceGenerator({
    required this.fieldTree,
    required this.className,
  });

  final FieldTree fieldTree;
  final String className;

  String build() {
    var library = Library(
      (lib) => lib
        ..ignoreForFile.addAll(["non_constant_identifier_names", "type_annotate_public_apis"])
        ..directives.addAll([
          Directive.import("package:app_lang/app_lang.dart"),
        ])
        ..body.addAll(
          [
            refer("\n\n// region [p] \n\n"),
            Class(
              (c) => c
                ..annotations.addAll(fieldTree.annotations.map((a) => CodeExpression(Code(a.toSource().replaceFirst("@", "")))))
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
        return MapEntry(field.name, field.value);
      } else {
        return MapEntry(field.name, literalRecord([], _buildSubField(field.children)));
      }
    });

    map.addEntries(test);

    return map;
  }
}

// endregion
