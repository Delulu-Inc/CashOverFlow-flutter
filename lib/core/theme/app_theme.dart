import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.appBackground,
    );
  }
}
