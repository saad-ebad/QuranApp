import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/collections.dart';
import '../utils/app_colors.dart';
import '../utils/common_functions.dart';




/*class VerseTile extends StatelessWidget {
  final String? surahName;
  final int verseNumber;
  final String? arabicText;
  final String? urduText;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const VerseTile({
    super.key,
    this.surahName,
    required this.verseNumber,
    this.arabicText,
    this.urduText,
    this.isPlaying = false,
    required this.onPlay,
    required this.onStop,
  });

  void _showCustomMenu(BuildContext context, Offset position) {
    showMenu(
      menuPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      color: Colors.white, // so our custom containers show fully
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First item container
              Container(
                decoration:  BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _menuItem(
                  icon: Icons.folder,
                  iconColor: Colors.pink,
                  text: "Add to folder",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionsScreen(
                          surahName: surahName,  // ✅ pass real surah name from your surah list
                          verseNumber: verseNumber,
                          arabicText: arabicText ?? "",
                          urduText: urduText ?? "",
                          comingFrom: true,
                        ),
                      ),
                    );



                  },
                ),
              ),

              const SizedBox(height: 8), // space between items

              // Second item container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _menuItem(
                  icon: Icons.share,
                  iconColor: Colors.green,
                  text: "Share",
                  onTap: () {
                    Navigator.pop(context);

                    UtilityFunctions.shareVerses(
                      surahName: surahName ?? "Unknown Surah",
                      verses: [
                        {
                          "verseNumber": verseNumber,
                          "arabic": arabicText ?? "",
                          "urdu": urduText ?? "",
                        }
                      ],
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPlaying ? Colors.purple.shade50 : AppColors.containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Three dots button
          GestureDetector(
            behavior: HitTestBehavior.translucent, // 👈 expands tap area
            onTapDown: (details) {
              _showCustomMenu(context, details.globalPosition);
            },
            child: Padding( // 👈 give some padding for easier tap
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (i) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.white : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),


          const SizedBox(width: 12),

          /// Verse content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (arabicText != null)
                  Text(
                    arabicText!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            verseNumber.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (urduText != null)
                  Text(
                    urduText!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// Play / Stop button
          InkWell(
            onTap: isPlaying ? onStop : onPlay,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.purple,
              child: Icon(
                size: 16,
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/


class VerseTile extends StatelessWidget {
  final String? surahName;
  final int verseNumber;
  final String? arabicText;
  final String? urduText;
  final bool isPlaying;
  final bool isSelected;       // ✅ new
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onSelect; // ✅ new

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const VerseTile({
    super.key,
    this.surahName,
    required this.verseNumber,
    this.arabicText,
    this.urduText,
    this.isPlaying = false,
    this.isSelected = false,
    required this.onPlay,
    required this.onStop,
    required this.onSelect,
    required this.onTap,
    required this.onLongPress
  });

  void _showCustomMenu(BuildContext context, Offset position) {
    showMenu(
      menuPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      color: Colors.white, // so our custom containers show fully
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First item container
              Container(
                decoration:  BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _menuItem(
                  icon: Icons.folder,
                  iconColor: Colors.pink,
                  text: "Add to folder",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionsScreen(
                          surahName: surahName,  // ✅ pass real surah name from your surah list
                          verseNumber: verseNumber,
                          arabicText: arabicText ?? "",
                          urduText: urduText ?? "",
                          comingFrom: true,
                        ),
                      ),
                    );



                  },
                ),
              ),

              const SizedBox(height: 8), // space between items

              // Second item container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _menuItem(
                  icon: Icons.share,
                  iconColor: Colors.green,
                  text: "Share",
                  onTap: () {
                    Navigator.pop(context);

                    UtilityFunctions.shareVerses(
                      surahName: surahName ?? "Unknown Surah",
                      verses: [
                        {
                          "verseNumber": verseNumber,
                          "arabic": arabicText ?? "",
                          "urdu": urduText ?? "",
                        }
                      ],
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }




  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.playingVerseColor.withOpacity(0.4)   // ✅ highlight selection first
              : isPlaying
              ? AppColors.playingVerseColor      // ✅ highlight playing if not selected
              : AppColors.containerColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Three dots button
            GestureDetector(
              behavior: HitTestBehavior.translucent, // 👈 expands tap area
              onTapDown: (details) {
                _showCustomMenu(context, details.globalPosition);
              },
              child: Padding( // 👈 give some padding for easier tap
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.white : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),


            const SizedBox(width: 12),

            /// Verse content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (arabicText != null)
                    Text(
                      arabicText!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade400,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              verseNumber.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade400,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (urduText != null)
                    Text(
                      urduText!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// Play / Stop button
            InkWell(
              onTap: isPlaying ? onStop : onPlay,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.purple,
                child: Icon(
                  size: 16,
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

