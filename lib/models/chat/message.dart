class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final String? content; // Keep content internally
  final bool isImage;
  final String? imageUrl;
  final bool isRead;
  final DateTime sentAt;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    required this.isImage,
    this.imageUrl,
    required this.isRead,
    required this.sentAt,
  });

  // fromJson
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String?, // Map backend 'message' to content
      isImage: json['isImage'] as bool,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  factory Message.fromSocketJson(Map<String, dynamic> json) {
    return Message(
      id: json['Id'] as int?, // Sử dụng 'Id' thay vì 'id'
      senderId: json['SenderId'] as int, // Sử dụng 'SenderId'
      receiverId: json['ReceiverId'] as int, // Sử dụng 'ReceiverId'
      content: json['Content'] as String?, // Sử dụng 'Content'
      isImage: json['IsImage'] as bool,
      imageUrl: json['ImageUrl'] as String?,
      isRead: json['IsRead'] as bool,
      sentAt: DateTime.parse(json['SentAt'] as String),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'Id': id, // Use capital 'Id' to match C# property
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Content': content, // Map content to backend 'Message'
      'IsImage': isImage,
      'ImageUrl': imageUrl,
      'IsRead': isRead,
      'SentAt': sentAt.toIso8601String(),
    };
  }
}
