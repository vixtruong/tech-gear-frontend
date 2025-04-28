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
      id: json['id'] as int?,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String?, // Map backend 'message' to content
      isImage: json['isImage'] as bool,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool,
      sentAt: DateTime.parse(json['sentAt'] as String),
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
