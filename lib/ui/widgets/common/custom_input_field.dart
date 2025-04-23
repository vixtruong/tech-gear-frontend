import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _isObscure;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            onChanged: (value) => {
              if (value.isEmpty)
                {
                  setState(() {
                    errorText = widget.validator?.call(value);
                  })
                }
              else
                {
                  setState(() {
                    errorText = null;
                  })
                }
            },
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                errorText = error;
              });
              return null;
            },
            keyboardType: widget.keyboardType,
            obscureText: _isObscure,
            enableInteractiveSelection: !widget.obscureText,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(widget.icon, color: Colors.black),
              ),
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black45,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
          ),
      ],
    );
  }
}
