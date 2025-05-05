import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/models/chat/message.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';
import 'package:techgear/services/cloudinary/cloudinary_service.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  late ChatProvider _chatProvider;
  late SessionProvider _sessionProvider;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  XFile? _selectedImage;
  bool _isSending = false;
  bool _isSendEnabled = false;

  String? userId;
  bool _isLoading = true;
  bool _isWebSocketConnected = false;

  StreamSubscription<int>? _routeSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadInformation();

    // Đăng ký lắng nghe Stream trong lần đầu tiên
    if (_routeSubscription == null) {
      final navigationProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      _routeSubscription = navigationProvider.routeChanges.listen((index) {
        if (index == 2 && !_isLoading) {
          _loadInformation();
        }
      });
    }
  }

  Future<void> _loadInformation({bool forceReload = false}) async {
    setState(() {
      _isLoading = true;
      _isWebSocketConnected = false;
    });
    try {
      await _sessionProvider.loadSession();
      userId = _sessionProvider.userId;
      final accessToken = _sessionProvider.accessToken;

      if (userId != null) {
        if (!_isWebSocketConnected) {
          _chatProvider.connectWebSocket(userId!, accessToken);
          _isWebSocketConnected = true;
        }
        await _chatProvider.fetchMessages(int.parse(userId!), 1);
        await _chatProvider.markAsRead(
            MarkAsReadDto(senderId: 1, receiverId: int.parse(userId!)));
      }

      _chatProvider.setSupportScreenActive(true);

      setState(() {
        _isLoading = false;
      });

      // Cuộn xuống cuối sau khi tải tin nhắn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading information: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    _chatProvider.setSupportScreenActive(false);
    if (_isWebSocketConnected) {
      try {
        _chatProvider.disconnectWebSocket();
      } catch (e) {
        print('Error disconnecting WebSocket: $e');
      }
      _isWebSocketConnected = false;
    }

    _messageController.dispose();
    _scrollController.dispose();
    _isWebSocketConnected = false;
    _chatProvider.dispose();
    super.dispose();
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Color(0xFF0088CC)),
                  title: const Text('Select from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                        _isSendEnabled = true;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (userId == null) return;

    final senderId = int.parse(userId!);
    final receiverId = 1;
    final content = _messageController.text.trim();

    if (content.isEmpty && _selectedImage == null) return;

    setState(() {
      _isSending = true;
    });

    bool hasError = false;

    try {
      if (_selectedImage != null) {
        final cloudService = CloudinaryService();
        final imageUrl = await cloudService.uploadImage(_selectedImage!);
        if (imageUrl != null) {
          final imageMessage = Message(
            id: null,
            senderId: senderId,
            receiverId: receiverId,
            content: "Image message",
            isImage: true,
            imageUrl: imageUrl,
            isRead: false,
            sentAt: DateTime.now(),
          );
          final result = await _chatProvider.sendMessage(imageMessage);
          if (!result) hasError = true;
        } else {
          if (!mounted) return;
          hasError = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }

      if (content.isNotEmpty) {
        final textMessage = Message(
          id: null,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          isImage: false,
          imageUrl: null,
          isRead: false,
          sentAt: DateTime.now(),
        );
        final result = await _chatProvider.sendMessage(textMessage);
        if (!result) hasError = true;
      }

      if (!hasError) {
        setState(() {
          _messageController.clear();
          _selectedImage = null;
          _isSendEnabled = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _groupMessagesByDate(List<Message> messages) {
    if (messages.isEmpty) return [];

    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    List<Map<String, dynamic>> groupedMessages = [];
    DateTime? currentDate;
    List<Message> currentGroup = [];

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    for (var message in messages) {
      final messageDate = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );

      if (currentDate == null || messageDate != currentDate) {
        if (currentGroup.isNotEmpty) {
          groupedMessages.add({
            'date': currentDate,
            'messages': List<Message>.from(currentGroup),
          });
          currentGroup.clear();
        }
        currentDate = messageDate;
      }
      currentGroup.add(message);
    }

    if (currentGroup.isNotEmpty) {
      groupedMessages.add({
        'date': currentDate,
        'messages': List<Message>.from(currentGroup),
      });
    }

    return groupedMessages.map((group) {
      final date = group['date'] as DateTime;
      String label;
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        label = 'Today';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(date);
      }
      return {
        'dateLabel': label,
        'messages': group['messages'] as List<Message>,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 800;
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        // Tự động cuộn xuống cuối khi danh sách tin nhắn thay đổi
        if (chatProvider.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final currentPosition = _scrollController.position.pixels;
              final maxScrollExtent =
                  _scrollController.position.maxScrollExtent;
              // Chỉ cuộn nếu người dùng đang ở gần cuối danh sách
              if ((maxScrollExtent - currentPosition).abs() < 200) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              'Support Center',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : userId == null
                  ? Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Please log in to be supported.",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Login Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        color: isWeb ? Colors.white : null,
                        width: isWeb
                            ? MediaQuery.of(context).size.width * 0.5
                            : double.infinity,
                        child: Column(
                          children: [
                            Expanded(
                              child: chatProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : chatProvider.error != null
                                      ? Center(
                                          child: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    'Error: ${chatProvider.error}'),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    chatProvider.clearError();
                                                    _loadInformation(
                                                        forceReload: true);
                                                  },
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          controller: _scrollController,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          itemCount: _groupMessagesByDate(
                                                  chatProvider.messages)
                                              .length,
                                          itemBuilder: (context, groupIndex) {
                                            final group = _groupMessagesByDate(
                                                chatProvider
                                                    .messages)[groupIndex];
                                            final dateLabel =
                                                group['dateLabel'] as String;
                                            final messages = group['messages']
                                                as List<Message>;

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    dateLabel,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                                ...messages.map((message) {
                                                  final isSentByUser = message
                                                          .senderId ==
                                                      int.parse(userId ?? '0');
                                                  return _buildMessageBubble(
                                                      message, isSentByUser);
                                                }),
                                              ],
                                            );
                                          },
                                        ),
                            ),
                            if (_selectedImage != null) _buildImagePreview(),
                            _buildInputArea(),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSentByUser ? const Color(0xFF0088CC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: isSentByUser ? Radius.zero : const Radius.circular(12),
            bottomLeft: isSentByUser ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isImage && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              Text(
                message.content ?? '',
                style: TextStyle(
                  color: isSentByUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.sentAt),
              style: TextStyle(
                color: isSentByUser ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[300],
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    _selectedImage!.path,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(_selectedImage!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 20),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _isSendEnabled = _messageController.text.trim().isNotEmpty;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            onPressed: _showImagePickerBottomSheet,
            icon: const Icon(Icons.image, color: Color(0xFF0088CC)),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _isSendEnabled =
                      value.trim().isNotEmpty || _selectedImage != null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending || !_isSendEnabled ? null : _sendMessage,
            icon: _isSending
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Icon(
                    Icons.send,
                    color:
                        _isSendEnabled ? const Color(0xFF0088CC) : Colors.grey,
                  ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
