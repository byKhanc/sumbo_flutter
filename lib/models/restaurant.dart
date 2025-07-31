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
  final String? phone;
  final String? openingHours;
  final String? mission;
  final int? reward;
  final bool? isOpen;

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
    this.phone,
    this.openingHours,
    this.mission,
    this.reward,
    this.isOpen,
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
      phone: json['phone'],
      openingHours: json['openingHours'],
      mission: json['mission'],
      reward: json['reward'],
      isOpen: json['isOpen'],
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
      'phone': phone,
      'openingHours': openingHours,
      'mission': mission,
      'reward': reward,
      'isOpen': isOpen,
    };
  }
}
