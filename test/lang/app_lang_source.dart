// ignore_for_file: non_constant_identifier_names, type_annotate_public_apis

import 'package:app_lang/app_lang.dart';

// region [p]

@AppLangConfig(json: true, easyLoader: true)
class AppLangSource {
  var user = (
    gender: (
      male: "Hi man ;) ",
      female: "Hello girl :)",
      other: "Hello ",
    ),
    money: (
      zero: "You not have money",
      one: "You have {} dollar",
      many: "You have {} dollars",
      other: "You have {} dollars",
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

// endregion
