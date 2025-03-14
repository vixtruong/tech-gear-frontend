import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final bool isSearch;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.inputType,
    required this.isSearch,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: widget.isSearch
              ? const EdgeInsets.symmetric(horizontal: 8.0)
              : const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextFormField(
            controller: widget.controller,
            onChanged: (value) => {
              setState(() {
                errorText = widget.validator?.call(value);
              })
            },
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                errorText = error;
              });
              return null;
            },
            keyboardType: widget.inputType,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.isSearch
                  ? const Icon(Icons.search, color: Colors.black54)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
