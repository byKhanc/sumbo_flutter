import 'package:flutter/material.dart';

class TreasureNotificationDialog extends StatelessWidget {
  final String treasureName;
  final String treasureDescription;
  final double distance;
  final VoidCallback onConfirm;
  final VoidCallback onShowAllList;
  final VoidCallback onCloseAll;

  const TreasureNotificationDialog({
    super.key,
    required this.treasureName,
    required this.treasureDescription,
    required this.distance,
    required this.onConfirm,
    required this.onShowAllList,
    required this.onCloseAll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('보물 발견! 💎'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            treasureName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            treasureDescription,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '거리: ${distance.toStringAsFixed(1)}km',
            style: const TextStyle(
              color: Color(0xFF2563eb),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onShowAllList, child: const Text('전체 목록')),
        TextButton(onPressed: onCloseAll, child: const Text('모두 닫기')),
        TextButton(onPressed: onConfirm, child: const Text('확인')),
      ],
    );
  }
}
