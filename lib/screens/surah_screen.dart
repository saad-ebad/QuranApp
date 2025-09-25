/*
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

import '../database_helper/database_helper.dart';
import '../database_helper/settings_db.dart';
import '../database_helper/verse_database/book_mark_db.dart';
import '../models/surah.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../utils/common_functions.dart';
import '../widgets/app_bar.dart';
import '../widgets/verse_tile.dart';

class SurahScreen extends StatefulWidget {
  final String? name;
  final String? subtitle;
  final int versesCount;
  final int? surahId;
  final String? surahNumber; // ✅ add this field

  const SurahScreen({
    super.key,
    required this.name,
    required this.subtitle,
    required this.versesCount,
    required this.surahId,
    this.surahNumber, // ✅ add in constructor
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}


class _SurahScreenState extends State<SurahScreen> {
  int selectedAyah = 1;
  bool showArabic = true;
  bool showUrdu = true;
  bool showEnglish = false;

  // List<Verse> verses = [];

  bool isBookmarked = false;
  bool isLoading = true;
  int? selectedVerse;
  SurahModel? surah;

  final AudioPlayer _player = AudioPlayer();
  int? _currentlyPlayingVerse;

  final ScrollController _scrollController = ScrollController();

  CancelToken? _downloadCancelToken;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  final List<GlobalKey> verseKeys = [];

  Set<int> selectedVerses = {};




  @override
  void initState() {
    super.initState();

    // Load Surah data
    loadSurahData(widget.surahId!).then((data) {
      setState(() {
        surah = data;
        isLoading = false;
      });
      _checkIfBookmarked();
    });

    // 👇 Setup listener with conditional continuation
    _player.onPlayerComplete.listen((_) {
      if (_currentlyPlayingVerse != null && surah != null) {
        final currentIndex =
        surah!.verses.indexWhere((v) => v.number == _currentlyPlayingVerse);

        if (selectedVerse == null) {
          // 🔥 Mode: Play all verses
          if (currentIndex != -1 && currentIndex < surah!.verses.length - 1) {
            final nextVerse = surah!.verses[currentIndex + 1];
            playVerse(nextVerse);
          } else {
            setState(() => _currentlyPlayingVerse = null);
          }
        } else {
          // 🔥 Mode: Play single ayah only once
          setState(() => _currentlyPlayingVerse = null);
        }
      }
    });
  }




  @override
  void dispose() {
    _player.dispose(); // very important
    _scrollController.dispose();
    super.dispose();
  }


  Future<SurahModel> loadSurahData(int surahId) async {
    final arabicJson = await rootBundle.loadString("assets/json_files/quran_verses_arabic.json");
    final urduJson = await rootBundle.loadString("assets/json_files/quran_verses_urdu.json");

    final arabicData = json.decode(arabicJson)["data"]["surahs"];
    final urduData = json.decode(urduJson)["data"]["surahs"];

    final arabicSurah = arabicData[surahId - 1];
    final urduSurah = urduData[surahId - 1];

    // 🔥 Batch load cached audio
    final cachedAudios = await AudioDatabase.getAllAudiosForSurah(surahId);

    List<VerseModel> verses = [];
    for (int j = 0; j < arabicSurah["ayahs"].length; j++) {
      final arabicVerse = arabicSurah["ayahs"][j];
      final urduVerse = urduSurah["ayahs"][j];
      final verseNum = arabicVerse["numberInSurah"];

      verses.add(
        VerseModel(
          number: verseNum,
          arabic: arabicVerse["text"],
          urdu: urduVerse["text"],
          localAudioPath: cachedAudios[verseNum],
        ),
      );
    }

    verseKeys.clear();
    verseKeys.addAll(List.generate(verses.length, (_) => GlobalKey()));

    return SurahModel(
      number: arabicSurah["number"],
      nameArabic: arabicSurah["name"],
      nameEnglish: arabicSurah["englishName"],
      totalVerses: arabicSurah["ayahs"].length,
      revelationType: arabicSurah["revelationType"],
      verses: verses,
    );
  }



*/
/*
  Future<void> downloadSurahAudio(int surahId) async {


    // ✅ Check Mobile Data Allowed or Not
    bool isMobileDataAllowed = await SettingsDatabase.getMobileDataSetting();

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile && !isMobileDataAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download over mobile data is not allowed. Please change your settings."),
        ),
      );
      return; // Stop here
    }




    // ✅ First check if this surah already has audio
    if (surah != null &&
        surah!.verses.every((v) => v.localAudioPath != null && File(v.localAudioPath!).existsSync())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surah ${surah!.nameEnglish} has already been downloaded")),
      );
      return; // ⛔ stop here
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadCancelToken = CancelToken();
    });

    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory("${dir.path}/surah_$surahId");
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    try {
      final response = await Dio().get(
        "https://api.alquran.cloud/v1/surah/$surahId/ur.khan",
      );

      final data = response.data["data"]["ayahs"];
      int total = data.length;
      int completed = 0;

      for (var ayah in data) {
        if (_downloadCancelToken?.isCancelled ?? false) {
          throw "Download cancelled";
        }

        final url = ayah["audio"];
        final verseNum = ayah["numberInSurah"];
        final savePath = "${surahDir.path}/$verseNum.mp3";

        if (!File(savePath).existsSync()) {
          await Dio().download(
            url,
            savePath,
            cancelToken: _downloadCancelToken,
          );
        }

        // Save into DB
        await AudioDatabase.insertAudio(surahId, verseNum, savePath);

        // Update VerseModel in memory
        final verse = surah?.verses.firstWhere((v) => v.number == verseNum);
        if (verse != null) verse.localAudioPath = savePath;

        // 🔥 Update percentage
        completed++;
        setState(() {
          _downloadProgress = completed / total;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Surah ${surah!.nameEnglish} downloaded successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadCancelToken = null;
        });
      }
    }
  }*//*



  Future<void> downloadSurahAudio(int surahId) async {
    // ✅ Force small delay to ensure DB write completes
    await Future.delayed(const Duration(milliseconds: 100));

    // ✅ Fetch latest value from DB (safe default false)
    bool isMobileDataAllowed = await SettingsDatabase.getMobileDataSetting();

    // ✅ Always returns a List<ConnectivityResult>
    final activeConnections = await Connectivity().checkConnectivity();

    // ✅ Check if mobile connection is active
    bool isOnMobile = activeConnections.contains(ConnectivityResult.mobile);

    debugPrint("📡 Active Connection: $activeConnections");
    debugPrint("📀 MobileDataAllowed (from DB): $isMobileDataAllowed");

    // ✅ Block download if on mobile data and not allowed
    if (isOnMobile && !isMobileDataAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Download over mobile data is not allowed. Please change your settings.",
          ),
        ),
      );
      return;
    }

    // ✅ Check if already downloaded
    if (surah != null &&
        surah!.verses.every((v) => v.localAudioPath != null && File(v.localAudioPath!).existsSync())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surah ${surah!.nameEnglish} has already been downloaded")),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadCancelToken = CancelToken();
    });

    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory("${dir.path}/surah_$surahId");
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    try {
      final response = await Dio().get(
        "https://api.alquran.cloud/v1/surah/$surahId/ur.khan",
      );

      final data = response.data["data"]["ayahs"];
      int total = data.length;
      int completed = 0;

      for (var ayah in data) {
        // ✅ Re-check connectivity before each ayah
        final currentConnections = await Connectivity().checkConnectivity();
        bool isCurrentlyOnMobile = currentConnections.contains(ConnectivityResult.mobile);

        if (isCurrentlyOnMobile && !isMobileDataAllowed) {
          debugPrint("⛔ Download stopped - switched to mobile data but not allowed.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Download stopped. Mobile data is not allowed."),
            ),
          );
          break;
        }

        if (_downloadCancelToken?.isCancelled ?? false) {
          throw "Download cancelled";
        }

        final url = ayah["audio"];
        final verseNum = ayah["numberInSurah"];
        final savePath = "${surahDir.path}/$verseNum.mp3";

        if (!File(savePath).existsSync()) {
          await Dio().download(
            url,
            savePath,
            cancelToken: _downloadCancelToken,
          );
        }

        await AudioDatabase.insertAudio(surahId, verseNum, savePath);

        final verse = surah?.verses.firstWhere((v) => v.number == verseNum);
        if (verse != null) verse.localAudioPath = savePath;

        completed++;
        setState(() {
          _downloadProgress = completed / total;
        });
      }

      if (mounted && completed == total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Surah ${surah!.nameEnglish} downloaded successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadCancelToken = null;
        });
      }
    }
  }










  void playVerse(VerseModel verse) async {
    if (verse.localAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please download surah first")),
      );
      return;
    }

    setState(() => _currentlyPlayingVerse = verse.number);

    _scrollToVerse(verse.number);

    await _player.stop();
    await _player.play(DeviceFileSource(verse.localAudioPath!));
  }



  void _scrollToVerse(int verseNumber) {
    final index = surah!.verses.indexWhere((v) => v.number == verseNumber);
    if (index != -1) {
      final context = verseKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }


  void stopAudio() async {
    await _player.stop();
    setState(() => _currentlyPlayingVerse = null);
  }



  Future<void> _checkIfBookmarked() async {
    final db = await BookmarkDatabase.instance.database;
    final result = await db.query(
      'bookmarks',
      where: 'surahId = ?',
      whereArgs: [widget.surahId],
    );
    setState(() {
      isBookmarked = result.isNotEmpty;
    });
  }

  /// ✅ Toggle bookmark state
  Future<void> _toggleBookmark() async {
    if (isBookmarked) {
      await BookmarkDatabase.instance.removeBookmark(widget.surahId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from bookmarks ❌")),
      );
    } else {
      await BookmarkDatabase.instance.addBookmark({
        "surahId": widget.surahId,
        "title": widget.subtitle,
        "titleAr": widget.name,
        "count": widget.versesCount,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to bookmarks ✅")),
      );
    }
    _checkIfBookmarked(); // refresh state
  }


  void toggleVerseSelection(int verseNum) {
    setState(() {
      if (selectedVerses.contains(verseNum)) {
        selectedVerses.remove(verseNum);
      } else {
        selectedVerses.add(verseNum);
      }
    });
  }

  void shareSelectedVerses() {
    if (surah == null || selectedVerses.isEmpty) return;

    final selected = surah!.verses
        .where((v) => selectedVerses.contains(v.number))
        .map((v) => {
      "verseNumber": v.number,
      "arabic": v.arabic,
      "urdu": v.urdu,
    })
        .toList();

    UtilityFunctions.shareVerses(
      surahName: surah!.nameEnglish,
      verses: selected,
    );
  }


  void _handleVerseLongPress(int verseNum) {
    setState(() {
      // start selection mode if not already
      if (selectedVerses.isEmpty) {
        selectedVerses.add(verseNum);
      } else {
        // toggle
        if (selectedVerses.contains(verseNum)) {
          selectedVerses.remove(verseNum);
        } else {
          selectedVerses.add(verseNum);
        }
      }
    });
  }

  void _handleVerseTap(int verseNum) {
    setState(() {
      if (selectedVerses.isNotEmpty) {
        // ✅ selection mode → toggle verse
        if (selectedVerses.contains(verseNum)) {
          selectedVerses.remove(verseNum);
        } else {
          selectedVerses.add(verseNum);
        }
      } else {
        // ✅ no selection → play/stop verse
        if (_currentlyPlayingVerse == verseNum) {
          stopAudio();
        } else {
          final verse = surah!.verses.firstWhere((v) => v.number == verseNum);
          playVerse(verse);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.name.toString(),
        subtitle: "${widget.subtitle} – Verses: ${widget.versesCount}",
        onSettingsTap: _toggleBookmark,
        iconPath: AppImages.book_mark,
        iconColor: isBookmarked ? Colors.green : Colors.white,
        isDownloading: _isDownloading,
        downloadProgress: _downloadProgress,
        onDownloadTap: () => downloadSurahAudio(widget.surahId!),
        onCancelDownload: () => _downloadCancelToken?.cancel(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Ayah dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Right box (Dropdown numbers)
                    Container(
                      height: 50.h,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.2,
                            ), // Shadow color
                            offset: const Offset(0, 3), // x=0, y=3
                            blurRadius: 6, // blur
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedVerse,
                          hint: const Text("Select Ayah"),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("Show All"),
                            ),
                            ...List.generate(
                              widget.versesCount,
                                  (index) => DropdownMenuItem<int?>(
                                value: index + 1,
                                child: Text("Ayah ${index + 1}"),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedVerse = value;
                            });
                          },
                        ),

                      ),
                    ) ],
                ),

                const Spacer(),

                // ✅ Single container for both checkboxes
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerColor, // Container remains white
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: showArabic,
                        onChanged: (val) {
                          if (val == false && !showUrdu) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("At least one language must be selected"),
                              ),
                            );
                            return;
                          }
                          setState(() => showArabic = val!);
                        },
                        activeColor: Colors.green, // Green background when checked
                        checkColor: Colors.white,  // White tick icon
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green; // Green when checked
                          }
                          return null; // Use default for other states
                        }),
                      ),
                      const Text("Arabic"),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: showUrdu,
                        onChanged: (val) {
                          if (val == false && !showArabic) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("At least one language must be selected"),
                              ),
                            );
                            return;
                          }
                          setState(() => showUrdu = val!);
                        },
                        activeColor: Colors.green, // Green background when checked
                        checkColor: AppColors.containerColor,  // White tick icon
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green; // Green when checked
                          }
                          return null; // Use default for other states
                        }),
                      ),
                      const Text("Urdu"),
                    ],
                  ),
                ),

              ],
            ),
          ),

          /// Verses List
          Expanded(
              child: isLoading || surah == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                itemCount: selectedVerse == null ? surah!.verses.length : 1,
                itemBuilder: (context, index) {
                  final verse = selectedVerse == null
                      ? surah!.verses[index]
                      : surah!.verses[selectedVerse! - 1];

                  return Container(
                    key: verseKeys[index],
                    child: VerseTile(
                      surahName: widget.name,
                      verseNumber: verse.number,
                      arabicText: showArabic ? verse.arabic : null,
                      urduText: showUrdu ? verse.urdu : null,
                      isPlaying: _currentlyPlayingVerse == verse.number,
                      isSelected: selectedVerses.contains(verse.number), // ✅
                      onSelect: () => toggleVerseSelection(verse.number),
                      onPlay: () => playVerse(verse),
                      onStop: stopAudio,
                      onTap: () => _handleVerseTap(verse.number),
                      onLongPress: () => _handleVerseLongPress(verse.number),

                    ),
                  );
                },
              )
          ),
        ],
      ),
      floatingActionButton: selectedVerses.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: shareSelectedVerses,
        icon: const Icon(Icons.share),
        label: Text("Share (${selectedVerses.length})"),
        backgroundColor: Colors.green,
      )
          : null,
    );
  }
}*/



