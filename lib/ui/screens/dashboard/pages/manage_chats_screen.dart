import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/chat_user_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ManageChats extends StatefulWidget {
  const ManageChats({super.key});

  @override
  State<ManageChats> createState() => _ManageChatsState();
}

class _ManageChatsState extends State<ManageChats> {
  late ChatProvider _chatProvider;
  late SessionProvider _sessionProvider;
  bool _isLoading = true;
  bool _isWebSocketConnected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _chatProvider.fetchChatUsers();
      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;
      final accessToken = _sessionProvider.accessToken;

      if (userId != null) {
        if (!_isWebSocketConnected) {
          _chatProvider.connectWebSocket(userId, accessToken);
          _isWebSocketConnected = true;
        }
      }
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
  void dispose() {
    _chatProvider.disconnectWebSocket();
    _isWebSocketConnected = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    key: ValueKey(provider.chatUsers
                        .length), // Đảm bảo ListView rebuild khi danh sách thay đổi
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.chatUsers.length,
                    itemBuilder: (context, index) {
                      final user = provider.chatUsers[index];
                      return ChatUserCard(
                        key: ValueKey(
                            user.id), // Đảm bảo mỗi item có key duy nhất
                        user: user,
                      );
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

  // List of colors that contrast well with white text
  static const List<Color> _avatarColors = [
    Color(0xFF0068FF), // Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF388E3C), // Green
    Color(0xFF7B1FA2), // Purple
    Color(0xFFF57C00), // Orange
    Color(0xFF0288D1), // Light Blue
    Color(0xFFC2185B), // Pink
    Color(0xFF00796B), // Teal
    Color(0xFF8E24AA), // Deep Purple
    Color(0xFF455A64), // Blue Grey
  ];

  // Get a consistent color based on user ID
  Color _getAvatarColor() {
    final index = user.id.hashCode.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

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
            CircleAvatar(
              radius: 20,
              backgroundColor: _getAvatarColor(),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  if (user.senderId == 1) ...[
                    Row(
                      children: [
                        const Text(
                          "You:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (user.isImage)
                          Row(
                            children: const [
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
                            user.lastMessagePreview ?? '',
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
                        children: const [
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
                        user.lastMessagePreview ?? '',
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
          ],
        ),
      ),
    );
  }
}
