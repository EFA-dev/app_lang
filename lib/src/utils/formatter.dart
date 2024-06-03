import 'package:app_lang/src/utils/emitter.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

// region [p]
///* Formats the generated code with custom emitter
class Formatter {
  static String format(Library library) {
    final emitter = CustomEmitter();
    return DartFormatter().format('${library.accept(emitter)}');
  }
}
// endregion
