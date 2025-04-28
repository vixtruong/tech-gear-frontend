import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/dtos/order_item_dto.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/models/order/coupon.dart';
import 'package:techgear/models/user/user_address.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';
import 'package:techgear/providers/order_providers/coupon_provider.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/user_provider/user_address_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';
import 'package:techgear/ui/widgets/cart/cart_item_card.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/dialogs/otp_dialog.dart';
import 'package:techgear/ui/widgets/user/user_address_card.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late NavigationProvider _navigationProvider;
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;
  late ProductItemProvider _productItemProvider;
  late UserProvider _userProvider;
  late OrderProvider _orderProvider;
  late CartProvider _cartProvider;
  late UserAddressProvider _addressProvider;
  late CouponProvider _couponProvider;

  String? checkUserId;
  bool? isLogin;
  int? userPoint;
  Coupon? couponVoucher;

  int currentStep = 0;
  int? selectedPaymentMethod;
  bool isUsePoint = false;
  String? note;
  String fullName = "";
  String email = "";
  String phoneNumber = "";
  String address = "";
  int totalAmount = 0;
  int discountAmount = 0;

  final shippingFee = 30000;

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
  List<UserAddress> userAddresses = [];
  int? selectedAddressId; // ID địa chỉ được chọn

  final vndFormat = NumberFormat.decimalPattern('vi_VN');

  List<Coupon> coupons = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _addressProvider = Provider.of<UserAddressProvider>(context, listen: false);
    _couponProvider = Provider.of<CouponProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    // Load session thông tin đăng nhập
    await _sessionProvider.loadSession();
    checkUserId = _sessionProvider.userId;

    // Lấy danh sách ID các sản phẩm trong giỏ hàng
    final productItemIds =
        widget.cartItems.map((item) => int.parse(item.productItemId)).toList();

    final fetchIsLogin = await _authProvider.isCustomerLogin();
    final fetchPrices = await _productItemProvider.getPrice(productItemIds);

    await _couponProvider.fetchCoupons();
    final fetchCoupons = _couponProvider.coupons;

    if (checkUserId != null) {
      final userIdInt = int.parse(checkUserId!);
      _userProvider.setUserId(userIdInt);

      await _userProvider.fetchLoyaltyPoints();
      await _addressProvider.fetchUserAddresses();

      if (_addressProvider.addresses.isNotEmpty) {
        final defaultAddress = _addressProvider.addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _addressProvider.addresses.first,
        );
        selectedAddressId = defaultAddress.id;
      }
    }

    // Cập nhật lại UI state
    if (mounted) {
      setState(() {
        prices = fetchPrices;
        isLogin = fetchIsLogin;
        if (checkUserId != null) {
          userPoint = _userProvider.loyaltyPoints;
          userAddresses = _addressProvider.addresses;
        }

        coupons = fetchCoupons;
        totalAmount = getProductTotalPrice() + shippingFee;
        discountAmount = totalAmount;

        _isLoading = false;
      });
    }
  }

  Future<void> _sendOtp(String email) async {
    OtpDialog.show(context, _submitWithoutLogin);

    await _authProvider.sendOtp(email);
  }

  Future<void> _handleConfirm() async {
    if (currentStep < steps.length - 1) {
      if (currentStep == 0) {
        if (isLogin == false) {
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
              !emailRegex.hasMatch(checkEmail) ||
              !RegExp(r'^\d{10}$').hasMatch(checkPhoneNumber)) {
            return;
          }

          setState(() {
            fullName = checkFullName;
            email = checkEmail;
            phoneNumber = checkPhoneNumber;
            address = checkAddress;
          });
        } else {
          final selectedAddress =
              userAddresses.where((a) => a.id == selectedAddressId).first;

          setState(() {
            fullName = selectedAddress.recipientName;
            phoneNumber = selectedAddress.recipientPhone;
            address = selectedAddress.address;
          });
        }
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
      if (isLogin == false) {
        _sendOtp(email);
      } else {
        // Order when log in
        showDialog(
          context: context,
          barrierDismissible: false,
          // ignore: deprecated_member_use
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        );

        try {
          final userId = _sessionProvider.userId;
          final userAddressId = selectedAddressId;
          final List<OrderItemDto> orderItems = List.generate(
            widget.cartItems.length,
            (index) => OrderItemDto(
              productItemId: int.parse(widget.cartItems[index].productItemId),
              quantity: widget.cartItems[index].quantity,
              price: prices[index],
            ),
          );

          final orderDto = OrderDto(
            userId: int.parse(userId!),
            userAddressId: userAddressId!,
            totalAmount: totalAmount,
            couponId: couponVoucher?.id,
            note: note,
            paymentMethod: selectedPaymentMethod == 1 ? 'COD' : 'Momo',
            createdAt: DateTime.now().toUtc(),
            orderItems: orderItems,
            isUsePoint: userPoint == 0 ? false : isUsePoint,
          );

          await _orderProvider.createOrder(orderDto);

          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _navigationProvider.setSelectedIndex(1);
            context.go('/activity');
          });
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create order. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _submitWithoutLogin(String otp) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );

      final registerRequest = RegisterRequestDto(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: phoneNumber,
        role: "Customer",
        address: address,
        otp: otp,
      );

      final data = await _authProvider.register(registerRequest);

      if (data == null) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_authProvider.errorMessage}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final userId = data['userId'];
      final userAddressId = data['userAddressId'];

      final List<OrderItemDto> orderItems = List.generate(
        widget.cartItems.length,
        (index) => OrderItemDto(
          productItemId: int.parse(widget.cartItems[index].productItemId),
          quantity: widget.cartItems[index].quantity,
          price: prices[index],
        ),
      );

      final orderDto = OrderDto(
        userId: userId,
        userAddressId: userAddressId,
        totalAmount: getProductTotalPrice(),
        couponId: couponVoucher?.id,
        note: note,
        paymentMethod: selectedPaymentMethod == 1 ? 'COD' : 'Momo',
        createdAt: DateTime.now().toUtc(),
        orderItems: orderItems,
        isUsePoint: userPoint == 0 ? false : isUsePoint,
      );

      await _orderProvider.createOrder(orderDto);

      var loginResponse = await _authProvider.login(email, phoneNumber);
      if (loginResponse == null) {
        return;
      }
      await _sessionProvider.saveSession(
          loginResponse['accessToken'], loginResponse['refreshToken']);
      await _sessionProvider.loadSession();

      await _cartProvider.updateCartToServer();

      // Điều hướng đến '/activity' và đồng bộ NavigationProvider
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigationProvider.setSelectedIndex(1);
        context.go('/activity');
      });

      if (!mounted) return;

      Navigator.of(context).pop(); // Đóng dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (!mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order fail!: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

      if (price == 0 || item.quantity == 0) {
        continue;
      }
      total += price * item.quantity;
    }

    return total;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.cartItems.length;
    final isWeb = MediaQuery.of(context).size.width >= 800;
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
          : (_isLoading)
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : Center(
                  child: Container(
                    color: Colors.white,
                    width: isWeb
                        ? MediaQuery.of(context).size.width * 0.5
                        : double.infinity,
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
        children: List.generate(
          steps.length * 2 - 1,
          (index) {
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
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[stepIndex]['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive || isCompleted
                            ? Colors.black
                            : Colors.grey,
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
                  color:
                      dividerIndex < currentStep ? Colors.black : Colors.grey,
                  thickness: 2,
                  height: 20,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return SingleChildScrollView(
          child: Column(
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
              if (isLogin == false)
                Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text("Full Name*",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _fullNameController,
                        hint: "Full Name",
                        inputType: TextInputType.text,
                        isSearch: false,
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter full name"
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text("Email*",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _emailController,
                        hint: "Email",
                        inputType: TextInputType.emailAddress,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          return !emailRegex.hasMatch(value)
                              ? "Please enter a valid email"
                              : null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text("Phone Number*",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _phoneNumberController,
                        hint: "Phone Number",
                        inputType: TextInputType.number,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter phone number";
                          }
                          return !RegExp(r'^\d{10}$').hasMatch(value)
                              ? "Phone number must be exactly 10 digits and contain only numbers"
                              : null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text("Address*",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _addressController,
                        hint: "123, Tran Hung Dao, phuong 5,...",
                        inputType: TextInputType.text,
                        isSearch: false,
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter delivery address"
                            : null,
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: userAddresses.length,
                  itemBuilder: (context, index) {
                    final address = userAddresses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: UserAddressCard(
                        name: address.recipientName,
                        phone: address.recipientPhone,
                        address: address.address,
                        value: address.id!,
                        groupValue: selectedAddressId ?? -1,
                        onChanged: (val) {
                          setState(() {
                            selectedAddressId = val;
                          });
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
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
                  Column(
                    children: [
                      _buildListTile(
                        "Voucher",
                        couponVoucher?.code ?? "Select a voucher",
                        () {
                          _showVoucherBottomSheet(coupons);
                        },
                      ),
                      _buildListTile(
                        "Note for shop",
                        note ?? "Text note...",
                        _showNoteBottomSheet,
                      ),
                      if (isLogin == true)
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
                                    "Points ($userPoint)",
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

                                      if (isUsePoint) {
                                        discountAmount -= userPoint! * 1000;
                                      } else {
                                        discountAmount += userPoint! * 1000;
                                      }
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
                              "${vndFormat.format(discountAmount)}đ", // giá khuyến mãi
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${vndFormat.format(totalAmount)}đ",
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
                      Text("Payment method"),
                      Text((selectedPaymentMethod == 1) ? "COD" : "Momo"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Product Amount"),
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
                  if (isUsePoint == true && userPoint != 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Points"),
                        Text(
                          '-${vndFormat.format(userPoint! * 1000)}đ',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  if (couponVoucher != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Voicher discount"),
                        Text(
                          '-${vndFormat.format(couponVoucher!.value)}đ',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Grand Total"),
                      Text(
                        "${vndFormat.format(discountAmount)}đ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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

  void _showVoucherBottomSheet(List<Coupon> vouchers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // for smooth rounded effect
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Available Vouchers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: vouchers.isEmpty
                        ? const Center(child: Text("No vouchers available."))
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: vouchers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final voucher = vouchers[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          voucher.code,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Discount: ${vndFormat.format(voucher.value)}₫ • Limit: ${voucher.usageLimit} uses",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Min order: ${vndFormat.format(voucher.minimumOrderAmount)}₫",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                        Text(
                                          voucher.expirationDate != null
                                              ? "Expires: ${DateFormat('dd/MM/yyyy').format(voucher.expirationDate!)}"
                                              : "No expiration",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.redAccent),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (couponVoucher != voucher) {
                                            couponVoucher = voucher;
                                            discountAmount -= voucher.value;
                                          } else {
                                            couponVoucher = null;
                                            discountAmount += voucher.value;
                                          }
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            (couponVoucher == voucher)
                                                ? Colors.grey
                                                : Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text((couponVoucher == voucher)
                                          ? "Applied"
                                          : "Apply"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNoteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
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
                  const Text(
                    "Add Note for the Shop",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Write something like: 'Leave at front door'",
                      hintStyle: const TextStyle(fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300, // More subtle gray color
                          width: 1.0, // Thinner border
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    maxLines: 3,
                    cursorColor: Colors.black,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      setState(() {
                        note = value.trim();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _noteController.clear();
                          Navigator.pop(context);
                          setState(() {
                            note = null;
                          });
                        },
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
