class VerseModel {
  final int number;
  final String arabic;
  final String urdu;
  String? localAudioPath; // 🔥 to store downloaded file

  VerseModel({
    required this.number,
    required this.arabic,
    required this.urdu,
    this.localAudioPath,
  });
}
