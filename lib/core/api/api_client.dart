import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  
  ApiResponse({required this.statusCode, required this.data});
}

class ApiClient {
  // Android Emulator URL
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> sendOtp(String mobile) async {
    return await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile}),
    );
  }

  static Future<ApiResponse> verifyOtp(String mobile, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'otp': otp}),
    );
    
    final data = response.statusCode == 200 
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    
    return ApiResponse(statusCode: response.statusCode, data: data);
  }
}
