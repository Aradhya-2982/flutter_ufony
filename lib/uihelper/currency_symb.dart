import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {

  static String currencySymbol(num amt, BuildContext context) {
    final locale = PlatformDispatcher.instance.locale;
    final format = NumberFormat.simpleCurrency(
      locale: locale.toLanguageTag(),
    );
    return format.format(amt);
  }
}