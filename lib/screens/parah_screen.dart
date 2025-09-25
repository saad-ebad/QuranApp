import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class ParahScreen extends StatefulWidget {
  const ParahScreen({super.key});

  @override
  State<ParahScreen> createState() => _ParahScreenState();
}

class _ParahScreenState extends State<ParahScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Parah Screen", style: TextStyle(fontSize: 20.sp, color: AppColors.purpleAppBarColor),),
    );
  }
}
