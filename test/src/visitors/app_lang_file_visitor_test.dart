import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:app_lang/src/models/field_tree.dart';
import 'package:app_lang/src/visitors/file_visitor.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// region [p]
void main() {
  test('ast', () async {
    var filePath = path.absolute('test/lang/app_lang_source.dart');

    final collection = AnalysisContextCollection(includedPaths: [filePath]);
    final analysisSession = collection.contextFor(filePath).currentSession;
    var result = analysisSession.getParsedUnit(filePath);

    if (result is ParsedUnitResult) {
      CompilationUnit unit = result.unit;
      var classList = unit.declarations.whereType<ClassDeclaration>();

      if (classList.isNotEmpty) {
        var classNode = classList.first;

        var keyTree = FieldTree();
        var annotations = classNode.childEntities.whereType<Annotation>();

        ///* Add all annotations to the keyTree
        keyTree.annotations.addAll(annotations);

        ///* Add all fields to the keyTree
        var fieldVisitor = FileVisitor(root: keyTree, addValueField: true);
        classNode.visitChildren(fieldVisitor);
        print(keyTree.fields.length);
      }
    }
  });
}

// endregion
