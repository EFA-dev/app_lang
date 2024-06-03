// 1
import 'package:app_lang/src/builders/app_lang_import_builder.dart';
import 'package:app_lang/src/builders/app_lang_json_builder.dart';
import 'package:app_lang/src/builders/app_lang_key_builder.dart';
import 'package:app_lang/src/builders/app_lang_loader_builder.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder appLangImportBuilder(BuilderOptions options) => LibraryBuilder(AppLangImportBuilder(), generatedExtension: '.importer.dart');
Builder appLangLoaderBuilder(BuilderOptions options) => LibraryBuilder(AppLangLoaderBuilder(), generatedExtension: '.loader.dart');
Builder appLangKeyBuilder(BuilderOptions options) => LibraryBuilder(AppLangKeyBuilder(), generatedExtension: '.key.dart');
Builder appLangJsonBuilder(BuilderOptions options) => LibraryBuilder(AppLangJsonBuilder(), generatedExtension: '.json');
