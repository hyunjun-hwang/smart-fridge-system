// FILE: lib/ui/pages/home/notification_modal.dart

import 'package:flutter/material.dart';

class NotificationItem {
  final int id;
  final String title;
  final String timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  // 임시 알림 데이터
  final List<NotificationItem> _notifications = [
    NotificationItem(
        id: 1, title: '냉장고 온도 급상승 감지', timestamp: '06/23 17:51', isRead: false),
    NotificationItem(
        id: 2, title: '얼음 생성 완료', timestamp: '06/23 17:51', isRead: false),
    NotificationItem(
        id: 3, title: '버섯 유통기한 3일 경과', timestamp: '06/23 17:51', isRead: true),
    NotificationItem(
        id: 4, title: '냉장고 가스 점검 필요', timestamp: '06/23 17:51', isRead: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('알림',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text('새로운 알림이 없습니다.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              itemCount: _notifications.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 10, color: Colors.transparent),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return Dismissible(
                  key: ValueKey(item.id), // 각 아이템에 고유한 키 부여
                  direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${item.title} 알림을 삭제했습니다.'),
                          duration: const Duration(seconds: 2)),
                    );
                  },
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: _buildNotificationTile(item),
                );
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCBD6AB),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('닫기',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return GestureDetector(
      onTap: () {
        // 탭하면 읽음 상태로 변경
        if (!item.isRead) {
          setState(() {
            item.isRead = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!item.isRead)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('읽지 않음',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ),
                const SizedBox(height: 4),
                Text(item.timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}