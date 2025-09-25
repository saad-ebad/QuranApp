import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/screens/settings_setup.dart';
import 'package:quran_app/screens/surah_screen.dart';
import 'package:quran_app/utils/app_images.dart';
import 'package:quran_app/widgets/customTextWidget.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_bar.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  Future<List<dynamic>> loadSurahMeta() async {
    final metaJson = await rootBundle.loadString("assets/json_files/surah_name_and_count.json");
    return json.decode(metaJson);
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildActionButton(String icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.greyColorLight,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 3),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              SvgPicture.asset(icon, color: color, height: 20.sp),
              SizedBox(height: 4.h),
              Text(label, style: TextStyle(fontSize: 11.sp)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  CustomAppBar(title: "Quran App", iconPath: AppImages.settings,requiredNotification: true,
      onSettingsTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsPageSetup(skip: false,)));
      },
      ),

      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // SizedBox(height: 10.h),
            // Row(
            //   children: [
            //     Expanded(child: _buildActionButton(AppImages.find, "Find Ayah", Colors.purple)),
            //     SizedBox(width: 12.w),
            //     Expanded(child: _buildActionButton(AppImages.search, "Search", Colors.blue)),
            //     SizedBox(width: 12.w),
            //     Expanded(child: _buildActionButton(AppImages.notes, "Notes", Colors.green)),
            //     SizedBox(width: 12.w),
            //     Expanded(child: _buildActionButton(AppImages.backup, "Backup", Colors.orange)),
            //   ],
            // ),
            // SizedBox(height: 12.h),

            /// Search Box
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.containerColor,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Filter Surah List by Number or Name",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.purpleAppBarColor,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            /// Surah List
            Expanded(
              child: FutureBuilder(
                future: loadSurahMeta(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final surahList = snapshot.data!;

                  // 🔎 Apply filter here
                  final filteredList = surahList.where((surah) {
                    final number = surah["index"].toString();
                    final english = surah["title"].toString().toLowerCase();
                    final arabic = surah["titleAr"].toString();
                    return number.contains(_searchQuery) ||
                        english.contains(_searchQuery) ||
                        arabic.contains(_searchQuery);
                  }).toList();

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final surah = filteredList[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.containerColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Text(
                            int.parse(surah["index"]!).toString(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.purpleAppBarColor,
                            ),
                          ),
                          title: CustomText(
                            text: surah["title"],
                            fontSize: 16.sp,
                            fontWeight: TextWeight.medium,
                          ),
                          trailing:  CustomText(
                            text: surah["titleAr"],
                            fontSize: 16.sp,
                            fontWeight: TextWeight.bold,
                          ),
                          subtitle: CustomText(
                            text: "Verses: ${surah["count"]}",
                            fontSize: 12.sp,
                            fontWeight: TextWeight.medium,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahScreen(
                                  surahId: index + 1,
                                  name: surah["titleAr"],
                                  subtitle: surah["title"],
                                  versesCount: surah["count"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),

    );
  }
}
