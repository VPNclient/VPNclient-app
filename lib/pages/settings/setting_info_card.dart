import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';

class SettingInfoCard extends StatelessWidget {
  final bool isConnected;
  final String connectionStatus;
  final String supportStatus;
  final String userId;

  const SettingInfoCard({
    super.key,
    required this.isConnected,
    required this.connectionStatus,
    required this.supportStatus,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                LocalizationService.to('about_app'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          _buildSettingRow(
            LocalizationService.to('version'),
            'v 1.0',
            Colors.orange,
          ),
          _buildSettingRow(
            LocalizationService.to('connection'),
            isConnected
                ? connectionStatus
                : LocalizationService.to('not_connected'),
            isConnected ? Colors.orange : Colors.red,
          ),
          _buildSettingRow(
            LocalizationService.to('support'),
            isConnected ? supportStatus : LocalizationService.to('unavailable'),
            isConnected ? Colors.orange : Colors.grey,
          ),
          _buildSettingRow(
            LocalizationService.to('your_id'),
            isConnected ? userId : '—',
            isConnected ? Colors.grey[600]! : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
