import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static int dashboardColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 16;
  }
}