import 'package:flutter/material.dart';
import 'package:quran_app/utils/app_images.dart';
import '../../models/app_log.dart';
import 'package:intl/intl.dart';
import '../database_helper/logs_db.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bar.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late Future<List<AppLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = LogsDatabase.getAllLogs();
  }

  String _formatDate(DateTime dt) {
    return DateFormat('EEE, dd MMM yyyy').format(dt);
  }

  String _formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Activity Logs",automaticallyImplyLeading: true,),
      body: FutureBuilder<List<AppLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                "No logs found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          // ✅ Group logs by date
          final groupedLogs = <String, List<AppLog>>{};
          for (var log in logs) {
            final dateKey = _formatDate(log.timestamp);
            groupedLogs.putIfAbsent(dateKey, () => []);
            groupedLogs[dateKey]!.add(log);
          }

          final sortedDates = groupedLogs.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dayLogs = groupedLogs[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📅 Date Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      date,
                      style:  TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purpleAppBarColorUpper,
                      ),
                    ),
                  ),

                  // 📝 Logs of that day
                  ...dayLogs.map((log) {
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.history, color: Colors.blue),
                        ),
                        title: Text(
                          log.message,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _formatTime(log.timestamp),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList()
                ],
              );
            },
          );
        },
      ),
    );
  }
}