///Working in Last Record

import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

import '../database_helper/database_helper.dart';
import '../database_helper/logs_db.dart';
import '../database_helper/settings_db.dart';
import '../database_helper/verse_database/book_mark_db.dart';
import '../database_helper/verse_database/last_played_verse.dart';
import '../models/last_played_verse.dart';
import '../models/surah.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../utils/common_functions.dart';
import '../widgets/app_bar.dart';
import '../widgets/verse_tile.dart';

class SurahScreen extends StatefulWidget {
  final String? name;
  final String? subtitle;
  final int versesCount;
  final int? surahId;
  final String? surahNumber; // ✅ add this field
  final int? lastPlayedVerse;

  const SurahScreen({
    super.key,
    this.name,
    this.subtitle,
    required this.versesCount,
    this.surahId,
    this.surahNumber, // ✅ add in constructor
    this.lastPlayedVerse
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}


class _SurahScreenState extends State<SurahScreen> {
  int selectedAyah = 1;
  bool showArabic = true;
  bool showUrdu = true;
  bool showEnglish = false;

  // List<Verse> verses = [];

  bool isBookmarked = false;
  bool isLoading = true;
  int? selectedVerse;
  SurahModel? surah;

  final AudioPlayer _player = AudioPlayer();
  int? _currentlyPlayingVerse;

  final ScrollController _scrollController = ScrollController();

  CancelToken? _downloadCancelToken;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  final List<GlobalKey> verseKeys = [];

  Set<int> selectedVerses = {};




  @override
  void initState() {
    super.initState();

    // Load Surah data
    loadSurahData(widget.surahId!).then((data) {
      setState(() {
        surah = data;
        isLoading = false;
      });
      _checkIfBookmarked();
    });

    // 👇 Setup listener with conditional continuation
    _player.onPlayerComplete.listen((_) {
      if (_currentlyPlayingVerse != null && surah != null) {
        final currentIndex =
        surah!.verses.indexWhere((v) => v.number == _currentlyPlayingVerse);

        if (selectedVerse == null) {
          // 🔥 Mode: Play all verses
          if (currentIndex != -1 && currentIndex < surah!.verses.length - 1) {
            final nextVerse = surah!.verses[currentIndex + 1];
            playVerse(nextVerse);
          } else {
            setState(() => _currentlyPlayingVerse = null);
          }
        } else {
          // 🔥 Mode: Play single ayah only once
          setState(() => _currentlyPlayingVerse = null);
        }
      }
    });
  }



  @override
  void dispose() {
    _player.dispose(); // very important
    _scrollController.dispose();
    super.dispose();
  }







  Future<SurahModel> loadSurahData(int surahId) async {
    final arabicJson = await rootBundle.loadString("assets/json_files/quran_verses_arabic.json");
    final urduJson = await rootBundle.loadString("assets/json_files/quran_verses_urdu.json");

    final arabicData = json.decode(arabicJson)["data"]["surahs"];
    final urduData = json.decode(urduJson)["data"]["surahs"];

    final arabicSurah = arabicData[surahId - 1];
    final urduSurah = urduData[surahId - 1];

    // 🔥 Batch load cached audio
    final cachedAudios = await AudioDatabase.getAllAudiosForSurah(surahId);

    List<VerseModel> verses = [];
    for (int j = 0; j < arabicSurah["ayahs"].length; j++) {
      final arabicVerse = arabicSurah["ayahs"][j];
      final urduVerse = urduSurah["ayahs"][j];
      final verseNum = arabicVerse["numberInSurah"];

      verses.add(
        VerseModel(
          number: verseNum,
          arabic: arabicVerse["text"],
          urdu: urduVerse["text"],
          localAudioPath: cachedAudios[verseNum],
        ),
      );
    }

    verseKeys.clear();
    verseKeys.addAll(List.generate(verses.length, (_) => GlobalKey()));

    return SurahModel(
      number: arabicSurah["number"],
      nameArabic: arabicSurah["name"],
      nameEnglish: arabicSurah["englishName"],
      totalVerses: arabicSurah["ayahs"].length,
      revelationType: arabicSurah["revelationType"],
      verses: verses,
    );
  }





/*  Future<void> downloadSurahAudio(int surahId) async {
    // ✅ Force small delay to ensure DB write completes
    await Future.delayed(const Duration(milliseconds: 100));

    // ✅ Fetch latest value from DB (safe default false)
    bool isMobileDataAllowed = await SettingsDatabase.getMobileDataSetting();

    // ✅ Always returns a List<ConnectivityResult>
    final activeConnections = await Connectivity().checkConnectivity();

    // ✅ Check if mobile connection is active
    bool isOnMobile = activeConnections.contains(ConnectivityResult.mobile);

    debugPrint("📡 Active Connection: $activeConnections");
    debugPrint("📀 MobileDataAllowed (from DB): $isMobileDataAllowed");

    // ✅ Block download if on mobile data and not allowed
    if (isOnMobile && !isMobileDataAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Download over mobile data is not allowed. Please change your settings.",
          ),
        ),
      );
      return;
    }

    // ✅ Check if already downloaded
    if (surah != null &&
        surah!.verses.every((v) => v.localAudioPath != null && File(v.localAudioPath!).existsSync())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surah ${surah!.nameEnglish} has already been downloaded")),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadCancelToken = CancelToken();
    });

    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory("${dir.path}/surah_$surahId");
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    try {
      final response = await Dio().get(
        "https://api.alquran.cloud/v1/surah/$surahId/ur.khan",
      );

      final data = response.data["data"]["ayahs"];
      int total = data.length;
      int completed = 0;

      for (var ayah in data) {
        // ✅ Re-check connectivity before each ayah
        final currentConnections = await Connectivity().checkConnectivity();
        bool isCurrentlyOnMobile = currentConnections.contains(ConnectivityResult.mobile);

        if (isCurrentlyOnMobile && !isMobileDataAllowed) {
          debugPrint("⛔ Download stopped - switched to mobile data but not allowed.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Download stopped. Mobile data is not allowed."),
            ),
          );
          break;
        }

        if (_downloadCancelToken?.isCancelled ?? false) {
          throw "Download cancelled";
        }

        final url = ayah["audio"];
        final verseNum = ayah["numberInSurah"];
        final savePath = "${surahDir.path}/$verseNum.mp3";

        if (!File(savePath).existsSync()) {
          await Dio().download(
            url,
            savePath,
            cancelToken: _downloadCancelToken,
          );
        }

        await AudioDatabase.insertAudio(surahId, verseNum, savePath);

        final verse = surah?.verses.firstWhere((v) => v.number == verseNum);
        if (verse != null) verse.localAudioPath = savePath;

        completed++;
        setState(() {
          _downloadProgress = completed / total;
        });
      }

      if (mounted && completed == total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Surah ${surah!.nameEnglish} downloaded successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadCancelToken = null;
        });
      }
    }
  }*/

  Future<void> downloadSurahAudio(int surahId) async {
    // ✅ Force small delay to ensure DB write completes
    await Future.delayed(const Duration(milliseconds: 100));

    // ✅ Fetch latest settings row
    final settings = await SettingsDatabase.getSettings();

    // ✅ Convert to bool (default false if null)
    bool isMobileDataAllowed = settings['mobileDataAllowed'] == 1;

    // ✅ Always returns a List<ConnectivityResult>
    final activeConnections = await Connectivity().checkConnectivity();

    // ✅ Check if mobile connection is active
    bool isOnMobile = activeConnections.contains(ConnectivityResult.mobile);

    debugPrint("📡 Active Connection: $activeConnections");
    debugPrint("📀 MobileDataAllowed (from DB): $isMobileDataAllowed");

    // ✅ Block download if on mobile data and not allowed
    if (isOnMobile && !isMobileDataAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Download over mobile data is not allowed. Please change your settings.",
          ),
        ),
      );
      return;
    }

