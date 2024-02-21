import 'package:capture_moment/constant.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static TextStyle normalTextStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? kBlack,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}
