import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../database_helper/verse_database/folder_database.dart';
import '../utils/app_images.dart';
import '../utils/common_functions.dart';
import '../widgets/app_bar.dart';



class FolderDetailsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;
  final String surahName;
  final String verseNumber;

  const FolderDetailsScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.surahName,
    required this.verseNumber
  });

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}
class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _ayahsFuture;

  /// ✅ track selected ayahs by their DB id
  final Set<int> _selectedAyahs = {};

  @override
  void initState() {
    super.initState();
    _refreshAyahs();
  }

  Future<List<Map<String, dynamic>>> _loadAyahs() async {
    return await FolderDatabase.instance.getAyahsByFolder(widget.folderId);
  }

  void _refreshAyahs() {
    _ayahsFuture = _loadAyahs();
  }

  void _confirmDelete(int ayahId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Verse?"),
        content: const Text("Are you sure you want to remove this verse from the folder?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FolderDatabase.instance.deleteAyah(ayahId);
              setState(() {
                _refreshAyahs();
                _selectedAyahs.remove(ayahId); // ✅ also remove from selection
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Verse deleted ✅")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ✅ share all selected ayahs
  void _shareSelected(List<Map<String, dynamic>> ayahs) {
    final selected = ayahs.where((a) => _selectedAyahs.contains(a['id'])).toList();

    if (selected.isEmpty) return;

    UtilityFunctions.shareVerses(
      surahName: selected.first['surahName'],
      verses: selected
          .map((a) => {
        "verseNumber": a['verseNumber'],
        "arabic": a['arabic'],
        "urdu": a['urdu'],
      })
          .toList(),
    );

    setState(() => _selectedAyahs.clear()); // ✅ clear selection after share
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.folderName,
        iconPath: AppImages.settings,
      ),
      body: FutureBuilder(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final ayahs = snapshot.data as List<Map<String, dynamic>>;
          if (ayahs.isEmpty) return const Center(child: Text("No verses added yet 📖"));

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.separated(
              itemCount: ayahs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                final isSelected = _selectedAyahs.contains(ayah['id']);

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAyahs.remove(ayah['id']);
                      } else {
                        _selectedAyahs.add(ayah['id']);
                      }
                    });
                  },
                  onTap: () {
                    if (_selectedAyahs.isNotEmpty) {
                      setState(() {
                        if (isSelected) {
                          _selectedAyahs.remove(ayah['id']);
                        } else {
                          _selectedAyahs.add(ayah['id']);
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? Colors.green.withOpacity(0.2) // ✅ highlight selected
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        "${ayah['surahName']} : ${ayah['verseNumber']}",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ayah['arabic'] ?? "",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: "QuranArabic",
                              fontSize: 30.sp,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah['urdu'] ?? "",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: "QuranUrdu",
                              fontSize: 20.sp,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedAyahs.isEmpty) // ✅ hide individual share if multi-select active
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.green),
                              onPressed: () {
                                UtilityFunctions.shareVerses(
                                  surahName: ayah['surahName'],
                                  verses: [
                                    {
                                      "surahName": ayah['surahName'],
                                      "verseNumber": ayah['verseNumber'],
                                      "arabic": ayah['arabic'],
                                      "urdu": ayah['urdu'],
                                    }
                                  ],
                                );
                              },
                            ),
                          GestureDetector(
                            onTap: () => _confirmDelete(ayah['id']),
                            child: SvgPicture.asset(
                              AppImages.uncollection,
                              height: 24.h,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      /// ✅ Floating share button when multiple selected
      floatingActionButton: FutureBuilder(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final ayahs = snapshot.data as List<Map<String, dynamic>>;
          if (_selectedAyahs.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => _shareSelected(ayahs),
            icon: const Icon(Icons.share),
            label: Text("Share ${_selectedAyahs.length} Ayah(s)"),
            backgroundColor: Colors.green,
          );
        },
      ),
    );
  }
}

