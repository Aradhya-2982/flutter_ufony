import 'package:flutter/material.dart';

class Constants{
  static double? boxGap=10;
  static final double subtitleFontSize=16;

  static final Color cardColor = const Color(0xFFDBE2FF);

  static final Color buttonColor = const Color(0xFF45198E);

  static final Color appbarIconColor = const Color(0xFF000000);
  static Text smallNormalFont({required String text}) {
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ));
  }
  static Text smallThinFont({required String text}) {
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 14,
    ));
  }
  static Text largeBoldFont({required String text}) {
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ));
  }

  static Text calenderIconList({required String text}){
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ));

  }

}