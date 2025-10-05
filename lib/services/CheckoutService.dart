import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:room_finder_flutter/models/Models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/';

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return headers;
  }

  static Future<Map<String, String>> get _authHeaders async {
    final token = await _getAuthToken();
    final headers = _headers;
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  // Shipping Address APIs
  static Future<List<ShippingAddress>> getShippingAddresses() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('${_baseUrl}shipping-addresses/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ShippingAddress.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shipping addresses: ${response.statusCode}');
    }
  }

static Future<ShippingAddress> createShippingAddress(ShippingAddress address) async {
  final headers = await _authHeaders;
  
  // First, check if this address already exists for the current user
  try {
    final existingAddresses = await getShippingAddresses();
    final existingAddress = _findMatchingAddress(existingAddresses, address);
    
    if (existingAddress != null) {
      print('Found existing shipping address with ID: ${existingAddress.id}');
      return existingAddress;
    }
  } catch (e) {
    print('Error checking existing addresses: $e');
    // Continue with creation if check fails
  }
  
  // If no existing address found, create new one
  final response = await http.post(
    Uri.parse('${_baseUrl}shipping-addresses/'),
    headers: headers,
    body: json.encode(address.toJson()),
  );

  if (response.statusCode == 201) {
    print('Created new shipping address: ${response.body}');
    return ShippingAddress.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create shipping address: ${response.statusCode}');
  }
}

// Helper method to find matching addresses
static ShippingAddress? _findMatchingAddress(List<ShippingAddress> existingAddresses, ShippingAddress newAddress) {
  for (final existing in existingAddresses) {
    if (_addressesMatch(existing, newAddress)) {
      return existing;
    }
  }
  return null;
}

// Helper method to compare addresses
static bool _addressesMatch(ShippingAddress a, ShippingAddress b) {
  return a.fullName.toLowerCase() == b.fullName.toLowerCase() &&
         a.email.toLowerCase() == b.email.toLowerCase() &&
         a.address1.toLowerCase() == b.address1.toLowerCase() &&
         a.city.toLowerCase() == b.city.toLowerCase() &&
         a.country.toLowerCase() == b.country.toLowerCase() &&
         (a.zipcode ?? '').toLowerCase() == (b.zipcode ?? '').toLowerCase();
}

  static Future<ShippingAddress> updateShippingAddress(ShippingAddress address) async {
    final headers = await _authHeaders;
    final response = await http.put(
      Uri.parse('${_baseUrl}shipping-addresses/${address.id}/'),
      headers: headers,
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 200) {
      return ShippingAddress.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update shipping address: ${response.statusCode}');
    }
  }

  static Future<void> deleteShippingAddress(int addressId) async {
    final headers = await _authHeaders;
    final response = await http.delete(
      Uri.parse('${_baseUrl}shipping-addresses/$addressId/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shipping address: ${response.statusCode}');
    }
  }

  // Order APIs
  static Future<List<Order>> getOrders() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('${_baseUrl}orders/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  // Update the createOrder method to handle existing addresses better
  static Future<Order> createOrder({
    required int shippingAddressId,
    required Cart cart,
    double shippingCost = 0.0,
    double taxRate = 0.0,
  }) async {
    final headers = await _authHeaders;
    
    final orderData = {
      'shipping_address': shippingAddressId,
      'items': cart.items.map((item) => {
        'product': item.product.id,
        'quantity': item.quantity,
      }).toList(),
      'shipping_cost': shippingCost.toString(),
      'tax_rate': taxRate.toString(),
    };

    print('Creating order with shipping address ID: $shippingAddressId');
    print('Order data: $orderData');

    final response = await http.post(
      Uri.parse('${_baseUrl}orders/'),
      headers: headers,
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      print('Order created successfully: ${response.body}');
      return Order.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create order: ${response.statusCode}');
    }
  }
  
  static Future<Order> getOrder(int orderId) async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('${_baseUrl}orders/$orderId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }

  static Future<Order> updateOrderStatus(int orderId, String status) async {
    final headers = await _authHeaders;
    final response = await http.post(
      Uri.parse('${_baseUrl}orders/$orderId/update_status/'),
      headers: headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update order status: ${response.statusCode}');
    }
  }

  // Calculate order total (for display purposes before creating actual order)
  static double calculateOrderTotal({
    required Cart cart,
    double shippingCost = 0.0,
    double taxRate = 0.0,
  }) {
    final subtotal = cart.subtotal;
    final taxAmount = subtotal * taxRate;
    return subtotal + taxAmount + shippingCost;
  }

  // Payment method options
  static List<PaymentMethod> getPaymentMethods() {
    return [
      PaymentMethod(
        id: 1,
        name: 'Credit Card',
        image: 'images/payment/credit_card.png',
        type: 'card',
      ),
      PaymentMethod(
        id: 2,
        name: 'PayPal',
        image: 'images/sneakerShopping/ic_paypal.png',
        type: 'paypal',
      ),
      PaymentMethod(
        id: 3,
        name: 'Bank Transfer',
        image: 'images/payment/bank_transfer.png',
        type: 'bank',
      ),
      // PaymentMethod(
      //   id: 4,
      //   name: 'Cash on Delivery',
      //   image: 'images/payment/cash.png',
      //   type: 'cash',
      // ),
    ];
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final String image;
  final String type;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.image,
    required this.type,
  });
}