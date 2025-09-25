import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../widgets/customTextWidget.dart';

class MissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final bool showVideoBox;

  const MissionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.buttonText,
    this.onButtonTap,
    this.showVideoBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: title,
            fontSize: 18.sp,
            fontWeight: TextWeight.medium,
            textAlign: TextAlign.center,
            color: Colors.purple,
            textOverflow: TextOverflow.visible,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: subtitle,
            fontSize: 14.sp,
            fontWeight: TextWeight.medium,
            textAlign: TextAlign.center,
            color: Colors.black,
            textOverflow: TextOverflow.visible,
          ),
          if (description != null) ...[
            SizedBox(height: 8.h),
            CustomText(
              text: description!,
              fontSize: 13.sp,
              fontWeight: TextWeight.medium,
              textAlign: TextAlign.center,
              color: Colors.black87,
              textOverflow: TextOverflow.visible,
            ),
          ],
          if (buttonText != null) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleAppBarColorUpper,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: CustomText(
                  text: buttonText!,
                  fontSize: 14.sp,
                  fontWeight: TextWeight.medium,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          if (showVideoBox) ...[
            SizedBox(height: 12.h),
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: "Video Tutorial",
                fontSize: 14.sp,
                fontWeight: TextWeight.medium,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}