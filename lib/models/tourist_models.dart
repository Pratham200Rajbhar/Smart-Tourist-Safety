class TouristGroup {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String status; // 'safe' or 'alert'
  final DateTime lastUpdate;

  TouristGroup({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.lastUpdate,
  });

  factory TouristGroup.fromJson(Map<String, dynamic> json) {
    return TouristGroup(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
      status: json['status'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'status': status,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Tourist {
  final String id;
  final String name;
  final String digitalId;
  final double lat;
  final double lng;
  final DateTime lastSeen;
  final bool isInDangerZone;

  Tourist({
    required this.id,
    required this.name,
    required this.digitalId,
    required this.lat,
    required this.lng,
    required this.lastSeen,
    this.isInDangerZone = false,
  });

  Tourist copyWith({
    String? id,
    String? name,
    String? digitalId,
    double? lat,
    double? lng,
    DateTime? lastSeen,
    bool? isInDangerZone,
  }) {
    return Tourist(
      id: id ?? this.id,
      name: name ?? this.name,
      digitalId: digitalId ?? this.digitalId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      lastSeen: lastSeen ?? this.lastSeen,
      isInDangerZone: isInDangerZone ?? this.isInDangerZone,
    );
  }
}

class SOSAlert {
  final String id;
  final String touristId;
  final String touristName;
  final String digitalId;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String severity; // 'high', 'medium', 'low'
  final String status; // 'active', 'resolved'

  SOSAlert({
    required this.id,
    required this.touristId,
    required this.touristName,
    required this.digitalId,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.severity = 'high',
    this.status = 'active',
  });
}

class GeoFence {
  final String id;
  final String name;
  final List<LatLngPoint> coordinates;
  final String type; // 'safe' or 'danger'
  final String color;

  GeoFence({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.type,
    required this.color,
  });
}

class LatLngPoint {
  final double latitude;
  final double longitude;

  LatLngPoint(this.latitude, this.longitude);
}