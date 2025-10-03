// services/ProductService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/';

  // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Update in ProductService.dart
  static Future<dynamic> getAllProducts({
    int? page,
    int? pageSize,
    String? ordering,
    String? category,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();
      if (ordering != null) queryParams['ordering'] = ordering;
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      // FIX: Add limit parameter support
      if (pageSize == null && page == null) {
        // If no pagination, use limit directly
        queryParams['limit'] = '20'; // Default limit
      }

      final uri = Uri.parse('${_baseUrl}products/').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all products: $e');
      rethrow;
    }
  }

  // Add this new method for getting featured products with limit
  static Future<dynamic> getFeaturedProducts({int limit = 4}) async {
    try {
      final token =_getAuthToken();
      final uri = Uri.parse('${_baseUrl}products/').replace(
        queryParameters: {
          'limit': limit.toString(),
          'ordering': '-created_at', // Or any other ordering for featured
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization' : 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        
        if (decodedResponse is List) {
          return decodedResponse;
        } else if (decodedResponse is Map && decodedResponse.containsKey('results')) {
          return decodedResponse['results'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load featured products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching featured products: $e');
      rethrow;
    }
  }

static Future<dynamic> getRecentProducts({
  int limit = 20,
  String ordering = '-created_at',
}) async {
  try {
    final uri = Uri.parse('${_baseUrl}products/').replace(
      queryParameters: {
        'limit': limit.toString(),
        'ordering': ordering,
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
      final decodedResponse = json.decode(response.body);
      
      // ✅ HANDLE THE PAGINATED RESPONSE
      if (decodedResponse is Map && decodedResponse.containsKey('results')) {
        // Return the list inside the 'results' key
        return decodedResponse['results'];
      } else {
        // This can handle cases where pagination might not be applied (e.g., other endpoints)
        return decodedResponse;
      }
    } else {
      throw Exception('Failed to load recent products: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching recent products: $e');
    rethrow;
  }
}

  // 3. Get products by category
  static Future<dynamic> getProductsByCategory(String category, {int limit = 20}) async {
    try {
      final token =_getAuthToken();

      final uri = Uri.parse('${_baseUrl}products/').replace(
        queryParameters: {
          'category': category,
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization' : 'Token $token',

        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        
        if (decodedResponse is List) {
          return decodedResponse;
        } else if (decodedResponse is Map && decodedResponse.containsKey('results')) {
          return decodedResponse['results'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      rethrow;
    }
  }

  // 4. Search products
  static Future<dynamic> searchProducts({
    required String query,
    String? category,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final Map<String, String> queryParams = {'search': query};
      if (category != null) queryParams['category'] = category;
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();

      final uri = Uri.parse('${_baseUrl}products/').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',

        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  // 5. Get product by ID
  static Future<dynamic> getProductById(int productId) async {
    try {
      final token =_getAuthToken();
      final response = await http.get(
        Uri.parse('${_baseUrl}products/$productId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization' : 'Token $token',

        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      rethrow;
    }
  }

  // 6. Get best selling products (assuming you have a way to determine this)
  static Future<dynamic> getBestSellingProducts({int limit = 10}) async {
    try {
      // This would depend on your business logic - you might need to add a sales_count field
      // final token =_getAuthToken();
      final uri = Uri.parse('${_baseUrl}products/').replace(
        queryParameters: {
          'ordering': '-stock', // Using stock as proxy for best selling for now
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization' : 'Token $token',

        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        
        if (decodedResponse is List) {
          return decodedResponse;
        } else if (decodedResponse is Map && decodedResponse.containsKey('results')) {
          return decodedResponse['results'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load best selling products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching best selling products: $e');
      rethrow;
    }
  }
}