    // ✅ Check if already downloaded
    if (surah != null &&
        surah!.verses.every((v) => v.localAudioPath != null && File(v.localAudioPath!).existsSync())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surah ${surah!.nameEnglish} has already been downloaded")),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadCancelToken = CancelToken();
    });

    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory("${dir.path}/surah_$surahId");
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    try {
      final response = await Dio().get(
        "https://api.alquran.cloud/v1/surah/$surahId/ur.khan",
      );

      final data = response.data["data"]["ayahs"];
      int total = data.length;
      int completed = 0;

      for (var ayah in data) {
        // ✅ Re-check connectivity before each ayah
        final currentConnections = await Connectivity().checkConnectivity();
        bool isCurrentlyOnMobile = currentConnections.contains(ConnectivityResult.mobile);

        if (isCurrentlyOnMobile && !isMobileDataAllowed) {
          debugPrint("⛔ Download stopped - switched to mobile data but not allowed.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Download stopped. Mobile data is not allowed."),
            ),
          );
          break;
        }

        if (_downloadCancelToken?.isCancelled ?? false) {
          throw "Download cancelled";
        }

        final url = ayah["audio"];
        final verseNum = ayah["numberInSurah"];
        final savePath = "${surahDir.path}/$verseNum.mp3";

        if (!File(savePath).existsSync()) {
          await Dio().download(
            url,
            savePath,
            cancelToken: _downloadCancelToken,
          );
        }

        await AudioDatabase.insertAudio(surahId, verseNum, savePath);

        final verse = surah?.verses.firstWhere((v) => v.number == verseNum);
        if (verse != null) verse.localAudioPath = savePath;

        completed++;
        setState(() {
          _downloadProgress = completed / total;
        });
      }

      if (mounted && completed == total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Surah ${surah!.nameEnglish} downloaded successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadCancelToken = null;
        });
      }
    }
  }









  void playVerse(VerseModel verse) async {
    if (verse.localAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please download surah first")),
      );
      return;
    }

    setState(() {
      _currentlyPlayingVerse = verse.number;
    });

    // ✅ Save last played to DB
    await LastPlayedDb.saveLastPlayed(
      LastPlayedVerse(
          surahId: widget.surahId!,
          surahName: widget.subtitle ?? "",
          verseNumber: verse.number,
          verseCount: widget.versesCount,
          arabicText: verse.arabic,
          urduText: verse.urdu,
          surahNameArabic: widget.name

      ),
    );

    setState(() => _currentlyPlayingVerse = verse.number);

    _scrollToVerse(verse.number);

    await _player.stop();
    await _player.play(DeviceFileSource(verse.localAudioPath!));
  }



