import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/order_detail_dto.dart';
import 'package:techgear/dtos/order_item_detail_dto.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final bool? isAdmin;

  const OrderDetailScreen(
      {super.key, required this.orderId, this.isAdmin = false});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderProvider _orderProvider;
  OrderDetailDto? _orderDetailDto;
  bool _isLoading = true;

  // Define VND currency formatter
  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      final fetchData = await _orderProvider.fetchOrderDetail(widget.orderId);
      setState(() {
        _orderDetailDto = fetchData;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading order: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to generate and print shipping label
  Future<void> _generateShippingLabel() async {
    if (_orderDetailDto == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: Store Information
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TechGear Store',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('Address: 123 Business Street, Hanoi, Vietnam'),
                    pw.Text('Phone: +84 123 456 789'),
                    pw.Text('Email: support@techgear.vn'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Shipping Information
              pw.Text(
                'Shipping Label',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Recipient: ${_orderDetailDto!.recipientName}',
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('Phone: ${_orderDetailDto!.recipientPhone}',
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('Address: ${_orderDetailDto!.address}',
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('Email: ${_orderDetailDto!.userEmail}',
                        style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Order Information
              pw.Text(
                'Order #${widget.orderId}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(_orderDetailDto!.createdAt.toLocal())}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Product',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('SKU',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Quantity',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._orderDetailDto!.orderItems.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.productName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.sku),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.quantity.toString()),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Total
              pw.Text(
                'Total: ${currencyFormatter.format(_orderDetailDto!.paymentTotalPrice)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Notes
              pw.Text(
                'Notes: Please handle with care. Contact support@techgear.vn for any issues.',
                style:
                    pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    // Print or save the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          "Order #${widget.orderId}",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
        actions: [
          if (widget.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.blueAccent),
              onPressed:
                  _orderDetailDto == null ? null : _generateShippingLabel,
              tooltip: 'Print Shipping Label',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent))
          : _orderDetailDto == null
              ? const Center(
                  child: Text(
                    "Order not found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionCard("Customer Information", [
                      _buildInfoRow("Email", _orderDetailDto!.userEmail),
                      _buildInfoRow(
                          "Recipient", _orderDetailDto!.recipientName),
                      _buildInfoRow("Phone", _orderDetailDto!.recipientPhone),
                      _buildInfoRow("Address", _orderDetailDto!.address),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionCard("Order Details", [
                      _buildInfoRow(
                          "Coupon Code", _orderDetailDto!.couponCode ?? "None"),
                      _buildInfoRow("Points Used",
                          _orderDetailDto!.point?.toString() ?? "0"),
                      _buildInfoRow(
                        "Created At",
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(_orderDetailDto!.createdAt.toLocal()),
                      ),
                      _buildInfoRow(
                        "Order Total",
                        currencyFormatter
                            .format(_orderDetailDto!.orderTotalPrice),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionCard("Payment", [
                      _buildInfoRow("Method", _orderDetailDto!.paymentMethod),
                      _buildInfoRow(
                        "Amount Paid",
                        currencyFormatter
                            .format(_orderDetailDto!.paymentTotalPrice),
                      ),
                      _buildInfoRow("Status", _orderDetailDto!.paymentStatus),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      "Products (${_orderDetailDto!.orderItems.length})",
                      _orderDetailDto!.orderItems
                          .map((item) => _buildOrderItemCard(item))
                          .toList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemDetailDto item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "SKU: ${item.sku}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text(
                        "Quantity: ${item.quantity}",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      Text(
                        "Price: ${currencyFormatter.format(item.price)}",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      Text(
                        "Discount: ${item.discount}%",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      Text(
                        "Total: ${currencyFormatter.format(item.totalPrice)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
