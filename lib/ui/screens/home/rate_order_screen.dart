// lib/ui/screens/rate_order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/product_item_info_dto.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/ui/widgets/product/product_rating_item.dart';

class RateOrderScreen extends StatefulWidget {
  final int orderId;

  const RateOrderScreen({super.key, required this.orderId});

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  late OrderProvider _orderProvider;
  List<ProductItemInfoDto> items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final fetchItems =
          await _orderProvider.fetchOrderItemsInfoByOrderId(widget.orderId);
      setState(() {
        items = fetchItems ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Rate Order #${widget.orderId}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInformations,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : items.isEmpty
                    ? Center(
                        child: Text(
                          'No items to rate',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return ProductRatingItem(
                                  item: item,
                                  orderId: widget.orderId,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