/*  void _scrollToVerse(int verseNumber) {
    final index = surah!.verses.indexWhere((v) => v.number == verseNumber);
    if (index != -1) {
      final context = verseKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }*/


  void _scrollToVerse(int verseNumber) {
    final index = surah!.verses.indexWhere((v) => v.number == verseNumber);
    if (index != -1) {
      final context = verseKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }






  void stopAudio() async {
    await _player.stop();
    setState(() => _currentlyPlayingVerse = null);
  }



  Future<void> _checkIfBookmarked() async {
    final db = await BookmarkDatabase.instance.database;
    final result = await db.query(
      'bookmarks',
      where: 'surahId = ?',
      whereArgs: [widget.surahId],
    );
    setState(() {
      isBookmarked = result.isNotEmpty;
    });
  }

  /// ✅ Toggle bookmark state
  Future<void> _toggleBookmark() async {
    if (isBookmarked) {
      await BookmarkDatabase.instance.removeBookmark(widget.surahId!);
      await LogsDatabase.addLog("Surah ${widget.surahId} ${widget.subtitle ?? ''} has been removed from bookmarks");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from bookmarks ❌")),
      );
    } else {
      await BookmarkDatabase.instance.addBookmark({
        "surahId": widget.surahId,
        "title": widget.subtitle,
        "titleAr": widget.name,
        "count": widget.versesCount,
      });
      await LogsDatabase.addLog("Surah ${widget.surahId} ${widget.subtitle ?? ''} has been bookmarked");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to bookmarks ✅")),
      );
    }
    _checkIfBookmarked();
  }



  void toggleVerseSelection(int verseNum) {
    setState(() {
      if (selectedVerses.contains(verseNum)) {
        selectedVerses.remove(verseNum);
      } else {
        selectedVerses.add(verseNum);
      }
    });
  }

  void shareSelectedVerses() async {
    if (surah == null || selectedVerses.isEmpty) return;

    final selected = surah!.verses
        .where((v) => selectedVerses.contains(v.number))
        .map((v) => {
      "verseNumber": v.number,
      "arabic": v.arabic,
      "urdu": v.urdu,
    })
        .toList();

    for (var v in selected) {
      await LogsDatabase.addLog(
        "Verse ${v['verseNumber']} of Surah ${widget.surahId} ${widget.subtitle ?? ''} has been shared",
      );
    }

    UtilityFunctions.shareVerses(
      surahName: surah!.nameEnglish,
      verses: selected,
    );
  }



  void _handleVerseLongPress(int verseNum) {
    setState(() {
      // start selection mode if not already
      if (selectedVerses.isEmpty) {
        selectedVerses.add(verseNum);
      } else {
        // toggle
        if (selectedVerses.contains(verseNum)) {
          selectedVerses.remove(verseNum);
        } else {
          selectedVerses.add(verseNum);
        }
      }
    });
  }

  void _handleVerseTap(int verseNum) {
    setState(() {
      if (selectedVerses.isNotEmpty) {
        // ✅ selection mode → toggle verse
        if (selectedVerses.contains(verseNum)) {
          selectedVerses.remove(verseNum);
        } else {
          selectedVerses.add(verseNum);
        }
      } else {
        // ✅ no selection → play/stop verse
        if (_currentlyPlayingVerse == verseNum) {
          stopAudio();
        } else {
          final verse = surah!.verses.firstWhere((v) => v.number == verseNum);
          playVerse(verse);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.subtitle.toString() /*widget.name.toString()*/,
        subtitle: 'Verses: ${widget.versesCount}',/*"${widget.subtitle} – Verses: ${widget.versesCount}"*/
        onSettingsTap: _toggleBookmark,
        iconPath: AppImages.book_mark,
        iconColor: isBookmarked ? Colors.green : Colors.white,
        isDownloading: _isDownloading,
        downloadProgress: _downloadProgress,
        onDownloadTap: () => downloadSurahAudio(widget.surahId!),
        onCancelDownload: () => _downloadCancelToken?.cancel(),
        requiredNotification: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Ayah dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Right box (Dropdown numbers)
                    Container(
                      height: 50.h,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.2,
                            ), // Shadow color
                            offset: const Offset(0, 3), // x=0, y=3
                            blurRadius: 6, // blur
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedVerse,
                          hint: const Text("Select Ayah"),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("Show All"),
                            ),
                            ...List.generate(
                              widget.versesCount,
                                  (index) => DropdownMenuItem<int?>(
                                value: index + 1,
                                child: Text("Ayah ${index + 1}"),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedVerse = value;
                            });
                          },
                        ),

                      ),
                    ) ],
                ),

                const Spacer(),

                // ✅ Single container for both checkboxes
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerColor, // Container remains white
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: showArabic,
                        onChanged: (val) {
                          if (val == false && !showUrdu) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("At least one language must be selected"),
                              ),
                            );
                            return;
                          }
                          setState(() => showArabic = val!);
                        },
                        activeColor: Colors.green, // Green background when checked
                        checkColor: Colors.white,  // White tick icon
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green; // Green when checked
                          }
                          return null; // Use default for other states
                        }),
                      ),
                      const Text("Arabic"),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: showUrdu,
                        onChanged: (val) {
                          if (val == false && !showArabic) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("At least one language must be selected"),
                              ),
                            );
                            return;
                          }
                          setState(() => showUrdu = val!);
                        },
                        activeColor: Colors.green, // Green background when checked
                        checkColor: AppColors.containerColor,  // White tick icon
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green; // Green when checked
                          }
                          return null; // Use default for other states
                        }),
                      ),
                      const Text("Urdu"),
                    ],
                  ),
                ),

              ],
            ),
          ),

          /// Verses List
          Expanded(
              child: isLoading || surah == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                itemCount: selectedVerse == null ? surah!.verses.length : 1,
                itemBuilder: (context, index) {
                  // actualIndex maps the builder index -> real verse index in list
                  final int actualIndex = selectedVerse == null ? index : (selectedVerse! - 1);
                  final verse = surah!.verses[actualIndex];

                  return Container(
                    key: verseKeys[actualIndex], // use correct key for the verse
                    child: VerseTile(
                      surahName: widget.name,
                      verseNumber: verse.number,
                      arabicText: showArabic ? verse.arabic : null,
                      urduText: showUrdu ? verse.urdu : null,
                      isPlaying: _currentlyPlayingVerse == verse.number,
                      isSelected: selectedVerses.contains(verse.number),
                      onSelect: () => toggleVerseSelection(verse.number),
                      onPlay: () => playVerse(verse),
                      onStop: stopAudio,
                      onTap: () => _handleVerseTap(verse.number),
                      onLongPress: () => _handleVerseLongPress(verse.number),
                    ),
                  );
                },

              )
          ),
        ],
      ),
      floatingActionButton: selectedVerses.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: shareSelectedVerses,
        icon: const Icon(Icons.share),
        label: Text("Share (${selectedVerses.length})"),
        backgroundColor: Colors.green,
      )
          : null,
    );
  }
}