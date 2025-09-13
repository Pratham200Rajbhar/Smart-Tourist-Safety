import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/demo_data.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  bool _isSharingEnabled = true;
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Mom',
      'phone': '+91 98765 43210',
      'relation': 'Mother',
      'isSharing': true,
    },
    {
      'name': 'Dad',
      'phone': '+91 98765 43211',
      'relation': 'Father',
      'isSharing': true,
    },
    {
      'name': 'Emergency Contact',
      'phone': '+91 98765 43212',
      'relation': 'Friend',
      'isSharing': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Sharing'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isSharingEnabled ? Icons.share_location : Icons.location_off,
              color: _isSharingEnabled ? Colors.white : Colors.red,
            ),
            onPressed: _toggleSharing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Privacy Notice',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Only selected contacts can see your location and safety status. You can disable sharing at any time.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Live Location Map
            if (_isSharingEnabled) ...[
              const Text(
                'Live Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        DemoData.currentTourist.lat,
                        DemoData.currentTourist.lng,
                      ),
                      initialZoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_tourist_safety',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(
                              DemoData.currentTourist.lat,
                              DemoData.currentTourist.lng,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, "0")}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Location sharing is disabled',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Emergency Contacts
            const Text(
              'Shared with Contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            for (int i = 0; i < _emergencyContacts.length; i++)
              _buildContactCard(_emergencyContacts[i], i),
            
            const SizedBox(height: 16),
            
            // Add Contact Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addContact,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Emergency Contact'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // SOS History
            const Text(
              'SOS History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (DemoData.sosAlerts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No emergency alerts triggered. You\'re safe!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final alert in DemoData.sosAlerts.take(3))
                _buildSOSHistoryCard(alert),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: contact['isSharing'] ? Colors.green : Colors.grey,
          child: Text(
            contact['name'][0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(contact['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact['phone']),
            Text(
              contact['relation'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: contact['isSharing'],
          onChanged: (value) {
            setState(() {
              _emergencyContacts[index]['isSharing'] = value;
            });
          },
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSOSHistoryCard(alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.emergency,
          color: alert.status == 'active' ? Colors.red : Colors.green,
        ),
        title: Text('SOS Alert'),
        subtitle: Text(
          '${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year} at ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, "0")}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: alert.status == 'active' ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            alert.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSharing() {
    setState(() {
      _isSharingEnabled = !_isSharingEnabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSharingEnabled 
              ? 'Family sharing enabled' 
              : 'Family sharing disabled',
        ),
        backgroundColor: _isSharingEnabled ? Colors.green : Colors.orange,
      ),
    );
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Relation',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency contact added'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}