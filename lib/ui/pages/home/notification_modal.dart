import 'package:flutter/material.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final List<Map<String, dynamic>> _notifications = [
    {"msg": "냉장고 온도 급상승 감지", "read": false},
    {"msg": "버섯 유통기한 3일 경과", "read": false},
    {"msg": "얼음 생성 완료", "read": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("알림", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._notifications.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Dismissible(
              key: Key(item["msg"]),
              direction: DismissDirection.startToEnd,
              onDismissed: (_) => setState(() => _notifications.removeAt(i)),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                title: Text(
                  item["msg"],
                  style: TextStyle(
                    fontWeight: item["read"] ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: const Text("07/23 13:24"),
              ),
            );
          }),
        ],
      ),
    );
  }
}