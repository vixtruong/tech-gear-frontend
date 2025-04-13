class Brand {
  final String id;
  final String name;

  const Brand({
    required this.id,
    required this.name,
  });

  factory Brand.fromMap(Map<String, dynamic> data) {
    return Brand(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
    );
  }
}
