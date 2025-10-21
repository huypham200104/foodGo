import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static late final String _cloudName;
  static late final String _apiKey;
  static late final String _apiSecret;
  static late final String _uploadPreset;

  /// Call this in main() after loading dotenv
  static void init() {
    _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (_cloudName.isEmpty || _apiKey.isEmpty) {
      throw Exception('Cloudinary is not properly configured in .env');
    }
  }

  /// Upload image to Cloudinary
  static Future<Map<String, dynamic>?> uploadImage(File imageFile, {String folder = 'Uploads'}) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);

    if (response.statusCode == 200) {
      print('Upload successful: ${data['secure_url']}');
      return data;
    } else {
      print('Upload failed: ${data['error']}');
      return null;
    }
  }

  /// Delete image by public_id
  static Future<bool> deleteImage(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final sigString = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    final signature = sha1.convert(utf8.encode(sigString)).toString();

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/destroy");

    final response = await http.post(url, body: {
      'public_id': publicId,
      'api_key': _apiKey,
      'timestamp': '$timestamp',
      'signature': signature,
    });

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['result'] == 'ok') {
      print('Image deleted successfully');
      return true;
    } else {
      print('Image deletion failed: ${response.body}');
      return false;
    }
  }

  /// Rename image
  static Future<bool> renameImage(String oldPublicId, String newPublicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final sigString = 'from_public_id=$oldPublicId&to_public_id=$newPublicId&timestamp=$timestamp$_apiSecret';
    final signature = sha1.convert(utf8.encode(sigString)).toString();

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/rename");

    final response = await http.post(url, body: {
      'from_public_id': oldPublicId,
      'to_public_id': newPublicId,
      'api_key': _apiKey,
      'timestamp': '$timestamp',
      'signature': signature,
    });

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['public_id'] == newPublicId) {
      print('Image renamed successfully');
      return true;
    } else {
      print('Image renaming failed: ${response.body}');
      return false;
    }
  }
}