import 'dart:typed_data'; // Dùng để load bytes
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatefulWidget {
  final String label;
  final Function(XFile?) onImagePicked;
  final FormFieldValidator<XFile?>? validator;

  const ImagePickerField({
    super.key,
    required this.label,
    required this.onImagePicked,
    this.validator,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes; // Cho Web dùng

  Future<void> _pickImage(FormFieldState<XFile?> field) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });

      widget.onImagePicked(_selectedImage);
      field.didChange(_selectedImage);
      field.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<XFile?>(
      validator: widget.validator,
      builder: (FormFieldState<XFile?> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _pickImage(field),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  field.errorText ?? "",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 15),
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.memory(_imageBytes!,
                      fit: BoxFit.cover), // Dùng memory cho Web
                ),
              ),
          ],
        );
      },
    );
  }
}
