// models.dart

// Note: No 'package:flutter/material.dart' import is needed as these are pure data models.

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
      image: json['image'] ?? 'images/default_product.jpg',
      colorRGB: json['colorRGB'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'colorRGB': colorRGB,
    };
  }
}


class Business {
  final int? id;
  final String name;
  final String image;
  final String? logo;
  final String businessType;
  final String location;
  final String address;
  final String description;
  final int views;
  final double rating;
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
    this.logo,
    required this.businessType,
    required this.location,
    required this.address,
    required this.description,
    required this.views,
    required this.rating,
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

  // --- CORRECTED: This constructor allows creating a partial Business object when only an ID is available. ---
  Business.fromId(this.id)
      : name = '',
        image = '',
        logo = null,
        businessType = '',
        location = '',
        address = '',
        description = '',
        views = 0,
        rating = 0.0,
        contactInfo = null,
        website = null,
        businessHours = null,
        targetAudience = null,
        valuation = null,
        totalInvestment = null,
        monthlyGrowthRate = null,
        deals = null,
        socialMedia = null;

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'] ?? "",
      image: json['image'] ?? 'images/default_product.jpg',
      logo: json['logo'],
      businessType: json['business_type'] ?? "",
      location: json['location'] ?? "",
      address: json['address'] ?? "",
      description: json['description'] ?? "",
      views: json['views'] ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      contactInfo: json['contact_info'],
      website: json['website'],
      businessHours: json['business_hours'],
      targetAudience: json['target_audience'],
      valuation: double.tryParse(json['valuation'].toString()),
      totalInvestment: double.tryParse(json['total_investment'].toString()),
      monthlyGrowthRate: double.tryParse(json['monthly_growth_rate'].toString()),
      deals: json['deals'],
      socialMedia: json['social_media'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'logo': logo,
      'business_type': businessType,
      'location': location,
      'address': address,
      'description': description,
      'views': views,
      'rating': rating,
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

  // --- FIX: Added fromJson factory for completeness. ---
  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      title: json['title'] ?? 'No Title',
      company: json['company'] ?? 'No Company',
      location: json['location'] ?? 'No Location',
      salary: json['salary'] ?? 'Not Disclosed',
      type: json['type'] ?? 'Full-Time',
      postedDate: json['posted_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'type': type,
      'posted_date': postedDate,
    };
  }
}


class Event {
  final String name;
  final String image;
  final String location;
  final String address;
  final String description;
  final double rating;

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
      image: json['image'] ?? 'images/default_product.jpg',
      location: json['location'] ?? 'Unknown Location',
      address: json['address'] ?? 'No Address',
      description: json['description'] ?? 'No Description',
      // --- FIX: Made rating parsing safer. ---
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'location': location,
      'address': address,
      'description': description,
      'rating': rating,
    };
  }
}


class Product {
  final int? id;
  final Business? business;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  // --- ✅ CORRECTED fromJson FACTORY ---
  factory Product.fromJson(Map<String, dynamic> json) {
    Business? businessObject;
    if (json['business'] != null) {
      // Case 1: API sends a full nested business object
      if (json['business'] is Map<String, dynamic>) {
        businessObject = Business.fromJson(json['business']);
      }
      // Case 2: API sends just the integer ID for the business
      else if (json['business'] is int) {
        businessObject = Business.fromId(json['business']);
      }
    }

    return Product(
      id: json['id'],
      // --- FIX: Use the 'businessObject' created above. This was the main error. ---
      business: businessObject,
      name: json['name'] ?? 'Unnamed Product',
      description: json['description'],
      // --- FIX: Use tryParse for safer parsing to avoid crashes. ---
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      category: json['category'],
      image: json['image'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // --- FIX: Serialize business ID if available, otherwise null. ---
      'business': business?.id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Add to your existing models.dart file
class ShippingAddress {
  final int? id;
  final int? user;
  final String fullName;
  final String email;
  final String address1;
  final String? address2;
  final String city;
  final String? state;
  final String? zipcode;
  final String country;

  ShippingAddress({
    this.id,
    this.user,
    required this.fullName,
    required this.email,
    required this.address1,
    this.address2,
    required this.city,
    this.state,
    this.zipcode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      user: json['user'],
      fullName: json['full_name'] ?? "",
      email: json['email'] ?? "",
      address1: json['address1'] ?? "",
      address2: json['address2'],
      city: json['city'] ?? "",
      state: json['state'],
      zipcode: json['zipcode'],
      country: json['country'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'full_name': fullName,
      'email': email,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'country': country,
    };
  }

  ShippingAddress copyWith({
    int? id,
    int? user,
    String? fullName,
    String? email,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipcode,
    String? country,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      user: user ?? this.user,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipcode: zipcode ?? this.zipcode,
      country: country ?? this.country,
    );
  }
}

class OrderItem {
  final int? id;
  final int? order;
  final int? productId;
  final String? productName;
  final String? productImage;
  final double price;
  final int quantity;

  OrderItem({
    this.id,
    this.order,
    this.productId,
    this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  double get cost => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      order: json['order'],
      productId: json['product'], // Directly assign the ID
      productName: json['product_name'],
      productImage: json['product_image'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'product': productId, // Just the ID
      'price': price,
      'quantity': quantity,
    };
  }
}

// user_model.dart

class User {
  final int id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Order {
  final int? id;
  final String? userEmail;
  final ShippingAddress? shippingAddress;
  final String? stripeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalPaid;
  final String status;
  final bool paid;
  final double shippingCost;
  final double taxRate;
  final List<OrderItem> items;

  Order({
    this.id,
    this.userEmail,
    this.shippingAddress,
    this.stripeId,
    this.createdAt,
    this.updatedAt,
    required this.totalPaid,
    required this.status,
    required this.paid,
    required this.shippingCost,
    required this.taxRate,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userEmail: json['user_email'],
      shippingAddress: json['shipping_address'] != null 
          ? ShippingAddress.fromJson(json['shipping_address']) 
          : null,
      stripeId: json['stripe_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      totalPaid: double.tryParse(json['total_paid'].toString()) ?? 0.0,
      status: json['status'] ?? 'Pending',
      paid: json['paid'] ?? false,
      shippingCost: double.tryParse(json['shipping_cost'].toString()) ?? 0.0,
      taxRate: double.tryParse(json['tax_rate'].toString()) ?? 0.0,
      items: json['items'] != null 
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_email': userEmail,
      'shipping_address': shippingAddress?.toJson(), // Changed this line
      'stripe_id': stripeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'total_paid': totalPaid,
      'status': status,
      'paid': paid,
      'shipping_cost': shippingCost,
      'tax_rate': taxRate,
      'items': items.map((item) => item.toJson()).toList(), // Added items serialization
    };
  }
}

// Cart Models
class CartItem {
  final Product product;
  int quantity;
  
  CartItem({
    required this.product,
    this.quantity = 1,
  });
  
  double get totalPrice => product.price * quantity;
  
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart {
  final List<CartItem> items;
  
  Cart({List<CartItem>? items}) : items = items ?? [];
  
  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + quantity,
      );
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
  }
  
  void removeItem(int productId) {
    items.removeWhere((item) => item.product.id == productId);
  }
  
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    
    final existingIndex = items.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(quantity: newQuantity);
    }
  }
  
  void clear() {
    items.clear();
  }
  
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  bool get isEmpty => items.isEmpty;
  
  Cart copyWith({
    List<CartItem>? items,
  }) {
    return Cart(
      items: items ?? this.items,
    );
  }
}
