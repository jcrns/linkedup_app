// services/UserService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/';
  final _secureStorage = const FlutterSecureStorage();


  // Auth API Methods
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      var url = Uri.parse('${_baseUrl}auth/login/');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.toLowerCase(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var token = jsonResponse['token'];
        var profile = jsonResponse['profile'];

        // Save token and profile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('profile', json.encode(profile));
        await prefs.setString('user_id', profile['id'].toString());

        // Save credentials securely
        await _saveCredentials(username, password);

        return {
          'success': true,
          'token': token,
          'profile': profile,
        };
      } else {
        return {
          'success': false,
          'error': 'Login Failed: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>?> registerUser(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Password confirmation check
    if (confirmPassword != password) {
      return {
        'success': false,
        'error': 'Password does not match',
      };
    }

    try {
      var url = Uri.parse('${_baseUrl}signup/');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.toLowerCase(),
          'username': username.toLowerCase(),
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        String responseBool = jsonResponse['response'];

        if (responseBool == 'success') {
          // Save credentials after successful registration
          await _saveCredentials(username, password);
          return {
            'success': true,
            'message': 'Creation success. Time to set up your profile...',
          };
        } else {
          return {
            'success': false,
            'error': 'Problem creating profile. Please try again.',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to create account: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred while creating account: $e',
      };
    }
  }

  // Credential Management
  Future<void> _saveCredentials(String username, String password) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String?>> loadCredentials() async {
    String? savedUsername = await _secureStorage.read(key: 'username');
    String? savedPassword = await _secureStorage.read(key: 'password');
    return {
      'username': savedUsername,
      'password': savedPassword,
    };
  }

  // Existing methods remain the same...
  resetAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    return userId as int?;
  }

  // 1. Get current user's business
  static Future<Map<String, dynamic>?> getMyBusiness() async {
    final token = await _getAuthToken();
    if (token == null) {
      print('No auth token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}businesses/my_business/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      print('My Business API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody;
      } else if (response.statusCode == 404) {
        print('No business found for user');
        return null;
      } else {
        print('Failed to load my business: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user business: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchProducts() async {
    print("fetchProducts called");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    var url = Uri.parse('http://127.0.0.1:5000/api/products');

    try {
      var response = await http.get(
        url,
        headers: { 
          'Content-Type': 'application/json',
          'X-Client-Version': '1.0.0',
          'X-Client-Platform': 'flutter-ios',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List && responseBody.isNotEmpty) {
          print("Product Response is a list with length: ${responseBody.length}");
          return responseBody[0];
        } else if (responseBody is Map<String, dynamic>) {
          print("Product Response is a single object");
          return responseBody;
        }
        print("Unexpected response format: ${response.body}");
        return json.decode(response.body);
      } else {
        print("Failed to load events: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
    return {};
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final response = await http.get(
      Uri.parse('${_baseUrl}profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody is List && responseBody.isNotEmpty) {
        print("Response is a list with length: ${responseBody.length}");
        return responseBody[0];
      } else if (responseBody is Map<String, dynamic>) {
        print("Response is a single object");
        return responseBody;
      }
      print("Unexpected response format: ${response.body}");
      return json.decode(response.body);
    } else {
      final profile = prefs.getString('profile');
      if (profile != null) {
        return json.decode(profile);
      }
      throw Exception('Failed to load profile1');
    }
  }
  
  static Future<Map<String, int>> getCoinBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final response = await http.get(
      Uri.parse('${_baseUrl}coin-balances/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    
    if (response.statusCode == 200) {
      return Map<String, int>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load coin balances');
    }
  }
  
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Sending profile update: ${json.encode(data)}');
    
    if (data['image'] is! File) {
      data.remove('image');
    }

    if (data['date_of_birth'] != null) {
      final dob = DateTime.tryParse(data['date_of_birth']);
      if (dob != null) {
        data['date_of_birth'] = "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
      } else {
        data.remove('date_of_birth');
      }
    }
    
    final response = await http.put(
      Uri.parse('${_baseUrl}profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Version': '1.0.0',
        'X-Client-Platform': 'flutter-ios',
        'Authorization': 'Token $token',
      },
      body: json.encode(data),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Update failed');
    }
  }
}