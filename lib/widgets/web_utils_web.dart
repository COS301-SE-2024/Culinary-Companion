// lib/web_utils_web.dart

import 'dart:html' as html;
import 'web_utils.dart';

class WebUtilsWeb implements WebUtils {
  @override
  void uploadImage(Function(String) onImageUploaded) {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        final base64Image = reader.result.toString().split(',').last;
        onImageUploaded(base64Image);
      });
    });
  }
}

WebUtils getWebUtils() => WebUtilsWeb();
