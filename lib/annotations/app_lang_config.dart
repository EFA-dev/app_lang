// region [p]

/// Annotation for the configuration of the app language file
class AppLangConfig {
  const AppLangConfig({
    this.keyClassName = "AppLang",
    this.easyLoader = false,
    this.json = false,
    this.import,
    this.remove,
    this.addRegionComments = false,
  });

  /// The class name of the generated language fields class
  final String keyClassName;

  /// Export the language fields as json files
  final bool json;

  /// Export the language fields as a dart file for easy_localization loader
  final bool easyLoader;

  /// Import the language fields from a json file
  /// Example: Import(locale: "en_US", path: "lib/lang/imports/en_US.json")
  /// If the source file is not empty, new languages are added based on the existing keys.
  /// If the source file is empty, the keys from the imported file are used.
  final Import? import;

  /// Remove the language fields from the file
  /// Example: "en_US"
  final String? remove;

  /// Add region comments to the generated file
  final bool addRegionComments;
}

class Import {
  /// The locale of the language fields
  /// Example: "en_US"
  final String locale;

  /// The path of the language fields
  /// Example: "lib/lang/imports/en_US.json"
  final String path;

  const Import({
    required this.locale,
    required this.path,
  });
}

// endregion
