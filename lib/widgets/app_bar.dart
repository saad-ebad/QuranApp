// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:quran_app/utils/app_images.dart';
//
// import '../utils/app_colors.dart';
// import 'customTextWidget.dart';
//
//
//
//
//
//
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   final VoidCallback? onSettingsTap;
//   final String? actionText;
//   final String? iconPath;
//   // 🔥 new props for download
//   final Color? iconColor;
//   final bool isDownloading;
//   final double downloadProgress; // 0.0 → 1.0
//   final VoidCallback? onDownloadTap;
//   final VoidCallback? onCancelDownload;
//
//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.subtitle,
//     this.onSettingsTap,
//     this.actionText,
//     this.iconPath,
//     this.iconColor,
//     this.isDownloading = false,
//     this.downloadProgress = 0.0,
//     this.onDownloadTap,
//     this.onCancelDownload,
//   }) : super(key: key);
//
//   @override
//   Size get preferredSize => Size.fromHeight(70.h);
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       backgroundColor: AppColors.purpleAppBarColor,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CustomText(
//             text: title,
//             fontSize: 22.sp,
//             fontWeight: TextWeight.medium,
//             color: Colors.white,
//           ),
//           if (subtitle != null)
//             CustomText(
//               text: subtitle!,
//               fontSize: 18.sp,
//               fontWeight: TextWeight.regular,
//               color: Colors.white,
//             ),
//         ],
//       ),
//       actions: [
//
//         actionText != null ? CustomText(text: actionText.toString(), fontSize: 12.sp,color: Colors.white,): SizedBox(),
//         // ⚙️ Settings
//          GestureDetector(
//           onTap: onSettingsTap,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8.w),
//             child: SvgPicture.asset(
//               iconPath!,
//               height: 24.h,
//               color: iconColor,
//             ),
//           ),
//         ),
//
//         // ⬇️ Download / Progress
//         onCancelDownload !=null ?  Padding(
//           padding: EdgeInsets.only(right: 12.w),
//           child: isDownloading
//               ? Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 height: 32,
//                 width: 32,
//                 child: CircularProgressIndicator(
//                   value: downloadProgress,
//                   strokeWidth: 3,
//                   backgroundColor: Colors.white30,
//                   valueColor: AlwaysStoppedAnimation(Colors.white),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onCancelDownload,
//                 child: const Icon(Icons.close,
//                     color: Colors.white, size: 16),
//               ),
//             ],
//           )
//               : IconButton(
//             icon: const Icon(Icons.download, color: Colors.white),
//             onPressed: onDownloadTap,
//           ),
//         ) : SizedBox(),
//       ],
//     );
//   }
// }
//
//
//


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/screens/logs_screen.dart';
import 'package:quran_app/utils/app_images.dart';

import '../screens/main_home.dart';
import '../utils/app_colors.dart';
import 'customTextWidget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSettingsTap;
  final String? actionText;
  final String? iconPath;
  final Color? iconColor;

  // 🔥 new props for download
  final bool isDownloading;
  final double downloadProgress; // 0.0 → 1.0
  final VoidCallback? onDownloadTap;
  final VoidCallback? onCancelDownload;

  // 🔥 new prop for notification
  final bool requiredNotification;

  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.onSettingsTap,
    this.actionText,
    this.iconPath,
    this.iconColor,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.onDownloadTap,
    this.onCancelDownload,
    this.requiredNotification = false, // default false
    this.automaticallyImplyLeading =false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(
        color: Colors.white, // Changes back icon color
      ),
      backgroundColor: AppColors.purpleAppBarColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: title,
            fontSize: 22.sp,
            fontWeight: TextWeight.medium,
            color: Colors.white,
          ),
          if (subtitle != null)
            CustomText(
              text: subtitle!,
              fontSize: 18.sp,
              fontWeight: TextWeight.regular,
              color: Colors.white,
            ),
        ],
      ),
      actions: [
        if (actionText != null)
         actionText == "Skip" ? GestureDetector(
           onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=> QuranHomeScreen()));

           },
           child: CustomText(
              text: actionText.toString(),
              fontSize: 12.sp,
              color: Colors.white,
            ),
         ) : CustomText(
           text: actionText.toString(),
           fontSize: 12.sp,
           color: Colors.white,
         ),

        // 🔔 Notification Icon
        if (requiredNotification)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Navigate to Log Screen
              Navigator.push(context, MaterialPageRoute(builder: (context)=> LogsPage()));
              // ya Navigator.push(context, MaterialPageRoute(builder: (_) => LogScreen()));
            },
          ),

        // ⚙️ Settings Icon
        if (iconPath != null)
          GestureDetector(
            onTap: onSettingsTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: SvgPicture.asset(
                iconPath!,
                height: 24.h,
                color: iconColor,
              ),
            ),
          ),

        // ⬇️ Download / Progress
        if (onCancelDownload != null)
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: isDownloading
                ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    value: downloadProgress,
                    strokeWidth: 3,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: onCancelDownload,
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 16),
                ),
              ],
            )
                : IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: onDownloadTap,
            ),
          ),
      ],
    );
  }
}
