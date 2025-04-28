import 'package:flutter/material.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirmed;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirmed();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
