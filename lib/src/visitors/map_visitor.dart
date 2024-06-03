import 'package:app_lang/src/models/field_tree.dart';
// region [p]

class MapVisitor {
  final Map<String, dynamic> mapData;
  final String locale;

  MapVisitor({required this.mapData, required this.locale});

  FieldTree visit() {
    var fieldTree = FieldTree();

    /// Create a FieldNode for each entry in the map
    /// If the value is a map, create a FieldNode for each entry in the map
    /// If the value is not a map, create a FieldNode with the value
    for (var field in mapData.entries) {
      if (field.value is Map) {
        var parentNode = FieldNode(
          name: field.key,
          path: field.key,
        );

        for (var subField in field.value.entries) {
          parentNode.children.add(_buildSubField(parentNode, subField, fieldTree));
        }

        fieldTree.fields.add(parentNode);
      } else {
        var parentNode = FieldNode(
          name: field.key,
          path: field.key,
        );

        var valueNode = FieldNode(
          parent: parentNode,
          name: locale,
          path: "${field.key}.$locale",
          value: field.value.toString(),
          valueNode: true,
        );

        parentNode.children = [valueNode];

        fieldTree.fields.add(parentNode);
        fieldTree.addValueField(path: parentNode.path, fieldNode: valueNode);
      }
    }

    return fieldTree;
  }

  FieldNode _buildSubField(FieldNode parent, MapEntry<String, dynamic> field, FieldTree fieldTree) {
    if (field.value is Map) {
      var parentNode = FieldNode(
        name: field.key,
        path: "${parent.path}.${field.key}",
        parent: parent,
      );

      for (var subField in field.value.entries) {
        parentNode.children.add(_buildSubField(parentNode, subField, fieldTree));
      }

      return parentNode;
    } else {
      var parentNode = FieldNode(
        name: field.key,
        path: "${parent.path}.${field.key}",
        parent: parent,
      );

      var valueNode = FieldNode(
        parent: parentNode,
        name: locale,
        path: "${parent.path}.${field.key}.$locale",
        value: field.value.toString(),
        valueNode: true,
      );

      parentNode.children = [valueNode];
      fieldTree.addValueField(path: parentNode.path, fieldNode: valueNode);

      return parentNode;
    }
  }
}

// endregion
