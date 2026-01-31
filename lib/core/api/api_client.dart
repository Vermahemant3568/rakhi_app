import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  
  ApiResponse({required this.statusCode, required this.data});
}

class ApiClient {
  static String? _authToken;
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://10.125.101.16:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
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
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          data = {'error': errorData['message'] ?? 'Server error occurred'};
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

  static Future<ApiResponse> verifyOtp(String mobile, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));
      
      print('DEBUG: OTP verification response code: ${response.statusCode}');
      print('DEBUG: OTP verification response body: ${response.body}');
      
      Map<String, dynamic> data;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
          // Store token from response - check nested data object
          if (data['data'] != null && data['data']['token'] != null) {
            _authToken = data['data']['token'];
            print('DEBUG: Token stored: $_authToken');
          } else {
            print('DEBUG: No token in response');
          }
        } catch (e) {
          print('DEBUG: JSON decode error: $e');
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
      print('DEBUG: Current token: $_authToken');
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Add auth token if available
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
        print('DEBUG: Added Authorization header');
      } else {
        print('DEBUG: No token available');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/app/status'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      print('DEBUG: App status response code: ${response.statusCode}');
      print('DEBUG: App status response body: ${response.body}');
      
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
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/start-trial'),
        headers: headers,
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
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: headers,
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
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/goals'),
        headers: headers,
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
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      print('DEBUG: Submitting onboarding data: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl/onboarding/submit'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      print('DEBUG: Onboarding response code: ${response.statusCode}');
      print('DEBUG: Onboarding response body: ${response.body}');
      
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
      print('DEBUG: Onboarding submission error: $e');
      return ApiResponse(
        statusCode: 500, 
        data: {'error': 'Network error. Please check your connection.'}
      );
    }
  }

  // Voice API method
  static Future<ApiResponse> startVoiceCall() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/voice/start'),
        headers: headers,
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
          data = {'error': errorData['message'] ?? 'Failed to start voice call'};
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

  // Chat API method
  static Future<ApiResponse> sendChatMessage(String message) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: headers,
        body: jsonEncode({'message': message}),
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
          data = {'error': errorData['message'] ?? 'Failed to send message'};
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

  // Payment API methods
  static Future<ApiResponse> createTrialOrder() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/payment/trial/order'),
        headers: headers,
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
          data = {'error': errorData['message'] ?? 'Failed to create trial order'};
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

  static Future<ApiResponse> verifyTrialPayment(Map<String, dynamic> paymentData) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/payment/trial/verify'),
        headers: headers,
        body: jsonEncode(paymentData),
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
          data = {'error': errorData['message'] ?? 'Payment verification failed'};
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

  static Future<ApiResponse> createSubscription() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/payment/subscription/create'),
        headers: headers,
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
          data = {'error': errorData['message'] ?? 'Failed to create subscription'};
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

  static Future<ApiResponse> verifySubscription(Map<String, dynamic> subscriptionData) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/payment/subscription/verify'),
        headers: headers,
        body: jsonEncode(subscriptionData),
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
          data = {'error': errorData['message'] ?? 'Subscription verification failed'};
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