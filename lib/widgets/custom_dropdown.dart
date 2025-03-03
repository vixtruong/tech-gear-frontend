import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        iconEnabledColor: Colors.black,
        dropdownColor: Colors.white,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
