import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/utils/formatter.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';

//#region [p]
///* Generates easy_localization loader
class AppLangLoaderGenerator {
  AppLangLoaderGenerator({
    required this.fieldTree,
  });

  final FieldTree fieldTree;
  Set<String> get locales => fieldTree.locales;

  String build() {
    var library = Library(
      (library) => library
        ..ignoreForFile.add("constant_identifier_names")
        ..directives.addAll(
          [
            Directive.import("dart:ui"),
            Directive.import("package:easy_localization/easy_localization.dart"),
          ],
        )
        ..body.addAll(
          [
            refer("\n\n// region [p] \n\n"),
            Class(
              (c) => c
                ..name = 'AppLangLoader'
                ..extend = refer('AssetLoader')
                ..constructors = ListBuilder(
                  [
                    Constructor(
                      (b) => b..constant = true,
                    ),
                  ],
                )
                ..methods.add(
                  Method(
                    (MethodBuilder b) => b
                      ..name = 'load'
                      ..annotations.add(refer("override"))
                      ..returns = refer("Future<Map<String, dynamic>?>")
                      ..requiredParameters = ListBuilder<Parameter>([
                        Parameter(
                          (p) => p
                            ..name = "path"
                            ..type = refer("String"),
                        ),
                        Parameter(
                          (p) => p
                            ..name = "locale"
                            ..type = refer("Locale"),
                        ),
                      ])
                      ..body = const Code("return Future.value(mapLocales[locale.toString()]);"),
                  ),
                )
                ..fields.addAll([
                  Field(
                    (p0) => p0
                      ..modifier = FieldModifier.constant
                      ..static = true
                      ..type = refer("Map<String, Map<String, dynamic>>")
                      ..name = "mapLocales"
                      ..assignment = literalMap(_buildLocales()).code,
                  ),
                  ...locales.map(
                    (locale) => Field(
                      (p0) => p0
                        ..modifier = FieldModifier.constant
                        ..static = true
                        ..type = refer("Map<String, dynamic>")
                        ..name = locale
                        ..assignment = literalMap(_buildField(locale)).code,
                    ),
                  ),
                ]),
            ),
            refer("\n // [endregion]"),
          ],
        ),
    );

    return Formatter.format(library);
  }

  /// Build locales map
  Map<String, dynamic> _buildLocales() {
    var map = <String, dynamic>{};

    var mapEntries = locales.map((locale) => MapEntry(locale, refer(locale)));
    map.addEntries(mapEntries);

    return map;
  }

  ///Builds Record type fields
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

  ///Builds sub children
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
}

//#endregion

