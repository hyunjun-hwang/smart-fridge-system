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