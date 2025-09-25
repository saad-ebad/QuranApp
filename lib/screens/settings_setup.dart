import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_app/services/notification_services.dart';
import 'package:quran_app/utils/app_colors.dart';
import 'package:quran_app/utils/app_images.dart';
import '../database_helper/settings_db.dart';
import '../widgets/app_bar.dart';
import '../widgets/customTextWidget.dart';
import 'main_home.dart';

class SettingsPageSetup extends StatefulWidget {
  bool skip =true;
   SettingsPageSetup({ this.skip =true, super.key});

  @override
  State<SettingsPageSetup> createState() => _SettingsPageSetupState();
}

class _SettingsPageSetupState extends State<SettingsPageSetup> {


  // State variables
  bool wifiOnly = true;
  bool mobileData = false;

  bool allowScreenshot = true;
  bool watermark = false;

  bool dailyNotif = true;
  bool weeklyNotif = true;

  String preferredReciter = "Fateh Muhammad Jalandhari";

  double downloadProgress = 0.19; // 19%

  String selectedTheme = "Light Mode";

  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    print("Value of skip = ${widget.skip}");
    loadSettings();
  }



  // Future<void> loadSettings() async {
  //   final settings = await SettingsDatabase.getSettings();
  //   setState(() {
  //     mobileData = settings['mobileDataAllowed'] == 1;
  //     dailyNotif = settings['dailyNotification'] == 1;
  //     selectedTheme = settings['selectedTheme'];
  //     if (settings['customNotificationTime'] != null) {
  //       final parts = (settings['customNotificationTime'] as String).split(':');
  //       selectedTime = TimeOfDay(
  //         hour: int.parse(parts[0]),
  //         minute: int.parse(parts[1]),
  //       );
  //     }
  //   });
  // }

  Future<void> loadSettings() async {
    final settings = await SettingsDatabase.getSettings();
    setState(() {
      mobileData = settings['mobileDataAllowed'] == 1;
      dailyNotif = settings['dailyNotification'] == 1;
      selectedTheme = settings['selectedTheme'];
      if (settings['customNotificationTime'] != null) {
        final parts = (settings['customNotificationTime'] as String).split(':');
        selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      // ✅ Load custom reminder checkbox
      CustomReminderTileState.isSelectedGlobal = settings['customReminderEnabled'] == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.skip ==false ? "Settings" : "First Time Setup",

        // subtitle: "${widget.subtitle} – Verses: ${widget.versesCount}",
        onSettingsTap: widget.skip ==false ? null : () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QuranHomeScreen()),
          );
        },
        iconPath: widget.skip ==false ? null : AppImages.skip,

        actionText: widget.skip ==false ? "" :"Skip",
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.0.w,
                    right: 12.0,
                    top: 8.0.h,
                    bottom: 8.0.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle("Connectivity"),

                      // ✅ Wi-Fi Option (Always ON & Disabled)
                      optionTile(
                        "Download audio only on Wi-Fi",
                        true, // Always ON
                        null, // No onChanged
                        enabled:
                            false, // Custom param in optionTile (disable tap)
                      ),

                      // ✅ Mobile Data Option (Editable)
                      optionTile(
                        "Allow mobile data for audio.",
                        mobileData,
                            (val) async {
                          await  SettingsDatabase.saveSettings(
                            mobileData: val,
                            dailyNotification: dailyNotif,
                            customTime: selectedTime != null
                                ? "${selectedTime!.hour}:${selectedTime!.minute}"
                                : null,
                            selectedTheme: selectedTheme,
                            customReminderEnabled: CustomReminderTileState.isSelectedGlobal, // ✅ add this
                          );
                          setState(() {
                            mobileData = val;
                          });
                        },
                      ),


                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Notifications
              Container(
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
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.0.w,
                    right: 12.0,
                    top: 8.0.h,
                    bottom: 8.0.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        "Notifications\nRemind me to track my recitation.",
                      ),

                      optionTile("Daily (default)", dailyNotif, (val) {
                        setState(() {
                          dailyNotif = val;

                          if (dailyNotif) {
                            // ✅ Schedule default reminders when user turns it ON
                            NotificationService.scheduleUserRemindersFromDB();
                          } else {
                            // (Optional) cancel daily reminders if turned OFF
                            NotificationService.cancelUserReminders();
                          }
                        });
                      }),

                      SizedBox(height: 12.h),

                      CustomReminderTile(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Audio Setup
              Container(
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
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.0.w,
                    right: 12.0,
                    top: 8.0.h,
                    bottom: 8.0.h,
                  ),
                  child: themeDropdown(),
                ),
              ),

              // Theme Selection
              Spacer(),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await SettingsDatabase.saveSettings(
                        mobileData: mobileData,
                        dailyNotification: dailyNotif,
                        customTime: selectedTime != null
                            ? "${selectedTime!.hour}:${selectedTime!.minute}"
                            : null,
                        customReminderEnabled: CustomReminderTileState
                            .isSelectedGlobal, // ✅ now passed
                        selectedTheme: selectedTheme,
                      );

                      if (dailyNotif) {
                        NotificationService.reScheduleFromDatabase();
                      } else {
                        NotificationService.cancelUserReminders();
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Settings Applied Successfully!")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => QuranHomeScreen()),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.purpleAppBarColorUpper, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // 4 radius
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Apply Settings",
                      style: TextStyle(
                        color: AppColors.yellowColor, // White text
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: CustomText(
        text: title,
        fontSize: 14.sp,
        fontWeight: TextWeight.medium,
        color: Colors.black,
      ),
    );
  }

  Widget optionTile(
    String title,
    bool value,
    Function(bool)? onChanged, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled && onChanged != null
          ? () => onChanged(!value)
          : null, // Disable tap if not enabled
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6, // Grey out if disabled
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: value ? Colors.green : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6.r),
            color: AppColors.containerColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                value ? Icons.check : Icons.check_box_outline_blank,
                color: value ? Colors.green : Colors.grey,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text: title,
                  fontSize: 12.sp,
                  fontWeight: TextWeight.medium,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget reciterOption(String name) {
    final isSelected = preferredReciter == name;
    return GestureDetector(
      onTap: () => setState(() => preferredReciter = name),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6.r),
          color: AppColors.containerColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: name,
              fontSize: 12.sp,
              fontWeight: TextWeight.medium,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget themeDropdown() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Theme",
                fontSize: 14.sp,
                fontWeight: TextWeight.medium,
              ),
              CustomText(
                text: "Visual Preference",
                fontSize: 12.sp,
                fontWeight: TextWeight.regular,
                color: Colors.grey[600], // Optional: add subtle color
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w), // Add some spacing
        Expanded(
          child: Container(
            height: 40,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            child: DropdownButton<String>(
              value: selectedTheme,
              isExpanded: true,
              underline: SizedBox(), // Remove default underline
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownColor: Colors.white, // Dropdown background color
              borderRadius: BorderRadius.circular(8.r),
              items: ["Light Mode", "Dark Mode"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: CustomText(
                        text: e,
                        fontSize: 14.sp, // Slightly smaller font
                        fontWeight: TextWeight.medium,
                        color: AppColors.purpleAppBarColor,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedTheme = val!);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ Public state holder (can be accessed anywhere)
class CustomReminderTileState {
  static bool isSelectedGlobal = false;
}

class CustomReminderTile extends StatefulWidget {
  const CustomReminderTile({super.key});

  @override
  State<CustomReminderTile> createState() => _CustomReminderTileState();
}

class _CustomReminderTileState extends State<CustomReminderTile> {
  Future<void> _pickTime(BuildContext context) async {
    await NotificationService.pickTimeAndSchedule(context, 4);

    // ✅ Auto-check the box when user picks a time
    setState(() {
      CustomReminderTileState.isSelectedGlobal = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                CustomReminderTileState.isSelectedGlobal =
                !CustomReminderTileState.isSelectedGlobal;
              });
            },
            child: CustomReminderTileState.isSelectedGlobal
                ? const Icon(Icons.check, size: 20, color: Colors.green)
                : Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  CustomReminderTileState.isSelectedGlobal =
                  !CustomReminderTileState.isSelectedGlobal;
                });
              },
              child: const Text(
                "Pick Custom Reminder Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _pickTime(context), // ✅ auto-checks after picking
            child: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}


