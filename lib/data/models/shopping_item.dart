class ShoppingItem {
  final int id;
  String name;
  bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });
}