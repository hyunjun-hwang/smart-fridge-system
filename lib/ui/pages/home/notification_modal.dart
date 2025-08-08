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
  final List<NotificationItem> _notifications = [
    NotificationItem(id: 1, title: '냉장고 온도 급상승 감지', timestamp: '08/04 23:00', isRead: false),
    NotificationItem(id: 2, title: '얼음 생성 완료', timestamp: '08/04 22:51', isRead: false),
    NotificationItem(id: 3, title: '새로운 레시피 추천: 두부 김치', timestamp: '08/04 21:30', isRead: false),
    NotificationItem(id: 4, title: '버섯 유통기한 3일 경과', timestamp: '08/04 17:51', isRead: true),
    NotificationItem(id: 5, title: '냉장고 가스 점검 필요', timestamp: '08/03 11:12', isRead: true),
    NotificationItem(id: 6, title: '계란 재고 부족', timestamp: '08/03 09:00', isRead: true),
    NotificationItem(id: 7, title: '스마트 제상 기능 작동 완료', timestamp: '08/02 18:00', isRead: true),
    NotificationItem(id: 8, title: '우유 유통기한 임박', timestamp: '08/02 15:25', isRead: true),
  ];

  void _deleteNotification(NotificationItem item) {
    setState(() {
      _notifications.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} 알림을 삭제했습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 모달의 높이가 내용에 맞게 조절되도록 유지
        children: [
          const Text('알림',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Flexible(
            child: _notifications.isEmpty
                ? const Center( // 알림이 없을 경우 중앙에 텍스트 표시
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('새로운 알림이 없습니다.'),
              ),
            )
                : ListView.separated(
              shrinkWrap: true, // Flexible과 함께 사용하여 내용만큼 크기 조절
              itemCount: _notifications.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 10, color: Colors.transparent),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _buildNotificationTile(item);
              },
            ),
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
        if (!item.isRead) {
          setState(() {
            item.isRead = true;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      item.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              onPressed: () => _deleteNotification(item),
              tooltip: '삭제',
            ),
          ],
        ),
      ),
    );
  }
}