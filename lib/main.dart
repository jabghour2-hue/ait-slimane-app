import 'package:flutter/material.dart';

void main() => runApp(const WaterApp());

class WaterApp extends StatelessWidget {
  const WaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('جمعية أيت سليمان للتنمية'),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildCard(
                  Icons.qr_code_scanner,
                  'استخلاص الفواتير والمسح',
                  'مسح باركود العداد وتسجيل الأداء',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildCard(
                  Icons.people,
                  'قائمة المشتركين',
                  'عرض المشتركين والديون السابقة',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildCard(
                  Icons.print,
                  'طابعة البلوتوث',
                  'إعدادات الطباعة الحرارية الميدانية',
                  Colors.indigo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCard(IconData icon, String title, String sub, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
