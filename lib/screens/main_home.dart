import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/screens/bookmark_screen.dart';
import 'package:quran_app/screens/collections.dart';
import 'package:quran_app/screens/home_screen.dart';
import 'package:quran_app/screens/settings_setup.dart';
import 'package:quran_app/screens/surah_screen.dart';

import '../database_helper/verse_database/last_played_verse.dart';
import '../models/last_played_verse.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../widgets/app_bar.dart';
import '../widgets/customTextWidget.dart';
import '../widgets/home_card.dart';
import 'our_mission.dart';

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  int selectedIndex = -1;

  LastPlayedVerse? lastPlayedVerse;
  bool isLoadingLastVerse = true;


  @override
  void initState() {
    super.initState();
    _loadLastPlayedVerse();
  }


 // none selected initially
  void onCardTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    // ✅ You can add navigation here
    if (index == 0) {
      debugPrint("Navigate to Quran screen");
    } else if (index == 1) {
      debugPrint("Navigate to Collections screen");
    }
  }




  Future<void> _loadLastPlayedVerse() async {
    final verse = await LastPlayedDb.getLastPlayed();
    setState(() {
      lastPlayedVerse = verse;
      isLoadingLastVerse = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Quran App",

        // subtitle: "${widget.subtitle} – Verses: ${widget.versesCount}",
        onSettingsTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsPageSetup(skip: false,)));
        },
        iconPath: AppImages.settings,

       // actionText: "Skip",
        requiredNotification: true,

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 🔹 App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Quran App",
                    fontSize: 20.sp,
                    fontWeight: TextWeight.bold,
                    color: Colors.white,
                  ),
                  const Icon(Icons.settings, color: Colors.white),
                ],
              ),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
                ),
                child: isLoadingLastVerse
                    ? const Center(child: CircularProgressIndicator())
                    : lastPlayedVerse == null
                    ? Column(
                  children: [
                    Icon(Icons.auto_stories,
                        size: 40.sp, color: AppColors.purpleAppBarColorUpper),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: "No recent verse found",
                      fontSize: 14.sp,
                      fontWeight: TextWeight.medium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                    : Column(
                  children: [

                    SvgPicture.asset(AppImages.quranLogo, height: 40.h,),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: "Last Played",
                      fontSize: 12.sp,
                      fontWeight: TextWeight.medium,
                      textAlign: TextAlign.center,
                      color: AppColors.purpleAppBarColorUpper,
                    ),
                    SizedBox(height: 8.h),
                    CustomText(
                      text:
                      "Verse ${lastPlayedVerse!.verseNumber} from ${lastPlayedVerse!.surahName}",
                      fontSize: 14.sp,
                      fontWeight: TextWeight.medium,
                      textAlign: TextAlign.center,
                      textOverflow: TextOverflow.visible,
                    ),
                    if (lastPlayedVerse!.arabicText != null) ...[
                      SizedBox(height: 8.h),
                      CustomText(
                        text: lastPlayedVerse!.arabicText!,
                        fontSize: 20.sp,
                        fontWeight: TextWeight.bold,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                        textOverflow: TextOverflow.visible,
                      ),
                    ],
                    if (lastPlayedVerse!.urduText != null) ...[
                      SizedBox(height: 6.h),
                      CustomText(
                        text: lastPlayedVerse!.urduText!,
                        fontSize: 16.sp,
                        fontWeight: TextWeight.regular,
                        textAlign: TextAlign.center,
                        color: Colors.black87,
                        textOverflow: TextOverflow.visible,
                      ),
                    ],
                  ],
                ),

              ),



              SizedBox(height: 16.h),

              // 🔹 Resume Reading Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleAppBarColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                    onPressed: () {
                      if (lastPlayedVerse == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahScreen(
                            surahId: lastPlayedVerse!.surahId,
                            subtitle: lastPlayedVerse!.surahName,
                            lastPlayedVerse: lastPlayedVerse!.verseNumber,
                            versesCount: lastPlayedVerse!.verseCount,// pass this parameter
                          ),
                        ),
                      );
                    },
                  icon: Icon(Icons.menu_book, size: 20.sp),
                  label: CustomText(
                    text: "Resume Reading",
                    fontSize: 16.sp,
                    fontWeight: TextWeight.medium,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // 🔹 Grid Menu
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            children: [
              HomeMenuCard(
                iconPath: AppImages.quranIc,
                title: "Quran",
                iconColor: Colors.green,
                isSelected: selectedIndex == 0,
                onTap: () async{
                  onCardTap(0); // ✅ sahi index
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
              ),
              HomeMenuCard(
                iconPath: AppImages.collectionIc,
                title: "Collections",
                iconColor: Colors.pink,
                isSelected: selectedIndex == 1,
                onTap: () async{
                  onCardTap(1); // ✅ ab sahi index
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionsScreen()));
                },
              ),
              HomeMenuCard(
                iconPath: AppImages.bookMarkIc,
                title: "Bookmarks",
                iconColor: Colors.orange,
                isSelected: selectedIndex == 2,
                onTap: () async{
                  onCardTap(2); // ✅ correct index
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookmarkScreen()));
                },
              ),
              HomeMenuCard(
                iconPath: AppImages.settingsIc,
                title: "Settings",
                iconColor: Colors.amber,
                isSelected: selectedIndex == 3,
                onTap: () async{
                  onCardTap(3);
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPageSetup(skip: false,)));
                },
              ),
              HomeMenuCard(
                iconPath: AppImages.ourMissionIc,
                title: "Our Mission",
                iconColor: Colors.blue,
                isSelected: selectedIndex == 4,
                onTap: () async{
                  onCardTap(4);
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OurMissionScreen()));
                },
              ),
              HomeMenuCard(
                iconPath: AppImages.otherProjIc,
                title: "Other Projects",
                iconColor: Colors.purple,
                isSelected: selectedIndex == 5,
                onTap: () => onCardTap(5),
              ),
              HomeMenuCard(
                iconPath: AppImages.shareIc,
                title: "Share",
                iconColor: Colors.purple,
                isSelected: selectedIndex == 6,
                onTap: () => onCardTap(6),
              ),
              HomeMenuCard(
                iconPath: AppImages.donationIc,
                title: "Donation",
                iconColor: Colors.yellow,
                isSelected: selectedIndex == 7,
                onTap: () => onCardTap(7),
              ),
              HomeMenuCard(
                iconPath: AppImages.askQuestionIc,
                title: "Ask Question",
                iconColor: Colors.green,
                isSelected: selectedIndex == 8,
                onTap: () => onCardTap(8),
              ),
            ],
          )
          ],
          ),
        ),
      ),
    );
  }
}
