import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class BusinessService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/';

      // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  static Future<Map<String, dynamic>?> getUserBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print('No auth token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}businesses/my_business/'), // Note the trailing slash
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token', // Use 'Token' instead of 'Bearer' for Django Token Authentication
        },
      );

      print('Business API Response Status: ${response.statusCode}');
      print('Business API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody;
      } else if (response.statusCode == 404) {
        // User doesn't have a business - this is normal
        print('No business found for user');
        return null;
      } else {
        print('Failed to load business: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user business: $e');
      return null;
    }
  }
    static Future<List<dynamic>?> getAllBusinesses({
    int? page,
    int? pageSize,
    String? ordering,
    String? businessType,
    String? location,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      final token = await _getAuthToken();

      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();
      if (ordering != null) queryParams['ordering'] = ordering;
      if (businessType != null) queryParams['business_type'] = businessType;
      if (location != null) queryParams['location'] = location;
      final uri = Uri.parse('${_baseUrl}businesses/').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        print('All Businesses API Response Body: ${response.body}');
        
        // FIX: Decode the body into a generic 'dynamic' type
        final dynamic decodedData = json.decode(response.body);
        
        // Check if the response is a paginated Map (standard Djang Rest Framework format)
        if (decodedData is Map<String, dynamic> && decodedData.containsKey('results')) {
          // If it's a Map, extract the list of results
          return decodedData['results'] as List<dynamic>;
        } 
        // Check if the response is a raw List (non-paginated)
        else if (decodedData is List) {
          // If it's already a list, return it directly
          return decodedData;
        } else {
          // Handle unexpected structure
          throw Exception('Failed to parse businesses: Unexpected API response structure.');
        }
        
      } else {
        throw Exception('Failed to load businesses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all businesses: $e');
      rethrow;
    }
  }

  // 3. Get recently added businesses
  static Future<List<dynamic>> getRecentBusinesses({
    int days = 30,
    int limit = 20,
  }) async {
    try {
      final token = await _getAuthToken();

      final uri = Uri.parse('${_baseUrl}businesses/recent/').replace(
        queryParameters: {
          'days': days.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',

        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody is List ? responseBody : [];
      } else {
        throw Exception('Failed to load recent businesses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recent businesses: $e');
      rethrow;
    }
  }

  // Search businesses
  static Future<dynamic> searchBusinesses({
    required String query,
    String? businessType,
    String? location,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final token = await _getAuthToken();
      final Map<String, String> queryParams = {'q': query};
      if (businessType != null) queryParams['type'] = businessType;
      if (location != null) queryParams['location'] = location;
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();


      final uri = Uri.parse('${_baseUrl}businesses/search/').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        // FIX: Return the decoded data as dynamic, letting the caller handle the type
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search businesses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching businesses: $e');
      rethrow;
    }
  }

  // 5. Get popular businesses
  static Future<List<dynamic>> getPopularBusinesses({
    int limit = 10,
    String orderBy = 'views', // 'views', 'rating', 'valuation', 'name'
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}businesses/popular/').replace(
        queryParameters: {
          'limit': limit.toString(),
          'order_by': orderBy,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody is List ? responseBody : [];
      } else {
        throw Exception('Failed to load popular businesses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular businesses: $e');
      rethrow;
    }
  }

  // 6. Get businesses by category
  static Future<List<dynamic>> getBusinessesByCategory(String category) async {
    try {
      final uri = Uri.parse('${_baseUrl}businesses/by_category/').replace(
        queryParameters: {'category': category},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody is List ? responseBody : [];
      } else {
        throw Exception('Failed to load businesses by category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching businesses by category: $e');
      rethrow;
    }
  }

  // 7. Get single business by ID
  static Future<Map<String, dynamic>?> getBusinessById(int businessId) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}businesses/$businessId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load business: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching business by ID: $e');
      rethrow;
    }
  }

  // 8. Create new business
  static Future<Map<String, dynamic>?> createBusiness(Map<String, dynamic> businessData) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}businesses/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(businessData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to create business: ${errorBody.toString()}');
      }
    } catch (e) {
      print('Error creating business: $e');
      rethrow;
    }
  }

  // 9. Update business
  static Future<Map<String, dynamic>?> updateBusiness(int businessId, Map<String, dynamic> businessData) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.patch(
        Uri.parse('${_baseUrl}businesses/$businessId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(businessData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to update business: ${errorBody.toString()}');
      }
    } catch (e) {
      print('Error updating business: $e');
      rethrow;
    }
  }

  // 10. Delete business
  static Future<bool> deleteBusiness(int businessId) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}businesses/$businessId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting business: $e');
      rethrow;
    }
  }
}