class MarkAsReadDto {
  final int senderId;
  final int receiverId;

  MarkAsReadDto({
    required this.senderId,
    required this.receiverId,
  });

  factory MarkAsReadDto.fromJson(Map<String, dynamic> json) {
    return MarkAsReadDto(
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}
