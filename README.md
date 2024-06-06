[<img src="https://raw.githubusercontent.com/EFA-dev/app_lang/main/assets/app_lang_cover.png"  height="320">](https://www.youtube.com/watch?v=c3G9xEA4PQg)

A build_runner package for managing app language files.

This package helps you to manage your app's language files in a single Dart file. It enables you to generate JSON files or easy_localization key and loader classes from the Dart file.

## Features
1. Combine translations in a single Dart file
2. Generates JSON files for each locale
3. Generates easy_localization loader class
4. Generate key file for key paths
5. Import new locale from a JSON file
6. Remove a locale from the source file
7. Continuously generate files with the watch command

<br /> 
 
## Getting started
****
- Add app_lang to pubspec.yaml file under the dependencies section

```yaml
  dependencies:   
    app_lang: latest
```

- Add build_runner to pubspec.yaml file under the dev_dependencies section

```yaml
  dev_dependencies:
    build_runner: latest

```

- Add easy_localization if you want to use easy localization loader
```yaml
  dependencies:
    app_lang: latest   
    easy_localization: latest
```

<br /> 
 
## Usage

1- Create a Dart file in `lib/lang/app_lang_source.dart` copy and past codes below.

```dart
// ignore_for_file: non_constant_identifier_names, type_annotate_public_apis

import 'package:app_lang/app_lang.dart';

@AppLangConfig(json: true, easyLoader: true)
class AppLangSource {
  var user = (
    gender: (
      male: (en_US: "Hi man {} ;) ",),
      female: (en_US: "Hello girl :)",),
      other: (en_US: "Hello {}",),
    ),
    money: (
      zero: (en_US: "You not have money",),
      one: (en_US: "You have {} dollar",),
      many: (en_US: "You have {} dollars",),
      other: (en_US: "You have {} dollars",),
    ),
  );

  var incomeTransaction = (
    fields: (
      amount: (en_US: "Price",),
      paymentDate: (en_US: "Payment Date",),
    ),
    actions: (
      update: (en_US: "Edit",),
      detail: (en_US: "Detail",),
      addTag: (en_US: "Add Tag",),
    ),
    validations: (
      amount: (
        notNull: (en_US: "You must enter an amount",),
        lessThen: (en_US: "Amount must be less than 100",),
      ),
    ),
  );

  var expenseTransaction = (
    fields: (
      amount: (en_US: "Price",),
      paymentDate: (en_US: "Payment Date",),
    ),
  );
}


```


> [!IMPORTANT]
> - Fields should be a Record
> - The last node(value node) should contain the locale as a parameter name and value should be a String
>- `zero`, `one`, `two`, `few`, `many`, `other`, `male`, `female` are reserved words. They should be the first parent of the value node.
>- If you use one of the reserved words and you are using the easy_localization package, `other` is required
****
<br />

2 - Run `dart run build_runner build --delete-conflicting-outputs `
  
The package will create files below in the same directory

- `app_lang_source.en_US.json` is a asset file you can use with easy_localization or some other packages which does support JSON assets

- `app_lang_source.loader.dart` is a easy_localization loader file. You can use it to load your translations.
  
- `app_lang_source.key.dart` is a Dart file that contains AppLang class and keys in it to access translations
  
<br />

## AppLangConfig Parameters
| Param | Type | Default | Description |
| -------------- | --------------| --------------| --------------|
| `keyClassName`  | String | AppLang |Name for keys class|
| `easyLoader` | bool     |false|Generates easy loader class|
| `json`    | bool    |false|Generates JSON files for each locale|
| `remove`    | String?   |null|Removes a locale from the source file|
| `import`    | Import?    |null|Import a new locale from a JSON file|
| `addRegionComments`    | bool| false   |Add region comments to generated dart files for Colored Regions VSCode plugin |

<br />

## Import New Locale
You can import a new locale with a JSON file. When you import a new local, the files will generated again with new translations. 

- If the source file contains a local already, existing keys will be use to import the new locale. If new locale json file doesn't contains any key that already exist, will be ignored.

- If the source file is empty, the keys will be generated from the JSON
  
```dart
import 'package:app_lang/app_lang.dart';


@AppLangConfig(import: Import(locale: "en_US", path: "lib/lang/imports/en_US.json",json: true, easyLoader: true,))
class AppLangSource {     
     // Fields ...    
}

```

> [!WARNING]
> After import you should remove the import parameter

<br />

## Remove Existing Locale
You can remove an existing locale from the sourcefile with `remove` parameter of `AppLangConfig` annotation.

When you remove a locale, all files will be generated again.

```dart

import 'package:app_lang/app_lang.dart';


@AppLangConfig(remove: "en_US", json: true, easyLoader: true)
class AppLangSource {
    // Fields ...
}

```

<br />

## Watch
With `dart run build_runner watch --delete-conflicting-outputs` command, you can watch the source file and generate files automatic while you are working.

If you use [localization_pro](https://pub.dev/packages/localization_pro) package you can install new JSON files and see the changes on app instantly without restart the app.