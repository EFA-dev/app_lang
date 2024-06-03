import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:app_lang/app_lang.dart';
import 'package:app_lang/src/generators/app_lang_json_generator.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

// region [p]

class AppLangJsonBuilder extends GeneratorForAnnotation<AppLangConfig> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    ///* Check if the jsonExport annotation is true
    var exportJson = annotation.read("json").boolValue;
    if (exportJson == false) return null;

    ///* Remove the locale file
    var locale = annotation.peek("remove")?.stringValue;
    if (locale != null) {
      var jsonFilePath = p.setExtension(p.withoutExtension(buildStep.inputId.path), ".$locale.json");
      var file = File(jsonFilePath);
      if (file.existsSync()) {
        file.delete();
      }
    }

    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep);
    if (sourceTree == null) {
      return null;
    }

    ///* Generate the json files
    var file = File(buildStep.inputId.path);
    var jsonGenerator = AppLangJsonGenerator(
      fieldTree: sourceTree,
      root: file.parent.path,
      prefix: buildStep.inputId.pathSegments.last.split('.').first,
    );
    var files = jsonGenerator.build();

    ///* Write the generated json files
    files.forEach((filePath, fileContent) {
      var sourceFile = File(filePath);
      sourceFile.writeAsString(fileContent);
    });
  }
}

// endregion
