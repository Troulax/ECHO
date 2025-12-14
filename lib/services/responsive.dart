import 'package:flutter/material.dart';

class Responsive {
  static Size size(BuildContext context) => MediaQuery.of(context).size;

  static double w(BuildContext context, double ratio) =>
      size(context).width * ratio;

  static double h(BuildContext context, double ratio) =>
      size(context).height * ratio;

  static bool isSmall(BuildContext context) =>
      size(context).width < 360;
}
