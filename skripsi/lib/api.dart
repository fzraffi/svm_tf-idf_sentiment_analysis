import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class Api {
  // ANDROID EMULATOR: 10.0.2.2
  // Kalau pakai HP fisik: ganti jadi IP laptop, contoh: http://192.168.1.5:8000
  static const String baseUrl = "http://10.0.2.2:8000";

  // ========= UPLOAD XLSX =========
  static Future<Map<String, dynamic>> uploadXlsx(PlatformFile file) async {
    if (file.bytes == null) {
      throw Exception(
        "File bytes kosong. Pastikan FilePicker pakai withData:true",
      );
    }

    final uri = Uri.parse("$baseUrl/upload");
    final req = http.MultipartRequest("POST", uri);

    req.files.add(
      http.MultipartFile.fromBytes("file", file.bytes!, filename: file.name),
    );

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception("Upload gagal (${streamed.statusCode}): $body");
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }

  // ========= PREPROCESS =========
  static Future<Map<String, dynamic>> preprocess({
    String textColumn = "full_text",
  }) async {
    final uri = Uri.parse("$baseUrl/preprocess?text_column=$textColumn");

    // debug biar kelihatan request kepanggil
    // ignore: avoid_print
    print("CALLING PREPROCESS: $uri");

    final res = await http.post(uri);

    if (res.statusCode != 200) {
      throw Exception("Preprocess gagal (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  //LABELING
  static Future<Map<String, dynamic>> label() async {
    final uri = Uri.parse("$baseUrl/label");

    // ignore: avoid_print
    print("CALLING LABEL: $uri");

    final res = await http.post(uri);

    if (res.statusCode != 200) {
      throw Exception("Label gagal (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }


  //Train
  static Future<Map<String, dynamic>> train() async {
  final uri = Uri.parse("$baseUrl/train?test_size=0.2&random_state=0&max_features=5000");

  // ignore: avoid_print
  print("CALLING TRAIN: $uri");

  final res = await http.post(uri);

  if (res.statusCode != 200) {
    throw Exception("Train gagal (${res.statusCode}): ${res.body}");
  }

  return jsonDecode(res.body) as Map<String, dynamic>;
}

}
