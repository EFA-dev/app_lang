import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:app_lang/app_lang.dart';
import 'package:app_lang/src/generators/app_lang_source_generator.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

// region [p]

class AppLangImportBuilder extends GeneratorForAnnotation<AppLangConfig> {
  @override
  Future<String?> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    var exclude = annotation.peek("remove")?.stringValue;

    var importFields = annotation.peek("import")?.objectValue;
    var importLocale = importFields?.getField("locale")?.toStringValue();
    var path = importFields?.getField("path")?.toStringValue();

    Import? import;
    if (exclude == null && importLocale != null && path != null) {
      import = Import(
        locale: importLocale,
        path: path,
      );
    }

    ///* Build the FieldTree from the JSON file
    var jsonFieldTree = await FieldTree.fromJson(import);

    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep, exclude: exclude);

    ///* If both trees are null, return null
    if (sourceTree == null && jsonFieldTree == null) {
      print("ERROR: No fields found in the source file or the JSON file");
      return null;
    }

    ///* Combine the sourceTree with the jsonFieldTree
    ///* If the sourceTree is null, use the jsonFieldTree
    var combinedFieldTree = sourceTree == null ? jsonFieldTree! : sourceTree.combine(jsonFieldTree);

    ///* Generate the source file
    var appLangSourceGenerator = AppLangSourceGenerator(
      fieldTree: combinedFieldTree,
      className: element.displayName,
    );

    ///* Write the generated source file
    var sourceFile = File(buildStep.inputId.path);
    var fileContent = appLangSourceGenerator.build();
    sourceFile.writeAsStringSync(fileContent);

    return fileContent;
  }
}

// endregion
