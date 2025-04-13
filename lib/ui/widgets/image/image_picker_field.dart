import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerField extends StatefulWidget {
  final String label;
  final Function(File?) onImagePicked;
  final FormFieldValidator<File?>? validator;

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(FormFieldState<File?> field) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      widget.onImagePicked(_selectedImage);
      field.didChange(_selectedImage);
      field.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<File?>(
      validator: widget.validator,
      builder: (FormFieldState<File?> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _pickImage(field),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.black,
                  ),
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
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
          ],
        );
      },
    );
  }
}
