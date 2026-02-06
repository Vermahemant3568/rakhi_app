import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  
  ApiResponse({required this.statusCode, required this.data});
}

class ApiClient {
  static String? _authToken;
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://10.159.117.16:8000/api';
    } else {
      // Use actual system IP instead of emulator-only 10.0.2.2
      return 'http://10.159.117.16:8000/api';
    }
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (requireAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  static Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _loadToken() async {
    if (_authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
    }
    // Debug: Print token status
    print('DEBUG: Token loaded: ${_authToken != null ? "YES" : "NO"}');
    if (_authToken != null) {
      print('DEBUG: Token: ${_authToken!.substring(0, 10)}...');
    }
  }

  static Future<ApiResponse> sendOtp(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'mobile': mobile}),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Server error occurred'};
        } catch (e) {
          // If HTML or non-JSON response
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> verifyOtp(String mobile, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: await _getHeaders(),
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
          // Save auth token if provided in nested data structure
          if (data.containsKey('data') && data['data'].containsKey('token')) {
            await _saveToken(data['data']['token']);
          }
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Verification failed'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> getAppStatus() async {
    try {
      await _loadToken(); // Ensure token is loaded
      final response = await http.get(
        Uri.parse('$baseUrl/app/status'),
        headers: await _getHeaders(requireAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to get app status'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> startTrial() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/start-trial'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to start trial'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to get languages'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> getGoals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to get goals'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> submitOnboarding(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/onboarding/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to submit onboarding'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> createTrialOrder(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-trial-order'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to create trial order'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> createSubscription(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to create subscription'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> verifyTrialPayment(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/verify-trial'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to verify trial payment'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> verifySubscription(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/verify-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to verify subscription'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> uploadImage(String imagePath) async {
    try {
      await _loadToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/chat/upload-image'));
      request.headers.addAll(await _getHeaders(requireAuth: true));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to upload image'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> sendChatMessage(String message, {int? imageId}) async {
    try {
      await _loadToken();
      final body = {'message': message};
      if (imageId != null) body['image_id'] = imageId.toString();
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to send message'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> startVoiceCall(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice/start-call'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> responseData;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          responseData = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          responseData = {'error': errorData['message'] ?? 'Failed to start voice call'};
        } catch (e) {
          responseData = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: responseData);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static Future<ApiResponse> getReports() async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: await _getHeaders(requireAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = {'error': 'Invalid response format'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Failed to get reports'};
        } catch (e) {
          data = {'error': _getErrorMessage(response.statusCode)};
        }
      }
      
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  static String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'Service not found. Please contact support.';
      case 500:
        return 'Server error. Please try again later.';
      case 422:
        return 'Invalid mobile number format.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
