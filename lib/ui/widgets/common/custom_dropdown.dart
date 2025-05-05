import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<Map<String, String?>> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? value;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.onChanged,
    this.validator,
    this.value,
    this.hint,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final GlobalKey<FormFieldState<String>> _dropdownKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 50, // Limit max height to remove extra space
      ),
      child: DropdownButtonFormField<String>(
        key: _dropdownKey,
        value: widget.value != null &&
                widget.items.any((item) => item['id'] == widget.value)
            ? widget.value
            : widget.items.first['id'], // Default value if invalid
        hint: Text(widget.hint ?? "",
            style: const TextStyle(color: Colors.black54)),
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 4), // Reduced vertical padding
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!, // Light grey border
              width: 1.0, // Thin border
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!, // Light grey border
              width: 1.0, // Thin border
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!, // Light grey border
              width: 1.0, // Thin border
            ),
          ),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        iconEnabledColor: Colors.black,
        dropdownColor: Colors.white,
        isDense: true, // Compact layout
        items: widget.items
            .map((e) => DropdownMenuItem(
                  value: e['id'],
                  child: Text(
                    e['name'].toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          setState(() {
            _dropdownKey.currentState?.validate();
          });
        },
      ),
    );
  }
}
