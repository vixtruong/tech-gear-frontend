import 'package:flutter/material.dart';
import 'package:techgear/dtos/chat_user_dto.dart';
import 'package:techgear/models/chat/message.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/services/chat_services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  List<Message> _messages = [];
  List<ChatUserDto> _chatUsers = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  bool _isSupportScreenActive = false;
  bool _isDisposed = false;

  ChatProvider(SessionProvider sessionProvider)
      : _chatService = ChatService(sessionProvider) {
    _chatService.messageStream.listen((message) {
      if (!_isDisposed &&
          !_messages.any((m) => m.id == message.id && m.id != null)) {
        _messages.add(message);

        sessionProvider.loadSession();
        final userId = sessionProvider.userId;
        if (userId != null) {
          final currentUserId = int.parse(userId);
          final userIndex = _chatUsers.indexWhere((user) =>
              user.id == message.senderId || user.id == message.receiverId);
          if (userIndex != -1) {
            final updatedUser = _chatUsers[userIndex].copyWith(
              lastMessagePreview: message.isImage ? "Image" : message.content,
              lastMessageSentAt: message.sentAt,
              isImage: message.isImage,
              senderId: message.senderId,
            );
            _chatUsers = List.from(_chatUsers);
            _chatUsers[userIndex] = updatedUser;
            _updateUnreadCount(message.senderId, currentUserId);
          }

          if (_isSupportScreenActive) {
            markAsRead(MarkAsReadDto(
              senderId: message.senderId,
              receiverId: currentUserId,
            ));
          }
        }
        if (!_isDisposed) notifyListeners();
      }
    });
  }

  List<Message> get messages => _messages;
  List<ChatUserDto> get chatUsers => _chatUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get isSupportScreenActive => _isSupportScreenActive;

  void setSupportScreenActive(bool active) {
    _isSupportScreenActive = active;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _updateUnreadCount(int senderId, int receiverId) async {
    try {
      final newUnreadCount =
          await _chatService.getUnreadMessageCount(senderId, receiverId);
      final userIndex = _chatUsers
          .indexWhere((user) => user.id == senderId || user.id == receiverId);
      if (userIndex != -1) {
        _chatUsers[userIndex] =
            _chatUsers[userIndex].copyWith(unreadMessageCount: newUnreadCount);
        _chatUsers = List.from(_chatUsers);
      }
      _unreadCount = newUnreadCount;
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }

  void connectWebSocket(String userId, String? accessToken) {
    _chatService.connectWebSocket(userId, accessToken);
  }

  void disconnectWebSocket() {
    _chatService.disconnectWebSocket();
  }

  Future<void> fetchMessages(int senderId, int receiverId) async {
    _isLoading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();

    try {
      final List<Map<String, dynamic>> data =
          await _chatService.fetchMessages(senderId, receiverId);
      final newMessages = data.map((e) => Message.fromJson(e)).toList();

      // Replace the existing messages with the new ones
      _messages = newMessages..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<bool> sendMessage(Message message) async {
    if (!_isDisposed) notifyListeners();

    try {
      final success = await _chatService.sendMessage(message);
      if (!success) {
        _messages.remove(message);
        _error = 'Failed to send message';
        if (!_isDisposed) notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _messages.remove(message);
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(MarkAsReadDto dto) async {
    try {
      await _chatService.markAsRead(dto);
      await fetchUnreadMessageCount(dto.senderId, dto.receiverId);
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> fetchUnreadMessageCount(int senderId, int receiverId) async {
    try {
      final newUnreadCount =
          await _chatService.getUnreadMessageCount(senderId, receiverId);
      if (_unreadCount != newUnreadCount) {
        _unreadCount = newUnreadCount;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> fetchChatUsers() async {
    try {
      var data = await _chatService.fetchChatUsers();
      _chatUsers = data.map((item) => ChatUserDto.fromJson(item)).toList();
    } catch (e) {
      _error = e.toString();
      print(_error);
    }
    if (!_isDisposed) notifyListeners();
  }

  void clearError() {
    _error = null;
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _chatService.dispose(); // Ensure ChatService resources are cleaned up
    super.dispose();
  }
}
