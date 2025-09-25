import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';




enum TextWeight {
  bold,
  light,
  medium,
  regular,
  semibold,
}

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final TextWeight? fontWeight;
  final TextOverflow? textOverflow;

  final int? maxLines;
  final Color? color;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final Color? backgroundColor;

  final List<Shadow>? shadows;
  final TextDirection? textDirection;


  const CustomText(
      {Key? key,
        required this.text,
        this.fontSize,
        this.color,
        this.fontWeight,
        this.textOverflow,
        this.maxLines,
        this.textAlign,
        this.textDecoration,
        this.letterSpacing,
        this.wordSpacing,
        this.backgroundColor,
        this.textDirection,
        this.shadows,
        this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      //overflow: textOverflow ?? TextOverflow.ellipsis,
      //softWrap: false,
      textAlign: textAlign,
     // maxLines: maxLines ?? 4,
      textDirection: textDirection,

      style: TextStyle(


        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        backgroundColor: backgroundColor,
        height: height ?? 0,
        overflow: textOverflow ?? TextOverflow.ellipsis,
        color: color ?? Colors.black,
        fontSize: fontSize ?? 16.r,
        fontFamily: (() {
          if (fontWeight == null) {
            return "Poppins-Regular";
          }
          if (fontWeight == TextWeight.regular) {
            return "Poppins-Regular";
          }
          if (fontWeight == TextWeight.light) {
            return "Poppins-Light";
          }
          if (fontWeight == TextWeight.medium) {
            return "Poppins-Medium";
          }
          if (fontWeight == TextWeight.bold) {
            return "Poppins-Bold";
          }
          if (fontWeight == TextWeight.semibold) {
            return "Poppins-SemiBold";
          }
        }()),
        decoration: textDecoration ?? TextDecoration.none,
        shadows: shadows,
      ),
    );
  }
}
