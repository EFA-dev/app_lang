import 'package:code_builder/code_builder.dart';
import 'package:code_builder/src/specs/expression.dart';

/// Custom emitter for formatting generated code
class CustomEmitter extends DartEmitter {
  CustomEmitter()
      : super(
          allocator: Allocator.simplePrefixing(),
          orderDirectives: true,
          useNullSafetySyntax: false,
        );

  @override
  StringSink visitReference(Reference spec, [StringSink? output]) {
    output ??= StringBuffer();
    var content = allocator.allocate(spec).replaceAll("// [endregion]", "// endregion");

    return output..write(content);
  }

  @override
  StringSink visitLiteralExpression(LiteralExpression expression, [StringSink? output]) {
    output ??= StringBuffer();
    final escaped = expression.literal;

    if (escaped.startsWith("'") && escaped.endsWith("'")) {
      return output..write('"${escaped.substring(1, escaped.length - 1)}"');
    }

    return output..write(escaped);
  }

  @override
  StringSink visitLiteralRecordExpression(LiteralRecordExpression expression, [StringSink? output]) {
    final out = output ??= StringBuffer();
    out.write('(');
    _visitAll<Object?>(expression.positionalFieldValues, out, (value) {
      _acceptLiteral(value, out);
    });
    if (expression.namedFieldValues.isNotEmpty) {
      if (expression.positionalFieldValues.isNotEmpty) {
        out.write(', ');
      }
    } else if (expression.positionalFieldValues.length == 1) {
      out.write(',');
    }
    _visitAll<MapEntry<String, Object?>>(expression.namedFieldValues.entries, out, (entry) {
      out.write('${entry.key}: ');
      _acceptLiteral(entry.value, out);
    });
    if (expression.namedFieldValues.isNotEmpty) {
      out.write(',');
    }
    return out..write(')');
  }

  /// Helper method improving on [StringSink.writeAll].
  ///
  /// For every `Spec` in [elements], executing [visit].
  ///
  /// If [elements] is at least 2 elements, inserts [separator] delimiting them.
  StringSink _visitAll<T>(
    Iterable<T> elements,
    StringSink output,
    void Function(T) visit, [
    String separator = ', ',
  ]) {
    // Basically, this whole method is an improvement on
    //   output.writeAll(specs.map((s) => s.accept(visitor));
    //
    // ... which would allocate more StringBuffer(s) for a one-time use.
    if (elements.isEmpty) {
      return output;
    }
    final iterator = elements.iterator..moveNext();
    visit(iterator.current);
    while (iterator.moveNext()) {
      output.write(separator);
      visit(iterator.current);
    }
    return output;
  }

  void _acceptLiteral(Object? literalOrSpec, StringSink output) {
    if (literalOrSpec is Spec) {
      literalOrSpec.accept(this, output);
      return;
    }
    literal(literalOrSpec).accept(this, output);
  }
}
