import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/screens/collections.dart';
import 'package:quran_app/screens/home_screen.dart';
import 'package:quran_app/screens/parah_screen.dart';
import 'package:quran_app/screens/settings_setup.dart';
import 'package:quran_app/screens/surah_screen.dart';

import '../database_helper/verse_database/book_mark_db.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/customTextWidget.dart';




class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}


class _BookmarkScreenState extends State<BookmarkScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final data = await BookmarkDatabase.instance.getBookmarks();
    setState(() => bookmarks = data);
  }

  void _removeBookmark(int surahId) async {
    await BookmarkDatabase.instance.removeBookmark(surahId);
    _loadBookmarks();
  }

  void _showRemoveDialog(BuildContext context, Map<String, dynamic> surah) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Remove Bookmark",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              Text("Do you want to remove bookmark?", style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 14.sp)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah["title"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${surah["type"]} - Verses:${surah["count"]}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h,),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _removeBookmark(surah["surahId"]);
                        Navigator.pop(context);
                      },
                      child: const Text("Remove"),
                    ),
                  ),
                  SizedBox(width: 8.w,),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.purple.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              )
            ],
          ),

        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Bookmarks", iconPath: AppImages.settings,  onSettingsTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsPageSetup(skip: false,)));
      },),
      body: bookmarks.isEmpty
          ? const Center(child: CustomText(text: "No bookmarks yet"))
          : Padding(
            padding:  EdgeInsets.all(12.0.w),
            child: Column(
                    children: [

            /// 🔍 Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
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
                    fontSize: 14.sp,
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

            /// ✅ Bookmark List with Expanded to fix overflow
            Expanded(
              child: ListView.separated(
                itemCount: bookmarks.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: 12.h), // spacing between items
                itemBuilder: (context, index) {
                  final surah = bookmarks[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CustomText(
                        text: surah["surahId"].toString(),
                        fontSize: 16.sp,
                        fontWeight: TextWeight.bold,
                        color: AppColors.purpleAppBarColor,
                      ),
                      title: CustomText(
                        text: surah["title"],
                        fontSize: 16.sp,
                        fontWeight: TextWeight.medium,
                      ),
                      subtitle: CustomText(
                        text: "Verses: ${surah["count"]}",
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          _showRemoveDialog(context, surah);
                        },
                        child: SvgPicture.asset(
                          AppImages.bookMarkRemove,
                          height: 24.h,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SurahScreen(
                                  surahId: surah["surahId"],
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
              ),
            ),
                    ],
                  ),
          ),
    );
  }
}
