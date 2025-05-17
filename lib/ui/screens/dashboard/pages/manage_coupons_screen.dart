import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/order/coupon.dart';
import 'package:techgear/providers/order_providers/coupon_provider.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';

class ManageCouponsScreen extends StatefulWidget {
  const ManageCouponsScreen({super.key});

  @override
  State<ManageCouponsScreen> createState() => _ManageCouponsScreenState();
}

class _ManageCouponsScreenState extends State<ManageCouponsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  DateTime? _expirationDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).fetchCoupons();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _usageLimitController.dispose();
    _minOrderAmountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showCouponForm({Coupon? coupon}) {
    if (coupon != null) {
      _codeController.text = coupon.code;
      _valueController.text = coupon.value.toString();
      _usageLimitController.text = coupon.usageLimit.toString();
      _minOrderAmountController.text = coupon.minimumOrderAmount.toString();
      _expirationDate = coupon.expirationDate;
    } else {
      _codeController.clear();
      _valueController.clear();
      _usageLimitController.clear();
      _minOrderAmountController.clear();
      _expirationDate = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text(
                      coupon == null ? 'Add New Coupon' : 'Edit Coupon',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _codeController,
                      hint: 'Coupon Code',
                      inputType: TextInputType.text,
                      isSearch: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a coupon code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _valueController,
                      hint: 'Discount Value',
                      inputType: TextInputType.number,
                      isSearch: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a discount value';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _usageLimitController,
                      hint: 'Usage Limit',
                      inputType: TextInputType.number,
                      isSearch: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a usage limit';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _minOrderAmountController,
                      hint: 'Minimum Order Amount',
                      inputType: TextInputType.number,
                      isSearch: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a minimum order amount';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        return ListTile(
                          title: Text(
                            _expirationDate == null
                                ? 'Select Expiration Date'
                                : 'Expiration: ${DateFormat('dd/MM/yyyy').format(_expirationDate!)}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dialogBackgroundColor: Colors.white,
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _expirationDate = pickedDate;
                              });
                              setModalState(() {});
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final couponData = Coupon(
                                id: coupon?.id ?? 0,
                                code: _codeController.text.trim(),
                                value: int.parse(_valueController.text),
                                usageLimit:
                                    int.parse(_usageLimitController.text),
                                minimumOrderAmount:
                                    int.parse(_minOrderAmountController.text),
                                expirationDate: _expirationDate,
                              );
                              final provider = Provider.of<CouponProvider>(
                                  context,
                                  listen: false);
                              final success = coupon == null
                                  ? await provider.createCoupon(couponData)
                                  : await provider.updateCoupon(couponData);
                              if (success) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      coupon == null
                                          ? 'Coupon created successfully'
                                          : 'Coupon updated successfully',
                                    ),
                                  ),
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${provider.error}'),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(coupon == null ? 'Create' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCoupon(BuildContext context, Coupon coupon) async {
    final outerContext = context;
    final shouldDelete = await showDialog<bool>(
      context: outerContext,
      builder: (context) => CustomConfirmDialog(
        title: 'Delete Coupon',
        content: 'Are you sure you want to delete coupon "${coupon.code}"?',
        confirmText: 'Delete',
        confirmColor: Colors.redAccent,
        onConfirmed: () async {
          final provider = Provider.of<CouponProvider>(context, listen: false);
          final success = await provider.deleteCoupon(coupon.id);
          if (success) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon deleted successfully'),
              ),
            );
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
              ),
            );
          }
        },
      ),
    );

    if (shouldDelete != true) {
      debugPrint("Delete canceled");
    }
  }

  Widget _buildCouponList(List<Coupon> coupons) {
    if (coupons.isEmpty) {
      return const Center(
        child: Text(
          'No coupons available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          Provider.of<CouponProvider>(context, listen: false).fetchCoupons(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                coupon.code,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                      'Discount: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(coupon.value)}'),
                  Text('Usage Limit: ${coupon.usageLimit}'),
                  Text(
                    'Min Order: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(coupon.minimumOrderAmount)}',
                  ),
                  Text(
                    'Expires: ${coupon.expirationDate != null ? DateFormat('dd/MM/yyyy').format(coupon.expirationDate!) : 'No expiration'}',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCouponForm(coupon: coupon),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteCoupon(context, coupon),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              'Manage Coupons',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _showCouponForm(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              overlayColor: WidgetStateProperty.all(Colors.grey[200]),
              indicatorColor: Colors.blue,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Valid'),
                Tab(text: 'Expired'),
              ],
            ),
          ),
          body: couponProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue))
              : couponProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            couponProvider.error!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => couponProvider.fetchCoupons(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCouponList(couponProvider.validCoupons),
                        _buildCouponList(couponProvider.expiredCoupons),
                      ],
                    ),
        );
      },
    );
  }
}
