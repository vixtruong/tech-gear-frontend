import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class CloudinaryService {
  final String cloudName = 'diito9afa';
  final String uploadPreset = 'techgear';

  Future<String?> uploadImage(XFile file) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final bytes = await file.readAsBytes();

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ),
      );

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);
      return decoded['secure_url'];
    } else {
      print('Upload failed with status ${response.statusCode}');
      return null;
    }
  }
}
