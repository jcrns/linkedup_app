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
  final String name;
  final String image;
  final String businessType;
  final String location;
  final String address;
  final String description;
  final String views;
  final double rating;

  Business({
    required this.name,
    required this.image,
    required this.businessType,
    required this.location,
    required this.address,
    required this.description,
    required this.views,
    required this.rating,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'] ?? "",
      image: json['image'] ?? 'No Image',
      businessType: json['business_type'] ?? "",
      location: json['location'] ?? "",
      address: json['address'] ?? "",
      description: json['description'] ?? "",
      views: json['views'] ?? "",
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
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

class Product {
  final String img;
  final String title;
  final String price;
  final String description;
  final String views;
  final bool unReadNotification;
  final Widget? newScreenWidget;
  final Color? color;
  final double rating;

  Product({
    required this.img,
    required this.title,
    required this.price,
    this.description = "",
    this.views = "0",
    this.unReadNotification = false,
    this.newScreenWidget,
    this.color,
    this.rating = 0.0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      img: json['img'] ?? 'assets/default_product.png',
      title: json['title'] ?? 'Untitled Product',
      price: json['price'] ?? '\$0',
      description: json['description'] ?? '',
      views: json['views']?.toString() ?? '0',
      unReadNotification: json['unReadNotification'] ?? false,
      newScreenWidget: json['newScreenWidget'], // Note: Requires custom handling
      color: json['color'] != null 
           ? Color(int.parse(json['color'], radix: 16))
           : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}
