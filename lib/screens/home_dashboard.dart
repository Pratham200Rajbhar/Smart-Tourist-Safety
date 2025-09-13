import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/tourist_bloc.dart';
import '../blocs/location_bloc.dart';
import '../models/demo_data.dart';
import '../widgets/safety_score_widget.dart';
import '../widgets/tourist_info_popup.dart';
import '../screens/sos_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Load initial data
    context.read<TouristBloc>().add(LoadTourists());
    context.read<LocationBloc>().add(StartLocationTracking());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tourist Safety Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              _showDigitalIdDialog();
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
            // Safety Score Widget
            const SafetyScoreWidget(),
            
            // Map
            Expanded(
              child: BlocBuilder<TouristBloc, TouristState>(
                builder: (context, state) {
                  if (state is TouristLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is TouristLoaded) {
                    return _buildMap(state);
                  }
                  
                  if (state is DangerZoneAlert) {
                    return _buildMap(TouristLoaded(
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
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SOSScreen(),
              ),
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.emergency, size: 28),
          label: const Text(
            'SOS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(TouristLoaded state) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(34.0837, 74.7973), // Srinagar
        initialZoom: 8.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.smart_tourist_safety',
        ),
        
        // Geo-fence polygons
        PolygonLayer(
          polygons: DemoData.geoFences.map((fence) {
            return Polygon(
              points: fence.coordinates.map((coord) {
                return LatLng(coord.latitude, coord.longitude);
              }).toList(),
              color: fence.type == 'danger' 
                  ? Colors.red.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
              borderColor: fence.type == 'danger' 
                  ? Colors.red
                  : Colors.green,
              borderStrokeWidth: 2.0,
            );
          }).toList(),
        ),
        
        // Tourist cluster markers
        MarkerLayer(
          markers: state.groups.map((group) {
            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(group.lat, group.lng),
              child: GestureDetector(
                onTap: () {
                  _showTouristGroupInfo(group);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: group.status == 'safe' 
                        ? Colors.green 
                        : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    group.status == 'safe' 
                        ? Icons.group 
                        : Icons.warning,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // Current tourist marker
        if (state.currentTourist != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 60.0,
                height: 60.0,
                point: LatLng(
                  state.currentTourist!.lat,
                  state.currentTourist!.lng,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: state.currentTourist!.isInDangerZone 
                        ? Colors.red 
                        : Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showTouristGroupInfo(group) {
    showDialog(
      context: context,
      builder: (context) => TouristInfoPopup(group: group),
    );
  }

  void _showDigitalIdDialog() {
    final currentTourist = DemoData.currentTourist;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digital ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user,
              size: 60,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${currentTourist.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${currentTourist.digitalId}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Blockchain Verified'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDangerAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Text('Safety Alert!'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SOSScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  void _triggerVibration() async {
    // Use haptic feedback instead of vibration package
    HapticFeedback.heavyImpact();
  }
}