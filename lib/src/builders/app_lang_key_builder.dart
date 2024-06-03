import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:app_lang/app_lang.dart';
import 'package:app_lang/src/generators/app_lang_key_generator.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

// region [p]
class AppLangKeyBuilder extends GeneratorForAnnotation<AppLangConfig> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep, includeValues: false);
    if (sourceTree == null) {
      return null;
    }

    ///* Get the key class name
    final keyClassName = annotation.read("keyClassName").stringValue;

    ///* Generate the key file
    var keyBuilder = AppLangKeyGenerator(
      fieldTree: sourceTree,
      className: keyClassName,
    );
    var fileContent = keyBuilder.build();

    ///* Write the generated key file
    var newPath = p.withoutExtension(buildStep.inputId.path).replaceAll(".importer", "");
    var filePath = p.setExtension(newPath, ".key.dart");
    var sourceFile = File(filePath);
    sourceFile.writeAsString(fileContent);
  }
}

// endregion
