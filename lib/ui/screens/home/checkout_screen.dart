import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/cart_providers/cart_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/ui/widgets/cart/cart_item_card.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late ProductItemProvider _productItemProvider;
  late AuthProvider _authProvider;

  bool? isLogin;

  int currentStep = 0;
  int? selectedPaymentMethod;
  bool isUsePoint = false;
  String note = "Text note...";
  String fullName = "";
  String email = "";
  String phoneNumber = "";
  String address = "";

  final steps = [
    {'icon': Icons.local_shipping, 'label': 'Shipping'},
    {'icon': Icons.payment, 'label': 'Payment'},
    {'icon': Icons.fact_check, 'label': 'Review'},
  ];

  final _key = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  List<int> prices = [];
  final vndFormat = NumberFormat.decimalPattern('vi_VN');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    final productItemIds =
        widget.cartItems.map((item) => int.parse(item.productItemId)).toList();
    final fetchIsLogin = await _authProvider.isCustomerLogin();
    final fetchPrices = await _productItemProvider.getPrice(productItemIds);

    setState(() {
      prices = fetchPrices;
      isLogin = fetchIsLogin;
    });
  }

  void _handleConfirm() {
    if (currentStep < steps.length - 1) {
      if (currentStep == 0) {
        if (!_key.currentState!.validate()) return;

        String checkFullName = _fullNameController.text.trim();
        String checkEmail = _emailController.text.trim();
        String checkPhoneNumber = _phoneNumberController.text.trim();
        String checkAddress = _addressController.text.trim();

        // Regex kiểm tra định dạng email
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        if (checkFullName.isEmpty ||
            checkEmail.isEmpty ||
            checkPhoneNumber.isEmpty ||
            checkAddress.isEmpty ||
            !emailRegex.hasMatch(checkEmail)) {
          return;
        }

        setState(() {
          fullName = checkFullName;
          email = checkEmail;
          phoneNumber = checkPhoneNumber;
          address = checkAddress;
        });
      }

      if (currentStep == 1) {
        if (selectedPaymentMethod == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select a payment method"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      }

      setState(() {
        currentStep++;
      });
    } else {
      // TODO: Handle final confirmation
    }
  }

  int getProductTotalPrice() {
    if (widget.cartItems.isEmpty) {
      return 0;
    }

    int total = 0;
    for (var i = 0; i < widget.cartItems.length; i++) {
      final item = widget.cartItems[i];
      final price = i < prices.length
          ? prices[i]
          : 0; // Fallback to 0 if price is missing

      if (price == 0) {
        continue;
      }
      if (item.quantity == 0) {
        continue;
      }

      total += price * item.quantity;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.cartItems.length;
    // final isWeb = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: kIsWeb ? 1 : 0,
        leading: kIsWeb
            ? null
            : GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_outlined),
              ),
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return IconButton(
                  icon: badges.Badge(
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(5),
                    ),
                    badgeContent: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  onPressed: () {},
                );
              },
            ),
          ),
        ],
      ),
      body: (itemCount == 0)
          ? Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/cart');
                });
                return const Center(child: CircularProgressIndicator());
              },
            )
          : Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildStepper(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepContent(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Trong hàm build của _CheckoutScreenState
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentStep > 0)
                          Expanded(
                            child: CustomButton(
                              text: "Back",
                              onPressed: () {
                                setState(() {
                                  currentStep--;
                                });
                              },
                              color: Colors.grey,
                              borderRadius: 20,
                            ),
                          ),
                        if (currentStep > 0) const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: currentStep == steps.length - 1
                                ? "Confirm"
                                : "Next",
                            onPressed: () => _handleConfirm(),
                            color: Colors.black,
                            borderRadius: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Phân bố đều các bước
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            // Hiển thị bước (Shipping, Payment, Review)
            final stepIndex = index ~/ 2;
            final isActive = stepIndex == currentStep;
            final isCompleted = stepIndex < currentStep;
            return SizedBox(
              width: 80, // Kích thước cố định cho mỗi bước
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isActive || isCompleted
                        ? Colors.black
                        : Colors.grey[300],
                    child: Icon(
                      steps[stepIndex]['icon'] as IconData,
                      color:
                          isActive || isCompleted ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[stepIndex]['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isActive || isCompleted ? Colors.black : Colors.grey,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Hiển thị Divider giữa các bước
            final dividerIndex = index ~/ 2;
            return SizedBox(
              width: 60, // Kích thước cố định cho Divider
              child: Divider(
                color: dividerIndex < currentStep ? Colors.black : Colors.grey,
                thickness: 2,
                height: 20,
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter Shipping Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full name textfield
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Full Name*",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    controller: _fullNameController,
                    hint: "Full Name",
                    inputType: TextInputType.text,
                    isSearch: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter full name";
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // Email textfield
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Email*",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                      controller: _emailController,
                      hint: "Email",
                      inputType: TextInputType.text,
                      isSearch: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }

                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email";
                        }

                        return null;
                      }),
                  SizedBox(
                    height: 15,
                  ),

                  // Phone number textfield
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Phone Number*",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    controller: _phoneNumberController,
                    hint: "Phone Number",
                    inputType: TextInputType.number,
                    isSearch: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),

                  // Address textfield
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Address*",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    controller: _addressController,
                    hint: "123, Tran Hung Dao, phuong 5,...",
                    inputType: TextInputType.text,
                    isSearch: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter delivery address";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            )
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Select a Payment Method",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/images/cod-payment.png",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: const Text(
                  "COD",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Radio<int>(
                  activeColor: Colors.blue,
                  value: 1, // COD
                  groupValue: selectedPaymentMethod,
                  onChanged: (int? value) {
                    setState(() {
                      selectedPaymentMethod = value; // Update state
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 1; // Select COD
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/images/momo-logo.png",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: const Text(
                  "Momo",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Radio<int>(
                  activeColor: Colors.blue,
                  value: 2, // Momo
                  groupValue: selectedPaymentMethod,
                  onChanged: (int? value) {
                    setState(() {
                      selectedPaymentMethod = value; // Update state
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 2; // Select Momo
                  });
                },
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Address Infomation
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          address,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Product Infomation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Column(
                      children: [
                        ...List.generate(widget.cartItems.length, (index) {
                          return CartItemCard(
                            productItemId: int.parse(
                                widget.cartItems[index].productItemId),
                            quantity: widget.cartItems[index].quantity,
                            isCheckout: true,
                          );
                        }),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.1,
                    color: Colors.grey[300],
                  ),
                  if (isLogin == true)
                    Column(
                      children: [
                        _buildListTile(
                          "Voucher",
                          "Select or text code",
                          () {},
                        ),
                        _buildListTile(
                          "Note for shop",
                          note,
                          _showNoteBottomSheet,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.currency_exchange,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    "Points (1000)",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Transform.scale(
                                scale: 0.75,
                                child: Switch(
                                  value: isUsePoint,
                                  activeTrackColor: Colors.black,
                                  inactiveTrackColor: Colors.grey[350],
                                  thumbColor:
                                      WidgetStateProperty.all(Colors.white),
                                  onChanged: (value) {
                                    setState(() {
                                      isUsePoint = value;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.1,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total (${widget.cartItems.length} products)",
                          style: TextStyle(fontSize: 14),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${vndFormat.format(getProductTotalPrice())}đ", // giá khuyến mãi
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${vndFormat.format(getProductTotalPrice())}đ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // PaymentDetail
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Payment details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal"),
                      Text("${vndFormat.format(getProductTotalPrice())}đ"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shipping fee"),
                      Text("30.000đ"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Grand Total"),
                      Text(
                        "${vndFormat.format(getProductTotalPrice() + 30000)}đ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Payment method"),
                      Text((selectedPaymentMethod == 1) ? "COD" : "Momo"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const Text(
          "Unknown Step",
          style: TextStyle(fontSize: 14),
        );
    }
  }

  void _showNoteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Note for Shop",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: "Enter your note here...",
                  hintStyle:
                      const TextStyle(fontSize: 14), // Font size for hint text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style:
                    const TextStyle(fontSize: 14), // Font size for typed text
                cursorColor: Colors.black,
                maxLines: 2,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _noteController.clear();
                      Navigator.pop(context);
                      setState(() {
                        setState(() {
                          note = "Text note...";
                        });
                      });
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        note = _noteController.text.trim();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.black45,
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
