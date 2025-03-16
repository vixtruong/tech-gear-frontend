import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<Map<String, String>> items;
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
    return Expanded(
      child: DropdownButtonFormField<String>(
        key: _dropdownKey,
        value: widget.value,
        hint: Text(widget.hint ?? "", style: TextStyle(color: Colors.black54)),
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 0),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        iconEnabledColor: Colors.black,
        dropdownColor: Colors.white,
        items: widget.items
            .map((e) => DropdownMenuItem(
                  value: e['id'],
                  child: Text(e['name'].toString(),
                      style: const TextStyle(color: Colors.black)),
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
