import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/tourist_bloc.dart';
import '../blocs/location_bloc.dart';
import '../models/demo_data.dart';
import '../models/tourist_models.dart';
import '../widgets/tourist_info_popup.dart';
import '../screens/sos_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/family_sharing_screen.dart';
import '../screens/settings_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  // Pulse animation removed to make SOS button static
  
  bool _isLocationSharingEnabled = true;
  bool _isSearching = false;
  List<LocationSafetyScore> _searchResults = [];
  LocationSafetyScore? _selectedLocation;

  // Helper: toggle location sharing state
  void _toggleLocationSharing() {
    setState(() => _isLocationSharingEnabled = !_isLocationSharingEnabled);
  }

  // Helper: clear search results
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults.clear();
      _selectedLocation = null;
    });
  }

  // Helper: select a safety location from search
  void _selectLocation(LocationSafetyScore location) {
    setState(() {
      _selectedLocation = location;
      _isSearching = false;
      _searchController.text = location.locationName;
    });
    // Center map to selection
    _mapController.move(LatLng(location.latitude, location.longitude), 12.5);
  }

  // Existing method redeclared earlier due to corruption; ensure no duplicate
  void _showTouristGroupInfo(TouristGroup group) {
    showDialog(
      context: context,
      builder: (context) => TouristInfoPopup(group: group),
    );
  }

  @override
  void initState() {
    super.initState();
    // Removed animation setup

    // Initialize Blocs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TouristBloc>().add(LoadTourists());
      context.read<LocationBloc>().add(StartLocationTracking());
    });
  }

  @override
  void dispose() {
    // No animation controller to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32), // Dark green
                Color(0xFF4CAF50), // Medium green
                Color(0xFF66BB6A), // Light green
              ],
            ),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.green.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showDrawer(context),
        ),
        title: const Text(
          'Safety Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Refresh data
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Optional: simulate slight movement before reload
              DemoData.simulateTouristMovement();
              context.read<TouristBloc>().add(LoadTourists());
            },
          ),
          // Location Sharing Toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _isLocationSharingEnabled ? Icons.location_on : Icons.location_off,
                color: _isLocationSharingEnabled ? Colors.lightGreen : Colors.red,
              ),
              onPressed: _toggleLocationSharing,
            ),
          ),
          // Alerts Button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                if (DemoData.sosAlerts.any((alert) => alert.status == 'active'))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<TouristBloc, TouristState>(
        listener: (context, state) {
          if (state is DangerZoneAlert) {
            _showDangerAlert(state.message);
            _triggerVibration();
          }
        },
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStatusBanner(),
            ),
            
            // Search Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildSearchBar(),
            ),
            
            // Search Results
            if (_isSearching && _searchResults.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchResults(),
              ),
            
            // Map Content
            Expanded(
              child: Stack(
                children: [
                  // Full-screen Map
                  BlocBuilder<TouristBloc, TouristState>(
                    builder: (context, state) {
                      if (state is TouristLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      if (state is TouristLoaded) {
                        return _buildHeatmapView(state);
                      }
                      
                      if (state is DangerZoneAlert) {
                        return _buildHeatmapView(TouristLoaded(
                          groups: DemoData.touristGroups,
                          currentTourist: state.tourist,
                          sosAlerts: DemoData.sosAlerts,
                        ));
                      }
                      
                      return const Center(
                        child: Text('Failed to load map data'),
                      );
                    },
                  ),
                  
                  // Selected Location Safety Score
                  if (_selectedLocation != null)
                    Positioned(
                      bottom: 200,
                      left: 16,
                      right: 16,
                      child: _buildSafetyScoreCard(),
                    ),
                  
                  // Legend removed (Safe/Danger zone card eliminated)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              Colors.red.shade600,
              Colors.red.shade700,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SOSScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emergency, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SOS EMERGENCY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapView(TouristLoaded state) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(34.0837, 74.7973), // Srinagar
        initialZoom: 10.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.smart_tourist_safety',
        ),
        
        PolygonLayer(
          polygons: _buildHeatmapPolygons(),
        ),
        
        MarkerLayer(
          markers: state.groups.map((group) {
            return Marker(
              width: 50.0,
              height: 50.0,
              point: LatLng(group.lat, group.lng),
              child: GestureDetector(
                onTap: () => _showTouristGroupInfo(group),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getGroupColor(group.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getGroupIcon(group.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        if (_isLocationSharingEnabled && state.currentTourist != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(state.currentTourist!.lat, state.currentTourist!.lng),
                child: Container(
                  decoration: BoxDecoration(
                    color: state.currentTourist!.isInDangerZone ? Colors.red : Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Polygon> _buildHeatmapPolygons() {
    return [
      Polygon(
        points: [
          const LatLng(34.0684, 74.3605),
          const LatLng(34.0284, 74.3605),
          const LatLng(34.0284, 74.4005),
          const LatLng(34.0684, 74.4005),
        ],
        color: Colors.red.withValues(alpha: 0.4),
        borderColor: Colors.red,
        borderStrokeWidth: 2.0,
      ),
      Polygon(
        points: [
          const LatLng(34.1026, 74.7570),
          const LatLng(34.0626, 74.7570),
          const LatLng(34.0626, 74.8370),
          const LatLng(34.1026, 74.8370),
        ],
        color: Colors.green.withValues(alpha: 0.4),
        borderColor: Colors.green,
        borderStrokeWidth: 2.0,
      ),
    ];
  }

  Widget _buildStatusBanner() {
    return BlocBuilder<TouristBloc, TouristState>(
      builder: (context, state) {
        String status = 'SAFE';
        Color statusColor = Colors.green.shade600;
        IconData statusIcon = Icons.shield_rounded;
        
        if (state is TouristLoaded && state.currentTourist != null) {
          if (state.currentTourist!.isInDangerZone) {
            status = 'DANGER';
            statusColor = Colors.red.shade600;
            statusIcon = Icons.warning_rounded;
          }
        } else if (state is DangerZoneAlert) {
          status = 'ALERT';
          statusColor = Colors.orange.shade600;
          statusIcon = Icons.warning_amber_rounded;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor,
                statusColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              if (_isLocationSharingEnabled) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Legend builder removed as per request

  // Add all the search-related methods and utility methods
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.green.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '🔍 Search location for safety score...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
    );
  }

  // Continue with remaining methods...
  Color _getSafetyColor(int score) {
    if (score >= 80) return const Color(0xFF2E7D32); // Dark green - Excellent
    if (score >= 60) return const Color(0xFF388E3C); // Medium green - Good
    if (score >= 40) return const Color(0xFFFF8F00); // Premium orange - Fair
    if (score >= 20) return const Color(0xFFE64A19); // Orange red - Poor
    return const Color(0xFFD32F2F); // Deep red - Very poor
  }

  Color _getGroupColor(String status) {
    switch (status) {
      case 'safe':
        return Colors.green;
      case 'alert':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getGroupIcon(String status) {
    switch (status) {
      case 'safe':
        return Icons.group;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.dangerous;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults.clear();
      } else {
        _isSearching = true;
        _searchResults = DemoData.searchLocations(query);
      }
    });
  }

  // Restored drawer method (previous implementation became malformed during edits)
  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green.shade50],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.family_restroom, color: Colors.green.shade600),
              title: const Text('Family Sharing'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilySharingScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green.shade600),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.green.shade600),
              title: const Text('E-FIR Filing'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/efir');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDangerAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600, size: 30),
            const SizedBox(width: 10),
            const Text('DANGER ALERT!'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SOSScreen()),
              );
            },
            child: const Text('SOS'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _triggerVibration() {
    HapticFeedback.heavyImpact();
  }

  // Add the search results and safety card methods
  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _searchResults.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.green.shade100,
            indent: 60,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final location = _searchResults[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectLocation(location),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getSafetyColor(location.safetyScore),
                              _getSafetyColor(location.safetyScore).withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getSafetyColor(location.safetyScore).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            location.safetyGrade,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.locationName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${location.safetyDescription} (${location.safetyScore}/100)',
                              style: TextStyle(
                                color: _getSafetyColor(location.safetyScore),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.green.shade400,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSafetyScoreCard() {
    final location = _selectedLocation!;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getSafetyColor(location.safetyScore),
                            _getSafetyColor(location.safetyScore).withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getSafetyColor(location.safetyScore).withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          location.safetyGrade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.locationName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getSafetyColor(location.safetyScore).withValues(alpha: 0.1),
                                  _getSafetyColor(location.safetyScore).withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getSafetyColor(location.safetyScore).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${location.safetyScore}/100 - ${location.safetyDescription}',
                              style: TextStyle(
                                color: _getSafetyColor(location.safetyScore),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        onPressed: () => setState(() => _selectedLocation = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (location.safetyFactors.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Safety Factors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...location.safetyFactors.take(2).map((factor) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade500, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  factor,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
                if (location.riskFactors.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade50,
                          Colors.orange.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.orange.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Risk Factors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...location.riskFactors.take(2).map((factor) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.orange.shade500, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  factor,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}