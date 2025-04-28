// lib/ui/widgets/order/order_card.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';

class OrderCard extends StatelessWidget {
  final OrderDto order;

  const OrderCard({super.key, required this.order});

  // Xác định màu sắc dựa trên trạng thái đơn hàng
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade100;
      case 'Confirmed':
        return Colors.blue.shade100;
      case 'Shipped':
        return Colors.purple.shade100;
      case 'Delivered':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // Xác định icon dựa trên trạng thái đơn hàng
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Confirmed':
        return Icons.check_circle_outline;
      case 'Shipped':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formattedDate = DateFormat('dd/MM/yyyy').format(order.createdAt);

    final bool canRate = order.deliveredDate != null &&
        DateTime.now().difference(order.deliveredDate!).inDays <= 14;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Product: ${order.orderItems?.length ?? 0}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Payment: ${formatter.format(order.paymentAmount)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Method: ${order.paymentMethod}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (order.status == "Delivered" &&
                        order.deliveredDate != null)
                      Text(
                        'Delivered Date: ${DateFormat('dd/MM/yyyy').format(order.deliveredDate!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
                if (order.status != null && order.status!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.status!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (order.status == "Delivered" && canRate)
              const SizedBox(height: 1),
            if (order.status == "Delivered" && canRate)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 40,
                    width: 90,
                    child: CustomButton(
                      text: "Rate",
                      onPressed: () {
                        if (kIsWeb) {
                          context.go('/rate-order/${order.id}');
                        } else {
                          context.push('/rate-order/${order.id}');
                        }
                      },
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
