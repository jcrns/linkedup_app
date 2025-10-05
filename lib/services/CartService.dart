import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:room_finder_flutter/models/Models.dart';

class CartService {
  static const String _cartKey = 'user_cart';
  
  static Future<Cart> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);
    
    if (cartData == null) {
      return Cart();
    }
    
    try {
      final Map<String, dynamic> data = json.decode(cartData);
      final List<dynamic> itemsData = data['items'] ?? [];
      
      final List<CartItem> items = [];
      for (final itemData in itemsData) {
        try {
          final product = Product.fromJson(itemData['product']);
          final quantity = itemData['quantity'] ?? 1;
          items.add(CartItem(product: product, quantity: quantity));
        } catch (e) {
          print('Error parsing cart item: $e');
        }
      }
      
      return Cart(items: items);
    } catch (e) {
      print('Error loading cart: $e');
      return Cart();
    }
  }
  
  static Future<void> saveCart(Cart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = {
      'items': cart.items.map((item) => {
        'product': item.product.toJson(),
        'quantity': item.quantity,
      }).toList(),
    };
    
    await prefs.setString(_cartKey, json.encode(cartData));
  }
  
  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    final cart = await getCart();
    cart.addItem(product, quantity: quantity);
    await saveCart(cart);
  }
  
  static Future<void> removeFromCart(int productId) async {
    final cart = await getCart();
    cart.removeItem(productId);
    await saveCart(cart);
  }
  
  static Future<void> updateQuantity(int productId, int newQuantity) async {
    final cart = await getCart();
    cart.updateQuantity(productId, newQuantity);
    await saveCart(cart);
  }
  
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
  
  static Future<int> getCartItemCount() async {
    final cart = await getCart();
    return cart.totalItems;
  }
}