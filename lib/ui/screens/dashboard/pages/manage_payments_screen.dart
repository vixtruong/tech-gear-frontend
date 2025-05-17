import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/payment_dto.dart';
import 'package:techgear/providers/order_providers/statistic_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html; // Chỉ dùng cho web

class ManagePaymentsScreen extends StatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticProvider>(context, listen: false).fetchPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _sortPayments(List<PaymentDto> payments) {
    payments.sort((a, b) {
      final dateA = a.paidAt ?? DateTime(1970);
      final dateB = b.paidAt ?? DateTime(1970);
      return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateB);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white, // Nền trắng cho dialog
            textTheme: const TextTheme(
              bodyLarge:
                  TextStyle(color: Colors.black), // Chữ đen cho nội dung chính
              bodyMedium:
                  TextStyle(color: Colors.black), // Chữ đen cho nội dung phụ
              headlineSmall:
                  TextStyle(color: Colors.black), // Chữ đen cho tiêu đề
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Màu chính (nút, chọn ngày)
              onPrimary: Colors.white, // Chữ trên nền primary
              surface: Colors.white, // Nền của lịch
              onSurface: Colors.black, // Chữ trên nền surface (ngày, tháng)
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: Colors.white, // Nền trắng cho dialog
              contentTextStyle:
                  TextStyle(color: Colors.black), // Chữ đen cho nội dung
              titleTextStyle:
                  TextStyle(color: Colors.black), // Chữ đen cho tiêu đề
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Chữ đen cho nút (Cancel, OK)
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _exportToExcel(List<PaymentDto> payments) async {
    // Tạo file Excel
    final excel = Excel.createExcel();
    final sheet = excel['Payments'];

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Order ID'),
      TextCellValue('Amount'),
      TextCellValue('Method'),
      TextCellValue('Paid At'),
    ]);

    for (var payment in payments) {
      sheet.appendRow([
        TextCellValue(payment.id.toString()),
        TextCellValue(payment.orderId.toString()),
        TextCellValue(payment.amount.toString()),
        TextCellValue(payment.method ?? 'N/A'),
        TextCellValue(payment.paidAt?.toIso8601String() ?? 'Not Paid'),
      ]);
    }

    // Mã hóa file Excel
    final excelBytes = excel.encode();
    if (excelBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to encode Excel file')),
      );
      return;
    }

    if (kIsWeb) {
      // Xử lý trên web: Tạo file và tải xuống
      final blob = html.Blob([excelBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download',
            'payments_${DateTime.now().millisecondsSinceEpoch}.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel file downloaded')),
      );
    } else {
      // Xử lý trên di động
      if (await Permission.storage.request().isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/payments_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excelBytes);

        if (await file.exists()) {
          // Chia sẻ file trên di động
          // ignore: deprecated_member_use
          await Share.shareFiles([filePath],
              text: 'Exported Payments Excel File');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel file saved at $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save Excel file')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Payments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey[600],
          overlayColor: WidgetStateProperty.all(Colors.grey[200]),
          indicatorColor: Colors.blue,
          indicatorWeight: 2.0,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Paid'),
            Tab(text: 'Unpaid'),
          ],
        ),
      ),
      body: Consumer<StatisticProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final paidPayments =
              provider.payments.where((p) => p.paidAt != null).toList();
          final unpaidPayments =
              provider.payments.where((p) => p.paidAt == null).toList();

          _sortPayments(paidPayments);
          _sortPayments(unpaidPayments);

          final filteredPaid = _selectedDateRange != null
              ? paidPayments.where((p) {
                  final paidAt = p.paidAt;
                  return paidAt != null &&
                      paidAt.isAfter(_selectedDateRange!.start) &&
                      paidAt.isBefore(
                          _selectedDateRange!.end.add(const Duration(days: 1)));
                }).toList()
              : paidPayments;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _selectDateRange(context),
                          icon: const Icon(
                            Icons.date_range,
                            color: Colors.black,
                          ),
                          label: Text(
                            _selectedDateRange == null
                                ? 'Select Date Range'
                                : '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                            });
                          },
                        ),
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: CustomButton(
                            text: "Export",
                            onPressed: () => _exportToExcel(
                                _tabController.index == 0
                                    ? filteredPaid
                                    : unpaidPayments),
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentList(filteredPaid),
                    _buildPaymentList(unpaidPayments),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentList(List<PaymentDto> payments) {
    if (payments.isEmpty) {
      return const Center(child: Text('No payments found'));
    }
    return ListView.builder(
      itemCount: payments.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text('Payment #${payment.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${payment.orderId}'),
                Text('Amount: \$${payment.amount}'),
                Text('Method: ${payment.method ?? 'N/A'}'),
                Text('Paid At: ${payment.paidAt?.toString() ?? 'Not Paid'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
