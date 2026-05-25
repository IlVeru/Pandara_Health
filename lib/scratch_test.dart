// ignore_for_file: avoid_print

import 'core/constants/weekly_report_data.dart';

void main() {
  final String reportText = WeeklyReportData.getFormattedReportText();
  final String message = "Halo Dr. Sarah, saya ingin berkonsultasi.\n\n$reportText";
  final String phone = '6285176914026';
  
  final String encodedMessage = Uri.encodeComponent(message);
  final Uri url = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
  
  print('URL String:');
  print(url.toString());
}
