import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class Axios {
  late String baseUrl;
  late String bearerToken;
  late http.Client _client;

  Axios() {
    _client = http.Client();
  }

  Future<void> init() async {
    baseUrl = dotenv.env["API_URL"] ?? "";
    final prefs = await SharedPreferences.getInstance();
    bearerToken = prefs.getString("token") ?? "";
  }

  Future<http.Response> get(String endpoint) async {
    await init();
    final response = await _client.get(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": 'Bearer $bearerToken',
      },
    );
    return response;
  }

  Future<http.Response> post(String endpoint, {dynamic data}) async {
    await init();
    final response = await _client.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );
    return response;
  }

  Future<http.Response> put(String endpoint, {dynamic data}) async {
    await init();
    final response = await _client.put(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: data,
    );
    return response;
  }

  Future<http.Response> delete(String endpoint, {dynamic data}) async {
    await init();
    final response = await _client.delete(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: data,
    );
    return response;
  }

  // Future<http.StreamedResponse> uploadFile(
  //     String endpoint, XFile imageFile) async {
  //   await init();
  //
  //   var request = http.MultipartRequest('POST', Uri.parse(baseUrl + endpoint));
  //   request.headers['Authorization'] = 'Bearer $bearerToken';
  //
  //   request.files.add(
  //     await http.MultipartFile.fromPath(
  //       'image',
  //       imageFile.path,
  //       contentType: MediaType(
  //           'image', 'jpeg'), // Adjust the content type based on your file type
  //     ),
  //   );
  //
  //   var response = await request.send();
  //
  //   return response;
  // }

  void close() {
    _client.close();
  }
}
