class ChatUserDto {
  final int id;
  final String userName;
  final String? lastMessagePreview;
  final bool isImage;
  final int senderId;
  final int unreadMessageCount;
  final DateTime lastMessageSentAt;

  ChatUserDto({
    required this.id,
    required this.userName,
    this.lastMessagePreview,
    required this.isImage,
    required this.senderId,
    required this.unreadMessageCount,
    required this.lastMessageSentAt,
  });

  factory ChatUserDto.fromJson(Map<String, dynamic> json) {
    return ChatUserDto(
      id: json['id'] as int,
      userName: json['userName'] as String,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      isImage: json['isImage'] as bool,
      senderId: json['senderId'] as int,
      unreadMessageCount: json['unreadMessageCount'] as int,
      lastMessageSentAt: DateTime.parse(json['lastMessageSentAt'] as String),
    );
  }
}
