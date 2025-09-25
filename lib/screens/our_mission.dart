import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_app/screens/settings_setup.dart';

import '../utils/app_images.dart';
import '../widgets/app_bar.dart';
import '../widgets/customTextWidget.dart';
import '../widgets/mission_card.dart';

class OurMissionScreen extends StatelessWidget {
  const OurMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: "First Time Setup",

        // subtitle: "${widget.subtitle} – Verses: ${widget.versesCount}",
        onSettingsTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsPageSetup(skip: false,)));
        },
        requiredNotification: true,
        iconPath: AppImages.settings,

        // actionText: "Skip",

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MissionCard(
              title: "Our Mission",
              subtitle: "Memorize. Understand. Live the Qur’an.",
              description:
              "In our busy daily lives, we often struggle to find enough time to recite and understand the Qur’an...",

            ),
            MissionCard(
              title: "Share the Mission",
              subtitle: "خَيْرُكُم مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ",
              description:
              "The best among you are those who learn the Qur’an and teach it.",
              buttonText: "Share",
              onButtonTap: () {
                // Share action
              },
            ),
            MissionCard(
              title: "Intro",
              subtitle: "Watch Intro",
              showVideoBox: true,
            ),
          ],
        ),
      ),
    );
  }
}