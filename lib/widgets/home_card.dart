// ✅ Reusable Menu Card Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'customTextWidget.dart';

class HomeMenuCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final Color iconColor;
  final Color? bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const HomeMenuCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.iconColor,
    this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          color: isSelected
              ? (bgColor ?? Colors.purple) // selected bg
              : (bgColor ?? Colors.white), // normal bg
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 28.sp,
              color: isSelected ? Colors.white : iconColor,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: title,
              fontSize: 12.sp,
              fontWeight: TextWeight.regular,
              textAlign: TextAlign.center,
              color: isSelected ? Colors.white : Colors.black,
              textOverflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}


