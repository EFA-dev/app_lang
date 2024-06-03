import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:app_lang/annotations/app_lang_config.dart';
import 'package:app_lang/src/generators/app_lang_source_generator.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/visitors/file_visitor.dart';
import 'package:app_lang/src/visitors/map_visitor.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
// region [p]

void main() {
  String filePath = absolute("test/lang/app_lang_source.import.dart");

  test("Test for import", () {
    final collection = AnalysisContextCollection(includedPaths: [filePath]);
    final analysisSession = collection.contextFor(filePath).currentSession;
    var result = analysisSession.getParsedUnit(filePath);

    if (result is ParsedUnitResult) {
      CompilationUnit unit = result.unit;
      var classNode = unit.declarations.whereType<ClassDeclaration>().first;

      var fieldTree = FieldTree();
      var fieldVisitor = FileVisitor(root: fieldTree);
      classNode.visitChildren(fieldVisitor);

      var appLangSourceGenerator = AppLangSourceGenerator(
        fieldTree: fieldTree,
        className: "AppLangSource",
      ).build();

      print(appLangSourceGenerator);
    }
  });

  test('Test for map to field tree', () async {
    var import = Import(locale: "tr_TR", path: "test/lang/tr_TR.json");

    ///* Build the FieldTree from the JSON file
    var jsonFieldTree = await FieldTree.fromJson(import);

    if (jsonFieldTree == null) {
      print("ERROR: No fields found in the JSON file");
      return;
    }

    ///* Generate the source file
    var appLangSourceGenerator = AppLangSourceGenerator(
      fieldTree: jsonFieldTree,
      className: "AppLangSource",
    );

    var fileContent = appLangSourceGenerator.build();
    print(fileContent);
  });

  test('Test for map to combine', () async {
    var file = File(filePath);

    var fileContent = await file.readAsString();
    var json = jsonDecode(fileContent);

    var sourceTree = MapVisitor(mapData: json, locale: "tr_TR").visit();
    var jsonTree = MapVisitor(mapData: json, locale: "en_US").visit();

    var combinedFieldTree = sourceTree.combine(jsonTree);
    print(combinedFieldTree);
  });
}

// endregion
