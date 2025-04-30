import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/chat_user_dto.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ManageChats extends StatefulWidget {
  const ManageChats({super.key});

  @override
  State<ManageChats> createState() => _ManageChatsState();
}

class _ManageChatsState extends State<ManageChats> {
  late ChatProvider _chatProvider;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _chatProvider.fetchChatUsers();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0068FF),
              ),
            )
          : Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0068FF),
                          ),
                          onPressed: () {
                            provider.clearError();
                            _loadInformation();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.chatUsers.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return RefreshIndicator(
                  color: const Color(0xFF0068FF),
                  onRefresh: _loadInformation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.chatUsers.length,
                    itemBuilder: (context, index) {
                      final user = provider.chatUsers[index];
                      return ChatUserCard(user: user);
                    },
                  ),
                );
              },
            ),
    );
  }
}

class ChatUserCard extends StatelessWidget {
  final ChatUserDto user;

  const ChatUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          context.go('/chats/${user.id}', extra: {'userName': user.userName});
        } else {
          context.push('/chats/${user.id}', extra: {'userName': user.userName});
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF0068FF),
              child: Text(
                user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên người dùng và thời gian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Đoạn trích tin nhắn cuối
                  if (user.senderId == 1) ...[
                    Row(
                      children: [
                        Text(
                          "You:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 5),
                        if (user.isImage)
                          Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: Colors.black54,
                                size: 18,
                              ),
                              Text(
                                "Image",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        if (!user.isImage)
                          Text(
                            user.lastMessagePreview!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    )
                  ] else ...[
                    if (user.isImage)
                      Row(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.black54,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Image",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    if (!user.isImage)
                      Text(
                        user.lastMessagePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ]
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(user.lastMessageSentAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (user.unreadMessageCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${user.unreadMessageCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            )
            // Badge tin nhắn chưa đọc
          ],
        ),
      ),
    );
  }
}
