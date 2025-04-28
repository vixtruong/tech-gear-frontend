import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';

class OtpDialog extends StatefulWidget {
  final Future<void> Function(String) onSubmit;

  const OtpDialog({super.key, required this.onSubmit});

  @override
  _OtpDialogState createState() => _OtpDialogState();

  // Static method to show the dialog
  static void show(
      BuildContext context, Future<void> Function(String) onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OtpDialog(onSubmit: onSubmit);
      },
    );
  }
}

class _OtpDialogState extends State<OtpDialog> {
  // Controllers for each OTP field
  late final TextEditingController _otpController1;
  late final TextEditingController _otpController2;
  late final TextEditingController _otpController3;
  late final TextEditingController _otpController4;
  late final TextEditingController _otpController5;
  late final TextEditingController _otpController6;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _otpController1 = TextEditingController();
    _otpController2 = TextEditingController();
    _otpController3 = TextEditingController();
    _otpController4 = TextEditingController();
    _otpController5 = TextEditingController();
    _otpController6 = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _otpController1.dispose();
    _otpController2.dispose();
    _otpController3.dispose();
    _otpController4.dispose();
    _otpController5.dispose();
    _otpController6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners for dialog
      ),
      title: const Center(
        child: Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the fields
            children: [
              _otpTextField(_otpController1, context, index: 1),
              const SizedBox(width: 3), // 5px spacing
              _otpTextField(_otpController2, context, index: 2),
              const SizedBox(width: 3),
              _otpTextField(_otpController3, context, index: 3),
              const SizedBox(width: 3),
              _otpTextField(_otpController4, context, index: 4),
              const SizedBox(width: 3),
              _otpTextField(_otpController5, context, index: 5),
              const SizedBox(width: 3),
              _otpTextField(_otpController6, context, index: 6),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 110,
            child: CustomButton(
              text: "Submit",
              onPressed: () async {
                // Get OTP from controllers
                String otp = _otpController1.text +
                    _otpController2.text +
                    _otpController3.text +
                    _otpController4.text +
                    _otpController5.text +
                    _otpController6.text;

                if (otp.isEmpty || otp.length != 6) {
                  // Error if OTP is empty or not 6 digits
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 6-digit OTP'),
                    ),
                  );
                  return;
                }

                await widget.onSubmit(otp);
              },
              color: Colors.blue,
              borderRadius: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpTextField(TextEditingController controller, BuildContext context,
      {required int index}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.0, // Ensure text is vertically centered
        ),
        decoration: InputDecoration(
          counterText: '', // Hide character counter
          contentPadding: EdgeInsets.zero, // Remove default padding
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFAFEEEE), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 6) {
              FocusScope.of(context)
                  .nextFocus(); // Move to next field if not last
            }
          } else {
            if (index > 1) {
              FocusScope.of(context)
                  .previousFocus(); // Move to previous field if not first
            }
          }
        },
      ),
    );
  }
}
