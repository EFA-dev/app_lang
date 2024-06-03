import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:app_lang/annotations/app_lang_config.dart';
import 'package:app_lang/src/utils/reserved.dart';
import 'package:app_lang/src/visitors/file_visitor.dart';
import 'package:app_lang/src/visitors/map_visitor.dart';
import 'package:build/build.dart';

// region [p]
class FieldTree {
  ///* The list of fields in the tree
  List<FieldNode> fields = [];

  ///* The set of locales in the tree
  Set<String> locales = <String>{};

  ///* The list of annotations in the source file
  List<Annotation> annotations = [];

  ///* The map of value fields in the tree
  ///* The key is the path of the value field
  ///* The value is the FieldNode of the value field
  final Map<String, FieldNode> _valueFields = <String, FieldNode>{};

  ///* Builds the FieldTree from the AST
  static Future<FieldTree?> fromAst(BuildStep buildStep, {String? exclude, bool includeValues = true}) async {
    ///* Get the class node
    var unit = await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    var classNodes = unit.declarations.whereType<ClassDeclaration>();

    ///* If the class is not found, return
    if (classNodes.isEmpty) {
      print("ERROR: Class not found in file: ${buildStep.inputId.path}");
      return null;
    }

    var classNode = classNodes.first;
    var sourceTree = FieldTree();

    ///* Add all annotations to the keyTree
    var annotations = classNode.childEntities.whereType<Annotation>();
    sourceTree.annotations.addAll(annotations);

    ///* Add all fields to the keyTree
    var fieldVisitor = FileVisitor(root: sourceTree, exclude: exclude, addValueField: includeValues);

    classNode.visitChildren(fieldVisitor);

    return sourceTree;
  }

  ///* Builds the FieldTree from the given JSON file
  ///* If the file is not found, return null
  ///* If the file is empty, return null
  static Future<FieldTree?> fromJson(Import? import) async {
    if (import == null) {
      return null;
    }

    ///* Create a file object from the path
    var jsonFile = File(import.path);

    ///* Check if the file exists
    if (jsonFile.existsSync() == false) {
      print("ERROR: File not found: ${import.path}");
      return null;
    }

    ///* Read the JSON file
    var fileContent = await jsonFile.readAsString();
    var json = jsonDecode(fileContent) as Map<String, dynamic>;

    ///* Check if the JSON file is empty
    if (json.isEmpty) {
      print("ERROR: JSON file is empty: ${import.path}");
      return null;
    }

    ///* Build the field tree from the JSON file
    var fieldTree = MapVisitor(
      mapData: json,
      locale: import.locale,
    ).visit();

    return fieldTree;
  }

  ///* Combine the new tree with the current tree
  ///* If the new tree is null, return the current tree
  ///* If the current tree is empty, return the new tree
  FieldTree combine(FieldTree? newTree) {
    if (newTree == null) {
      return this;
    }

    if (_valueFields.isEmpty) {
      newTree.annotations.addAll(annotations);
      return newTree;
    }

    for (var field in _valueFields.entries) {
      var targetNode = newTree.findValueField(field.key);
      if (targetNode != null) {
        field.value.parent?.children.add(targetNode);
      }
    }

    return this;
  }

  ///* Find the value field in the tree
  FieldNode? findValueField(String path) {
    return _valueFields[path];
  }

  ///* Add a value field to the tree
  void addValueField({required String path, required FieldNode fieldNode}) {
    _valueFields.addEntries([MapEntry(path, fieldNode)]);

    if (reservedWords.contains(fieldNode.name)) return;
    locales.add(fieldNode.name);
  }
}
// endregion

// region [p]

///* The node of a field in the tree
class FieldNode {
  final String name;
  final String path;
  final FieldNode? parent;
  String? value;
  bool valueNode;
  List<FieldNode> children = [];

  FieldNode({
    required this.name,
    required this.path,
    this.parent,
    this.value,
    this.valueNode = false,
  });
}

// endregion
