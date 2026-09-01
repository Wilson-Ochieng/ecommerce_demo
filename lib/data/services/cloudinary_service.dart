import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName =
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  final String uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> uploadImage(File image) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary configuration is missing. Check your .env file.',
      );
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
      ),
    );

    final response = await request.send();

    final responseBody =
        await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed: $responseBody',
      );
    }

    final data = jsonDecode(responseBody);

    final imageUrl = data['secure_url'];

    if (imageUrl == null) {
      throw Exception(
        'Cloudinary did not return an image URL.',
      );
    }

    return imageUrl;
  }
}