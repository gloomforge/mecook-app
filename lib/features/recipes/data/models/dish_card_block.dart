class DishCardBlock {
  final String type;
  final String value;
  final int orderIndex;

  DishCardBlock({
    required this.type,
    required this.value,
    required this.orderIndex,
  });

  factory DishCardBlock.fromJson(Map<String, dynamic> json) {
    return DishCardBlock(
      type: json['type'],
      value: json['value'],
      orderIndex: json['orderIndex'],
    );
  }
}
