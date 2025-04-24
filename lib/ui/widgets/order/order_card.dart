import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/dtos/order_dto.dart';

class OrderCard extends StatelessWidget {
  final OrderDto order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formattedDate = DateFormat('dd/MM/yyyy').format(order.createdAt);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Text('Order #${order.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(formattedDate),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Product: ${order.orderItems?.length ?? 0}'),
                Text('Payment: ${formatter.format(order.paymentAmount)}'),
                Text('Method: ${order.paymentMethod}'),
              ],
            ),
            if (order.status != null && order.status!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order.status!,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }
}
