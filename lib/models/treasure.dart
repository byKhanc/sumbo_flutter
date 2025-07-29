import 'package:google_maps_flutter/google_maps_flutter.dart';

class Treasure {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> tags;

  const Treasure({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.tags,
  });

  LatLng get position => LatLng(latitude, longitude);

  @override
  String toString() {
    return 'Treasure(id: $id, name: $name, description: $description, address: $address, latitude: $latitude, longitude: $longitude, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Treasure && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
