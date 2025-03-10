class Brand {
  final String id;
  final String name;

  const Brand({
    required this.id,
    required this.name,
  });

  factory Brand.fromMap(Map<String, dynamic> data, String documentId) {
    return Brand(
      id: documentId,
      name: data['name'] ?? '',
    );
  }
}
