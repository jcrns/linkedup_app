import 'package:flutter/material.dart';

class Category {
  final String name;
  final String image;
  final String colorRGB;

  Category({
    required this.name,
    required this.image,
    required this.colorRGB,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? "",
      image: json['image'] ?? 'No Image', // Default for image if not found
      colorRGB: json['colorRGB'] ?? '#FFFFFF', // Default color, e.g., white
    );
  }
}

class Business {
  final int? id;
  final String name;
  final String image;
  final String businessType;
  final String location;
  final String address;
  final String description;
  final int views;
  final double rating;

  // 💡 FIX: Added the missing 'logo' field
  final String? logo; // Assuming logo is a nullable String URL
  
  // --- ADDED MISSING FIELDS ---
  final String? contactInfo;
  final String? website;
  final String? businessHours;
  final String? targetAudience;
  final double? valuation;
  final double? totalInvestment;
  final double? monthlyGrowthRate;
  final String? deals;
  final String? socialMedia;

  Business({
    this.id,
    required this.name,
    required this.image,
    required this.businessType,
    required this.location,
    required this.address,
    required this.description,
    required this.views,
    required this.rating,
    
    // 💡 FIX: Added 'logo' to the constructor
    this.logo, 
    
    // Add to constructor
    this.contactInfo,
    this.website,
    this.businessHours,
    this.targetAudience,
    this.valuation,
    this.totalInvestment,
    this.monthlyGrowthRate,
    this.deals,
    this.socialMedia,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as int?,
      name: json['name'] ?? "",
      image: json['image'] ?? 'No Image',
      businessType: json['business_type'] ?? "",
      location: json['location'] ?? "",
      address: json['address'] ?? "",
      description: json['description'] ?? "",
      views: json['views'] as int? ?? 0,
      rating: (json['rating'] is String)
          ? double.tryParse(json['rating']) ?? 0.0
          : (json['rating'] as num?)?.toDouble() ?? 0.0,

      logo: json['logo'] as String?,

      contactInfo: json['contact_info'] as String?,
      website: json['website'] as String?,
      businessHours: json['business_hours'] as String?,
      targetAudience: json['target_audience'] as String?,

      valuation: json['valuation'] != null
          ? double.tryParse(json['valuation'].toString())
          : null,

      totalInvestment: json['total_investment'] != null
          ? double.tryParse(json['total_investment'].toString())
          : null,

      monthlyGrowthRate: json['monthly_growth_rate'] != null
          ? double.tryParse(json['monthly_growth_rate'].toString())
          : null,

      deals: json['deals'] as String?,
      socialMedia: json['social_media'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'business_type': businessType,
      'location': location,
      'address': address,
      'description': description,
      'views': views,
      'rating': rating,
      
      // 💡 FIX: Add 'logo' to JSON serialization
      'logo': logo, 
      
      // --- ADD NEW FIELDS TO JSON ---
      'contact_info': contactInfo,
      'website': website,
      'business_hours': businessHours,
      'target_audience': targetAudience,
      'valuation': valuation,
      'total_investment': totalInvestment,
      'monthly_growth_rate': monthlyGrowthRate,
      'deals': deals,
      'social_media': socialMedia,
    };
  }
}
// Add to Models.dart:
class Opportunity {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String postedDate;

  Opportunity({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.postedDate,
  });
}

// Add to RFDataGenerator.dart:

// models/Event.dart
class Event {
  String name;
  String image;
  String location;
  String address;
  String description;
  double rating;

  Event({
    required this.name,
    required this.image,
    required this.location,
    required this.address,
    required this.description,
    required this.rating,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'] ?? 'No Name',
      image: json['image'] ?? 'No Image',
      location: json['location'] ?? 'Unknown Location',
      address: json['address'] ?? 'No Address',
      description: json['description'] ?? 'No Description',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

// Update your Product model in Models.dart
class Product {
  int? id;
  Business? business;
  String name;
  String? description;
  double price;
  int stock;
  String? category;
  String? image;
  DateTime? created_at;
  DateTime? updated_at;

  String get title => name;
  String get img => image ?? 'images/default_product.jpg';

  Product({
    this.id,
    this.business,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.image,
    this.created_at,
    this.updated_at,
  });

  // ✅ FIXED fromJson FACTORY
  factory Product.fromJson(Map<String, dynamic> json) {
    Business? businessObject;
    if (json['business'] != null) {
      // Check if the business data is a nested object (Map)
      if (json['business'] is Map<String, dynamic>) {
        businessObject = Business.fromJson(json['business']);
      
      // Check if it's just an integer ID
      } else if (json['business'] is int) {
        // Create a Business object with only the ID.
        businessObject = Business(
          id: json['business'],
          // Provide default empty values for required fields
          name: '',
          image: '',
          businessType: '',
          location: '',
          address: '',
          description: '',
          views: 0,
          rating: 0.0,
        );
      }
    }

    return Product(
      id: json['id'],
      business: businessObject, // Use the processed business object
      name: json['name'] ?? 'Unnamed Product',
      description: json['description'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      stock: json['stock'] ?? 0,
      category: json['category'],
      image: json['image'],
      created_at: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updated_at: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business': business?.toJson(),
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image': image,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}