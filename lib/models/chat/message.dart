class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String? content;
  final bool isImage;
  final String? imageUrl;
  final bool isRead;
  final DateTime sentAt;

  Message({
    required this.id,
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
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String?,
      isImage: json['isImage'] as bool,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isImage': isImage,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}
