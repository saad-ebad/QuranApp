import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/widgets/customTextWidget.dart';

import '../utils/app_colors.dart';
import '../utils/app_images.dart';

/*class BottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomBar({
    Key? key,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            svgPath: AppImages.collection,
            label: "Collections",
            index: 0,
          ),
          _buildNavItem(
            svgPath: AppImages.parah,
            label: "Parah",
            index: 1,
          ),
          _buildNavItem(
            svgPath: AppImages.quran,
            label: "Quran",
            index: 2,
          ),
          _buildNavItem(
            svgPath: AppImages.mushaf,
            label: "Mushaf",
            index: 3,
          ),
          _buildNavItem(
            svgPath: AppImages.book_mark,
            label: "Bookmarks",
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String svgPath,
     Color? color,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(svgPath, color: color, height: 22.h),
          const SizedBox(height: 2),
          CustomText(
            text: label,

              fontSize: 12,
              fontWeight: isSelected ? TextWeight.bold : TextWeight.regular,
              color: Colors.black,
            ),

        ],
      ),
    );
  }
}*/


class BottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomBar({
    Key? key,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            svgPath: AppImages.collection,
            label: "Home",
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            svgPath: AppImages.parah,
            label: "Collections",
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            svgPath: AppImages.quran,
            label: "Parah",
            index: 2,
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            svgPath: AppImages.mushaf,
            label: "Quran",
            index: 3,
            isSelected: currentIndex == 3,
          ),
          _buildNavItem(
            svgPath: AppImages.book_mark,
            label: "Bookmarks",
            index: 4,
            isSelected: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String svgPath,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            color: isSelected ? AppColors.purpleAppBarColor : null,
            height: 22,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: 12,
            fontWeight: isSelected ? TextWeight.bold : TextWeight.regular,
            color: isSelected ? AppColors.purpleAppBarColor : null,
          ),
        ],
      ),
    );
  }
}