import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/utils/reserved.dart';

// region [p]

class FileVisitor extends GeneralizingAstVisitor<void> {
  FileVisitor({
    required this.root,
    this.exclude,
    this.addValueField = true,
  });

  final FieldTree root;
  final bool addValueField;
  final String? exclude;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (VariableDeclaration field in node.fields.variables) {
      if (field.initializer.runtimeType != RecordLiteralImpl) continue;

      var keyNode = FieldNode(
        name: field.name.lexeme,
        path: field.name.lexeme,
      );

      var record = field.initializer as RecordLiteral;
      var namedExpressions = record.childEntities.whereType<NamedExpression>().toList();

      for (var field in namedExpressions) {
        var fieldName = field.name.label.name;
        var subRecords = field.childEntities.whereType<RecordLiteralImpl>().toList();

        var parentNode = FieldNode(
          parent: keyNode,
          name: fieldName,
          path: "${keyNode.path}.$fieldName",
        );

        ///* Add sub nodes
        for (var subRecord in subRecords) {
          _buildRecord(parentNode, subRecord);
        }

        keyNode.children.add(parentNode);
      }

      root.fields.add(keyNode);
    }

    super.visitFieldDeclaration(node);
  }

  void _buildRecord(FieldNode parent, RecordLiteral record) {
    var namedExpressions = record.childEntities.whereType<NamedExpression>().toList();

    for (var field in namedExpressions) {
      var fieldName = field.name.label.name;
      var subRecords = field.childEntities.whereType<RecordLiteralImpl>().toList();

      ///* Exclude reserved words
      if (addValueField == false && reservedWords.contains(fieldName)) continue;

      if (subRecords.isNotEmpty) {
        ///* Add sub nodes
        var valueParent = FieldNode(
          name: fieldName,
          path: "${parent.path}.$fieldName",
          parent: parent,
        );

        for (var subRecord in subRecords) {
          _buildRecord(valueParent, subRecord);
        }

        parent.children.add(valueParent);
      } else {
        if (addValueField == false || fieldName == exclude) continue;

        var stringNode = field.childEntities.whereType<SimpleStringLiteral>().toList();

        ///* Add value node
        if (stringNode.isNotEmpty) {
          var valueNode = FieldNode(
            name: fieldName,
            value: stringNode.first.value,
            path: "${parent.path}.$fieldName",
            parent: parent,
            valueNode: true,
          );

          parent.children.add(valueNode);
          root.addValueField(path: parent.path, fieldNode: valueNode);
        }
      }
    }
  }
}

// endregion
