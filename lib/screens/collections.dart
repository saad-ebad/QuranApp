import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/screens/saved_verses_collections.dart';

import '../database_helper/logs_db.dart';
import '../database_helper/verse_database/folder_database.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../widgets/app_bar.dart';
import '../widgets/customTextWidget.dart';

class CollectionsScreen extends StatefulWidget {
  final String? surahName;   // ✅ Add this
  final int? verseNumber;
  final String? arabicText;
  final String? urduText;
   bool comingFrom;

   CollectionsScreen({
    super.key,
    this.surahName,
    this.verseNumber,
    this.arabicText,
    this.urduText,
    this.comingFrom = false
  });

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// 🔥 Local DB folders
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();

    print("this is verse number ${widget.verseNumber} and name ${widget.surahName}");
    // if user came here via "Add to Folder"
    if (widget.verseNumber != null &&
        widget.arabicText != null &&
        widget.urduText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFolderDialog(); // open immediately
      });
    }
  }

  Future<void> _loadFolders() async {
    final folders = await FolderDatabase.instance.getAllFolders();
    setState(() {
      _folders = folders;
    });
  }




/*  Future<void> _showFolderDialog() async {
    final folders = await FolderDatabase.instance.getAllFolders();
    String? _selectedFolderId;
    final TextEditingController _folderController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 8.h,),
                      /// Title
                      CustomText(
                        text: "Create Collection Folder",
                    fontWeight: TextWeight.medium,
                    fontSize: 14.sp,

                      ),
                      const SizedBox(height: 12),

                      CustomText(
                        text: "Enter Folder Name",
                        fontWeight: TextWeight.medium,
                        fontSize: 12.sp,

                      ),

                      const SizedBox(height: 8),

                      /// Input + Add button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _folderController,
                                decoration: InputDecoration(
                                 // hintText: "Enter Folder Name",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: InputBorder.none, // Remove default border
                                  focusedBorder: InputBorder.none, // Remove border when focused
                                  enabledBorder: InputBorder.none, // Remove border when enabled
                                ),
                              ),
                            )
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (_folderController.text.isNotEmpty) {
                                final id = await FolderDatabase.instance
                                    .createFolder(_folderController.text);

                                if (widget.comingFrom == true &&
                                    widget.verseNumber != null &&
                                    widget.arabicText != null &&
                                    widget.urduText != null) {
                                  await FolderDatabase.instance.insertAyah(
                                    folderId: id,
                                    surahName: widget.surahName ?? "Unknown",
                                    verseNumber: widget.verseNumber!,
                                    arabic: widget.arabicText!,
                                    urdu: widget.urduText!,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "New folder created & Ayah added ✅")),
                                  );
                                  setState((){
                                    widget.comingFrom =false;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "New empty folder created 📂")),
                                  );
                                }

                                Navigator.pop(context);
                                _loadFolders();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(4),
                              fixedSize: Size(30, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 24,),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Existing Folders Section
                  widget.comingFrom ==true?  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                            text: "Collection Folder",
                            fontWeight: TextWeight.medium,
                            fontSize: 14.sp,
                        ),

                        const SizedBox(height: 8),

                        if (folders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("No folders found."),
                          )
                        else
                          SizedBox(
                            height: 200, // scrollable height
                            child: ListView.builder(
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFolderId =
                                          folder['id'].toString();
                                    });
                                  },
                                  child: Container(
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _selectedFolderId ==
                                          folder['id'].toString()
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      folder['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState((){
                                  widget.comingFrom =false;
                                });
                              },
                              child: const Text("Cancel"),
                            ),
                            if (widget.comingFrom == true)
                              ElevatedButton(
                                onPressed: () async {
                                  if (_selectedFolderId != null) {
                                    await FolderDatabase.instance.insertAyah(
                                      folderId: int.parse(_selectedFolderId!),
                                      surahName: widget.surahName ?? "Unknown",
                                      verseNumber: widget.verseNumber!,
                                      arabic: widget.arabicText!,
                                      urdu: widget.urduText!,
                                    );
                                    Navigator.pop(context);
                                    _loadFolders();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Ayah added to selected folder ✅"),
                                      ),
                                    );
                                    setState((){
                                      widget.comingFrom =false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4), // Reduced from 8 to 4
                                  ),
                                ),
                                child: const Text("Add to Folder"),
                              ),
                          ],
                        )
                      ],
                    ) : SizedBox(),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }*/


  Future<void> _showFolderDialog() async {
    final folders = await FolderDatabase.instance.getAllFolders();
    String? _selectedFolderId;
    final TextEditingController _folderController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      CustomText(
                        text: "Create Collection Folder",
                        fontWeight: TextWeight.medium,
                        fontSize: 14.sp,
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text: "Enter Folder Name",
                        fontWeight: TextWeight.medium,
                        fontSize: 12.sp,
                      ),
                      const SizedBox(height: 8),

                      /// Input + Add button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _folderController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (_folderController.text.isNotEmpty) {
                                final folderName = _folderController.text;
                                final id = await FolderDatabase.instance
                                    .createFolder(folderName);

                                if (widget.comingFrom == true &&
                                    widget.verseNumber != null &&
                                    widget.arabicText != null &&
                                    widget.urduText != null) {
                                  await FolderDatabase.instance.insertAyah(
                                    folderId: id,
                                    surahName: widget.surahName ?? "Unknown",
                                    verseNumber: widget.verseNumber!,
                                    arabic: widget.arabicText!,
                                    urdu: widget.urduText!,
                                  );

                                  // ✅ Log: new folder created + ayah added
                                  await LogsDatabase.addLog(
                                    "New folder \"$folderName\" created & Ayah ${widget.verseNumber} from Surah ${widget.surahName ?? "Unknown"} added",
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "New folder created & Ayah added ✅"),
                                    ),
                                  );
                                  setState(() {
                                    widget.comingFrom = false;
                                  });
                                } else {
                                  // ✅ Log: empty folder created
                                  await LogsDatabase.addLog(
                                    "New empty folder \"$folderName\" created",
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text("New empty folder created 📂"),
                                    ),
                                  );
                                }

                                Navigator.pop(context);
                                _loadFolders();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(4),
                              fixedSize: const Size(30, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Existing folders section
                      widget.comingFrom == true
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Collection Folder",
                            fontWeight: TextWeight.medium,
                            fontSize: 14.sp,
                          ),
                          const SizedBox(height: 8),
                          if (folders.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No folders found."),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: folders.length,
                                itemBuilder: (context, index) {
                                  final folder = folders[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFolderId =
                                            folder['id'].toString();
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _selectedFolderId ==
                                            folder['id'].toString()
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        folder['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 12),

                          /// Add to existing folder
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    widget.comingFrom = false;
                                  });
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_selectedFolderId != null) {
                                    final selectedFolder = folders.firstWhere(
                                          (f) =>
                                      f['id'].toString() ==
                                          _selectedFolderId,
                                    );

                                    await FolderDatabase.instance.insertAyah(
                                      folderId:
                                      int.parse(_selectedFolderId!),
                                      surahName:
                                      widget.surahName ?? "Unknown",
                                      verseNumber: widget.verseNumber!,
                                      arabic: widget.arabicText!,
                                      urdu: widget.urduText!,
                                    );

                                    // ✅ Log: ayah added to existing folder
                                    await LogsDatabase.addLog(
                                      "Ayah added to folder \"${selectedFolder['name']}\"",
                                    );

                                    Navigator.pop(context);
                                    _loadFolders();

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Ayah added to selected folder ✅"),
                                      ),
                                    );
                                    setState(() {
                                      widget.comingFrom = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text("Add to Folder"),
                              ),
                            ],
                          )
                        ],
                      )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }





  void _confirmDeleteFolder(int folderId, String folderName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Folder?"),
        content: Text(
          "Are you sure you want to delete the folder \"$folderName\" and all verses inside it?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog first

              await FolderDatabase.instance.deleteFolder(folderId);

              // ✅ Generate log after deletion
              await LogsDatabase.addLog("Folder \"$folderName\" deleted");

              // ✅ Refresh state AFTER delete completes
              await _loadFolders();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Folder \"$folderName\" deleted ✅")),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Collections",
        iconPath: AppImages.addCollection,
        onSettingsTap: (){
          _showFolderDialog();
        },

      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            /// Search Box
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
                  hintText: "Filter Folders by Name",
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
                onChanged: (value) {
                  setState(() {}); // rebuild for search filter
                },
              ),
            ),

            SizedBox(height: 12.h),

            /// Folder List
            Expanded(
              child: _folders.isEmpty
                  ? const Center(child: Text("No folders yet 📂"))
                  : ListView.separated(
                itemCount: _folders.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final folder = _folders[index];
                  final query = _searchController.text.toLowerCase();
                  if (query.isNotEmpty &&
                      !folder['name']
                          .toLowerCase()
                          .contains(query)) {
                    return const SizedBox.shrink(); // hide if not match
                  }
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                      title: Text(
                        folder["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: (){
                          _confirmDeleteFolder(folder['id'], folder['name']);
                        },
                        child: SvgPicture.asset(
                          AppImages.uncollection,
                          height: 24.h,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FolderDetailsScreen(
                              folderId: folder['id'],
                              folderName: folder['name'],
                              surahName: widget.surahName.toString(),
                              verseNumber: widget.verseNumber.toString(),


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

