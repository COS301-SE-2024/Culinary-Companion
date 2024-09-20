// lib/web_utils.dart

//import 'package:flutter/foundation.dart' show kIsWeb;

class WebUtils {
  void uploadImage(Function(String) onImageUploaded) {
    throw UnimplementedError(
        'uploadImage is not implemented on this platform.');
  }
}

WebUtils getWebUtils() => WebUtils();
