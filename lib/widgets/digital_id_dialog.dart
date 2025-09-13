import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/demo_data.dart';
import '../models/tourist_models.dart';

class DigitalIdDialog extends StatelessWidget {
  final Tourist tourist;
  final VoidCallback? onRegenerate;
  final VoidCallback? onShare; // Mock share action

  const DigitalIdDialog({super.key, required this.tourist, this.onRegenerate, this.onShare});

  bool get hasDigitalId => tourist.digitalId.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.verified_user, color: Colors.green.shade600),
            const SizedBox(width: 8),
          const Text('Digital Tourist ID'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white, Colors.green.shade50]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text('Name: ${tourist.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Internal ID: ${tourist.id}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  const Divider(height: 24),
                  if (hasDigitalId) ...[
                    QrImageView(
                      data: tourist.digitalId,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tourist.digitalId,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Blockchain Verified (mock)', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ] else ...[
                    const Icon(Icons.qr_code_2, size: 90, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No Digital ID yet', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Generate one to enable secure identification.', style: TextStyle(color: Colors.grey.shade700, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (!hasDigitalId && onRegenerate != null)
                  ElevatedButton.icon(
                    onPressed: onRegenerate,
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Generate ID'),
                  ),
                if (hasDigitalId && onShare != null)
                  OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: Colors.green.shade600)),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    final tourist = DemoData.getCurrentTourist();
    showDialog(
      context: context,
      builder: (ctx) => DigitalIdDialog(
        tourist: tourist,
        onRegenerate: () {
          // Mock regenerate: create timestamp-based ID
            final newId = 'BLK-CHAIN-${DateTime.now().millisecondsSinceEpoch}';
          DemoData.currentTourist = tourist.copyWith(digitalId: newId);
          Navigator.pop(ctx);
          // Reopen to reflect new data
          Future.microtask(() => DigitalIdDialog.show(context));
        },
        onShare: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock share: Digital ID copied')), // Replace with real share later
          );
        },
      ),
    );
  }
}
