import 'package:flutter/material.dart';
import '../models/demo_data.dart';
import '../models/tourist_models.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: DemoData.sosAlerts.length + _getMockAlerts().length,
        itemBuilder: (context, index) {
          if (index < DemoData.sosAlerts.length) {
            return _buildSOSAlertCard(DemoData.sosAlerts[index]);
          } else {
            final mockAlerts = _getMockAlerts();
            return _buildSystemAlertCard(mockAlerts[index - DemoData.sosAlerts.length]);
          }
        },
      ),
    );
  }

  Widget _buildSOSAlertCard(SOSAlert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.status == 'active' ? Colors.red : Colors.green,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emergency,
                    color: alert.status == 'active' ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SOS Alert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: alert.status == 'active' ? Colors.red : Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.status == 'active' ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Tourist: ${alert.touristName}'),
              Text('Location: ${alert.lat.toStringAsFixed(4)}, ${alert.lng.toStringAsFixed(4)}'),
              Text('Time: ${_formatTime(alert.timestamp)}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String;
    final color = _getSeverityColor(severity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(alert['icon'] as IconData, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      severity.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert['description'] as String,
                style: const TextStyle(fontSize: 14),
              ),
              if (alert['recommendation'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💡 ${alert['recommendation']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockAlerts() {
    return [
      {
        'title': 'Weather Alert - Gulmarg',
        'description': 'Heavy snowfall expected. Visibility may be reduced.',
        'severity': 'high',
        'icon': Icons.cloud_queue,
        'recommendation': 'Avoid outdoor activities and stay in safe accommodations.',
      },
      {
        'title': 'Road Closure - Srinagar-Leh Highway',
        'description': 'Temporary closure due to landslide clearance.',
        'severity': 'medium',
        'icon': Icons.block,
        'recommendation': 'Use alternative routes and check with local authorities.',
      },
      {
        'title': 'Tourist Congestion - Dal Lake',
        'description': 'High tourist activity reported in the area.',
        'severity': 'low',
        'icon': Icons.people,
        'recommendation': 'Consider visiting during off-peak hours.',
      },
      {
        'title': 'Medical Facility Update',
        'description': 'New medical camp established near Pahalgam.',
        'severity': 'info',
        'icon': Icons.local_hospital,
        'recommendation': 'Emergency medical services now available 24/7.',
      },
    ];
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      case 'info':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
