import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tourist_bloc.dart';
import '../models/demo_data.dart';

class SafetyScoreWidget extends StatelessWidget {
  const SafetyScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TouristBloc, TouristState>(
      builder: (context, state) {
        String safetyStatus = 'Calculating...';
        Color statusColor = Colors.grey;
        IconData statusIcon = Icons.help_outline;
        
        if (state is TouristLoaded && state.currentTourist != null) {
          if (state.currentTourist!.isInDangerZone) {
            safetyStatus = 'Risky Area';
            statusColor = Colors.red;
            statusIcon = Icons.warning;
          } else {
            safetyStatus = 'Safe Zone';
            statusColor = Colors.green;
            statusIcon = Icons.security;
          }
        } else if (state is DangerZoneAlert) {
          safetyStatus = 'Risky Area';
          statusColor = Colors.red;
          statusIcon = Icons.warning;
        }

        // Count safe vs alert groups for overall safety score
        final safeGroups = DemoData.touristGroups.where((g) => g.status == 'safe').length;
        final totalGroups = DemoData.touristGroups.length;
        final safetyPercentage = ((safeGroups / totalGroups) * 100).round();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.1),
                statusColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            safetyStatus,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Live',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Region Safety',
                      '$safetyPercentage%',
                      safetyPercentage >= 70 ? Colors.green : Colors.orange,
                      Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Tourist Groups',
                      '$safeGroups/$totalGroups Safe',
                      Colors.blue,
                      Icons.groups_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}