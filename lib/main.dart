import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

void main() => runApp(const AitSlimaneApp());

class AitSlimaneApp extends StatelessWidget {
  const AitSlimaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جمعية أيت سليمان',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('جمعية أيت سليمان للتنمية', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildMenuItem(
                context,
                title: 'استخلاص الفواتير والمسح',
                subtitle: 'مسح باركود العداد وتسجيل الأداء',
                icon: Icons.qr_code_scanner,
                color: Colors.blue,
                destination: const ScannerBillingPage(),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'قائمة المشتركين',
                subtitle: 'عرض المشتركين والديون السابقة',
                icon: Icons.people,
                color: Colors.green,
                destination: const MembersListPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      ),
    );
  }
}

// ----------------- صفحة المسح واستخلاص الفاتورة -----------------
class ScannerBillingPage extends StatefulWidget {
  const ScannerBillingPage({super.key});

  @override
  State<ScannerBillingPage> createState() => _ScannerBillingPageState();
}

class _ScannerBillingPageState extends State<ScannerBillingPage> {
  final String apiBase = "https://c1.appy.ma/ce/api";
  Map<String, dynamic>? invoice;
  bool loading = false;

  Future<void> loadInvoice(String meter) async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('$apiBase/get_by_meter.php?meter=$meter'));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['status'] == true) {
        setState(() => invoice = data['data']);
      } else {
        _notify(data['message'] ?? 'العداد غير موجود');
      }
    } catch (_) {
      _notify('خطأ في الاتصال بالسيرفر');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> processPayment(String subCode) async {
    setState(() => loading = true);
    try {
      final res = await http.post(
        Uri.parse('$apiBase/pay_invoice.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'subscriber_code': subCode}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['status'] == true) {
        setState(() => invoice?['payment_status'] = 'مدفوع');
        _notify('تم استخلاص الفاتورة بنجاح', isError: false);
      } else {
        _notify('فشل الاستخلاص');
      }
    } catch (_) {
      _notify('تعذر إتمام العملية');
    } finally {
      setState(() => loading = false);
    }
  }

  void _notify(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
      ),
    );
  }

  void _openCamera() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: 400,
        child: MobileScanner(
          onDetect: (capture) {
            final code = capture.barcodes.firstOrNull?.rawValue;
            if (code != null) {
              Navigator.pop(ctx);
              loadInvoice(code);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('استخلاص فواتير الماء'),
          actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _openCamera)],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : invoice == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, size: 70, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('اضغط لمسح باركود عداد المشترك'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.qr_code),
                          label: const Text('تشغيل الكاميرا'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(invoice!['full_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('رقم العداد: ${invoice!['meter_number']} \vert{} الكود: ${invoice!['subscriber_code']}'),
                            const Divider(height: 20),
                            _detailRow('الاستهلاك:', '${invoice!['consumption_m3']} م³'),
                            _detailRow('واجب الاستهلاك:', '${invoice!['consumption_cost']} درهم'),
                            _detailRow('الواجبات الثابتة:', '${invoice!['fixed_fees']} درهم'),
                            _detailRow('واجب الإمام:', '${invoice!['imam_fee']} درهم'),
                            _detailRow('قسط الاشتراك:', '${invoice!['subscription_fee']} درهم'),
                            const Divider(height: 20),
                            _detailRow('المبلغ الإجمالي:', '${invoice!['total_amount']} درهم', isBold: true),
                            const SizedBox(height: 12),
                            Center(
                              child: Chip(
                                label: Text(invoice!['payment_status'], style: const TextStyle(color: Colors.white)),
                                backgroundColor: invoice!['payment_status'] == 'مدفوع' ? Colors.green : Colors.red,
                              ),
                            ),
                            if (invoice!['payment_status'] != 'مدفوع') ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                                onPressed: () => processPayment(invoice!['subscriber_code']),
                                child: const Text('تأكيد الاستخلاص الآن', style: TextStyle(color: Colors.white)),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _detailRow(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// ----------------- صفحة
