import 'dart:convert';
import 'package:flutter/services.dart';

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String category;
  final List<String> tags;
  final double rating;
  final int reviewCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.tags,
    required this.rating,
    required this.reviewCount,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      district: json['district'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      category: json['category'],
      tags: List<String>.from(json['tags']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;

  RestaurantService._internal();

  List<Restaurant> _restaurants = [];
  bool _isInitialized = false;

  Future<List<Restaurant>> getAllRestaurants() async {
    if (!_isInitialized) {
      await _loadRestaurants();
    }
    return _restaurants;
  }

  Future<void> _loadRestaurants() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/restaurants_data.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _restaurants = jsonList.map((json) => Restaurant.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      print('맛집 데이터 로드 실패: $e');
      _restaurants = [];
    }
  }

  List<Restaurant> getRestaurantsByCategory(String category) {
    return _restaurants
        .where((restaurant) => restaurant.category == category)
        .toList();
  }

  List<Restaurant> getRestaurantsByDistrict(String district) {
    return _restaurants
        .where((restaurant) => restaurant.district == district)
        .toList();
  }

  List<Restaurant> searchRestaurants(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _restaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(lowercaseQuery) ||
          restaurant.address.toLowerCase().contains(lowercaseQuery) ||
          restaurant.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
