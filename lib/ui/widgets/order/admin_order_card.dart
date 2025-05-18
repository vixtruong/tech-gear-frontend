import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';

class AdminOrderCard extends StatefulWidget {
  final OrderDto order;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onShip;
  final VoidCallback? onDeliver;

  const AdminOrderCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onConfirm,
    this.onShip,
    this.onDeliver,
  });

  @override
  State<AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<AdminOrderCard> {
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
      case 'Canceled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

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
      case 'Canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formattedDate =
        DateFormat('dd/MM/yyyy' ' - ' 'HH:mm').format(widget.order.createdAt);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (kIsWeb) {
            context.pushReplacement('/orders/${widget.order.id}/detail');
          } else {
            context.push('/orders/${widget.order.id}/detail');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Order #${widget.order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Product: ${widget.order.orderItems?.length ?? 0}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Payment: ${formatter.format(widget.order.paymentAmount)}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Method: ${widget.order.paymentMethod}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.order.confirmedDate != null)
                          Text(
                            'Confirmed Date: ${DateFormat('dd/MM/yyyy' ' - ' 'HH:mm').format(widget.order.confirmedDate!)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.order.shippedDate != null)
                          Text(
                            'Shipped Date: ${DateFormat('dd/MM/yyyy' ' - ' 'HH:mm').format(widget.order.shippedDate!)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.order.deliveredDate != null)
                          Text(
                            'Delivered Date: ${DateFormat('dd/MM/yyyy' ' - ' 'HH:mm').format(widget.order.deliveredDate!)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.order.canceledDate != null)
                          Text(
                            'Canceled Date: ${DateFormat('dd/MM/yyyy' ' - ' 'HH:mm').format(widget.order.canceledDate!)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.order.cancelReason != null &&
                            widget.order.cancelReason != '')
                          Text(
                            'Canceled Reason: ${widget.order.cancelReason}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                  if (widget.order.status != null &&
                      widget.order.status!.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.order.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(widget.order.status),
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.order.status!,
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.order.status == 'Pending') ...[
                    SizedBox(
                      height: 40,
                      width: 105,
                      child: CustomButton(
                          text: "Cancel",
                          onPressed: widget.onCancel ?? () {},
                          color: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      width: 110,
                      child: CustomButton(
                          text: "Confirm",
                          onPressed: widget.onConfirm ?? () {},
                          color: Colors.blue),
                    ),
                  ],
                  if (widget.order.status == 'Confirmed')
                    SizedBox(
                      height: 40,
                      width: 105,
                      child: CustomButton(
                          text: "Ship",
                          onPressed: widget.onShip ?? () {},
                          color: Colors.purple),
                    ),
                  if (widget.order.status == 'Shipped')
                    SizedBox(
                      height: 40,
                      width: 120,
                      child: CustomButton(
                          text: "Delivered",
                          onPressed: widget.onDeliver ?? () {},
                          color: Colors.green),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
