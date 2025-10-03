// services/FavoritesService.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _businessesKey = 'favorite_businesses';
  static const String _productsKey = 'favorite_products';

  // Add business to favorites
  static Future<void> addBusiness(Map<String, dynamic> business) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteBusinesses();
    
    // Check if already favorited
    if (!favorites.any((fav) => fav['id'] == business['id'])) {
      favorites.add(business);
      await prefs.setString(_businessesKey, json.encode(favorites));
    }
  }

  // Remove business from favorites
  static Future<void> removeBusiness(int businessId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteBusinesses();
    favorites.removeWhere((fav) => fav['id'] == businessId);
    await prefs.setString(_businessesKey, json.encode(favorites));
  }

  // Get favorite businesses
  static Future<List<Map<String, dynamic>>> getFavoriteBusinesses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_businessesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Check if business is favorited
  static Future<bool> isBusinessFavorited(int businessId) async {
    final favorites = await getFavoriteBusinesses();
    return favorites.any((fav) => fav['id'] == businessId);
  }

  // Add product to favorites
  static Future<void> addProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteProducts();
    
    // Check if already favorited
    if (!favorites.any((fav) => fav['id'] == product['id'])) {
      favorites.add(product);
      await prefs.setString(_productsKey, json.encode(favorites));
    }
  }

  // Remove product from favorites
  static Future<void> removeProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteProducts();
    favorites.removeWhere((fav) => fav['id'] == productId);
    await prefs.setString(_productsKey, json.encode(favorites));
  }

  // Get favorite products
  static Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_productsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Check if product is favorited
  static Future<bool> isProductFavorited(int productId) async {
    final favorites = await getFavoriteProducts();
    return favorites.any((fav) => fav['id'] == productId);
  }

  // Clear all favorites
  static Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_businessesKey);
    await prefs.remove(_productsKey);
  }
}