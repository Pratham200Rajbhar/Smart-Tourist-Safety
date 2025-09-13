import '../models/tourist_models.dart';

class DemoData {
  // Tourist Groups in Jammu & Kashmir
  static List<TouristGroup> touristGroups = [
    TouristGroup(
      id: 1,
      name: 'Group A - Srinagar',
      lat: 34.0837,
      lng: 74.7973,
      status: 'safe',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    TouristGroup(
      id: 2,
      name: 'Group B - Gulmarg',
      lat: 34.0484,
      lng: 74.3805,
      status: 'alert',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    TouristGroup(
      id: 3,
      name: 'Group C - Leh',
      lat: 34.1526,
      lng: 77.5770,
      status: 'safe',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TouristGroup(
      id: 4,
      name: 'Group D - Kargil',
      lat: 33.7782,
      lng: 76.5762,
      status: 'alert',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    TouristGroup(
      id: 5,
      name: 'Group E - Pahalgam',
      lat: 34.0173,
      lng: 75.3312,
      status: 'safe',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    TouristGroup(
      id: 6,
      name: 'Group F - Sonamarg',
      lat: 34.2996,
      lng: 75.2918,
      status: 'safe',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  // Geo-fences for demonstration
  static List<GeoFence> geoFences = [
    // Danger zone near Gulmarg
    GeoFence(
      id: 'danger1',
      name: 'High Risk Area - Gulmarg',
      type: 'danger',
      color: '#FF5252',
      coordinates: [
        LatLngPoint(34.0584, 74.3705),
        LatLngPoint(34.0384, 74.3705),
        LatLngPoint(34.0384, 74.3905),
        LatLngPoint(34.0584, 74.3905),
      ],
    ),
    // Safe zone around Srinagar
    GeoFence(
      id: 'safe1',
      name: 'Safe Zone - Srinagar City',
      type: 'safe',
      color: '#4CAF50',
      coordinates: [
        LatLngPoint(34.0937, 74.7873),
        LatLngPoint(34.0737, 74.7873),
        LatLngPoint(34.0737, 74.8073),
        LatLngPoint(34.0937, 74.8073),
      ],
    ),
    // Danger zone near Kargil
    GeoFence(
      id: 'danger2',
      name: 'Restricted Area - Kargil',
      type: 'danger',
      color: '#FF5252',
      coordinates: [
        LatLngPoint(33.7882, 76.5662),
        LatLngPoint(33.7682, 76.5662),
        LatLngPoint(33.7682, 76.5862),
        LatLngPoint(33.7882, 76.5862),
      ],
    ),
  ];

  // Sample tourist for current user
  static Tourist currentTourist = Tourist(
    id: 'user123',
    name: 'Demo User',
    digitalId: 'BLK-CHAIN-${DateTime.now().millisecondsSinceEpoch}',
    lat: 34.0837, // Starting at Srinagar
    lng: 74.7973,
    lastSeen: DateTime.now(),
  );

  // Sample SOS alerts for authority dashboard
  static List<SOSAlert> sosAlerts = [
    SOSAlert(
      id: 'sos_001',
      touristId: 'tourist_456',
      touristName: 'John Doe',
      digitalId: 'BLK-CHAIN-456789',
      lat: 34.0484,
      lng: 74.3805,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      severity: 'high',
      status: 'active',
    ),
    SOSAlert(
      id: 'sos_002',
      touristId: 'tourist_789',
      touristName: 'Jane Smith',
      digitalId: 'BLK-CHAIN-789012',
      lat: 33.7782,
      lng: 76.5762,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      severity: 'medium',
      status: 'resolved',
    ),
  ];

  // Safety tips and alerts
  static List<Map<String, String>> safetyTips = [
    {
      'title': 'Stay Connected',
      'description': 'Keep your mobile phone charged and maintain contact with your group.',
      'icon': '📱'
    },
    {
      'title': 'Weather Awareness',
      'description': 'Check weather conditions before traveling to high-altitude areas.',
      'icon': '🌤️'
    },
    {
      'title': 'Emergency Contacts',
      'description': 'Save local emergency numbers: Police (100), Medical (108).',
      'icon': '🚨'
    },
    {
      'title': 'Travel in Groups',
      'description': 'Avoid traveling alone, especially in remote areas.',
      'icon': '👥'
    },
  ];

  // Mock function to simulate movement
  static void simulateTouristMovement() {
    final random = DateTime.now().millisecond;
    if (random % 2 == 0) {
      // Move slightly north
      currentTourist = currentTourist.copyWith(
        lat: currentTourist.lat + 0.001,
        lastSeen: DateTime.now(),
      );
    } else {
      // Move slightly east
      currentTourist = currentTourist.copyWith(
        lng: currentTourist.lng + 0.001,
        lastSeen: DateTime.now(),
      );
    }
  }

  // Check if tourist is in danger zone
  static bool isInDangerZone(double lat, double lng) {
    for (final fence in geoFences) {
      if (fence.type == 'danger') {
        // Simple point-in-polygon check (basic rectangle)
        final minLat = fence.coordinates.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
        final maxLat = fence.coordinates.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
        final minLng = fence.coordinates.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
        final maxLng = fence.coordinates.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);
        
        if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
          return true;
        }
      }
    }
    return false;
  }

  // Location Safety Scores for popular destinations
  static List<LocationSafetyScore> locationSafetyScores = [
    LocationSafetyScore(
      locationName: 'Srinagar City',
      latitude: 34.0837,
      longitude: 74.7973,
      safetyScore: 85,
      riskLevel: 'low',
      safetyFactors: [
        'Active police presence',
        'Tourist-friendly infrastructure',
        'Emergency services available',
        'Good communication networks'
      ],
      riskFactors: [
        'Occasional protests',
        'Traffic congestion'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    LocationSafetyScore(
      locationName: 'Gulmarg',
      latitude: 34.0484,
      longitude: 74.3805,
      safetyScore: 35,
      riskLevel: 'high',
      safetyFactors: [
        'Beautiful scenic location',
        'Ski resort facilities'
      ],
      riskFactors: [
        'Weather alerts active',
        'Avalanche risk',
        'Limited emergency access',
        'Poor road conditions'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    LocationSafetyScore(
      locationName: 'Leh',
      latitude: 34.1526,
      longitude: 77.5770,
      safetyScore: 75,
      riskLevel: 'low',
      safetyFactors: [
        'Well-established tourism',
        'Medical facilities available',
        'Stable political situation',
        'Good tourist infrastructure'
      ],
      riskFactors: [
        'High altitude effects',
        'Remote location'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    LocationSafetyScore(
      locationName: 'Pahalgam',
      latitude: 34.0173,
      longitude: 75.3312,
      safetyScore: 80,
      riskLevel: 'low',
      safetyFactors: [
        'Popular tourist destination',
        'Good accommodation',
        'Regular security patrols',
        'Easy access roads'
      ],
      riskFactors: [
        'Monsoon flooding risk',
        'Crowded during peak season'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    LocationSafetyScore(
      locationName: 'Sonamarg',
      latitude: 34.2996,
      longitude: 75.2918,
      safetyScore: 70,
      riskLevel: 'medium',
      safetyFactors: [
        'Scenic valley location',
        'Tourist police present',
        'Good connectivity'
      ],
      riskFactors: [
        'Weather dependent access',
        'Limited medical facilities',
        'Landslide risk in monsoon'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    LocationSafetyScore(
      locationName: 'Kargil',
      latitude: 33.7782,
      longitude: 76.5762,
      safetyScore: 45,
      riskLevel: 'medium',
      safetyFactors: [
        'Strategic location',
        'Military presence'
      ],
      riskFactors: [
        'Border area restrictions',
        'Limited tourist infrastructure',
        'Harsh weather conditions',
        'Security checks required'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    LocationSafetyScore(
      locationName: 'Dal Lake',
      latitude: 34.1218,
      longitude: 74.8092,
      safetyScore: 90,
      riskLevel: 'low',
      safetyFactors: [
        'Major tourist attraction',
        'Constant security presence',
        'Well-developed facilities',
        'Emergency boats available',
        'Tourist assistance centers'
      ],
      riskFactors: [
        'Water safety concerns',
        'Tourist scams possible'
      ],
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  // Search locations by name (case-insensitive)
  static List<LocationSafetyScore> searchLocations(String query) {
    if (query.isEmpty) return [];
    
    return locationSafetyScores.where((location) {
      return location.locationName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get safety score for a specific location by coordinates
  static LocationSafetyScore? getLocationSafetyScore(double lat, double lng, {double threshold = 0.1}) {
    for (final location in locationSafetyScores) {
      final distance = _calculateDistance(lat, lng, location.latitude, location.longitude);
      if (distance <= threshold) {
        return location;
      }
    }
    return null;
  }

  // Get current tourist for UI display
  static Tourist getCurrentTourist() {
    return currentTourist;
  }

  // Simple distance calculation
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return ((lat1 - lat2).abs() + (lng1 - lng2).abs());
  }
}
