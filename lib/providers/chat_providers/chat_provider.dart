import 'package:flutter/material.dart';
import 'package:techgear/models/chat/message.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/services/chat_services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  ChatProvider(SessionProvider sessionProvider)
      : _chatService = ChatService(sessionProvider);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> fetchMessages(int senderId, int receiverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data =
          await _chatService.fetchMessages(senderId, receiverId);
      _messages = data.map((e) => Message.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(Message message) async {
    _messages.add(message); // Optimistic update
    notifyListeners();

    try {
      final success = await _chatService.sendMessage(message);
      if (!success) {
        _messages.remove(message);
        _error = 'Failed to send message';
        notifyListeners();
        return false;
      }
      // Refresh unread count after sending
      await fetchUnreadMessageCount(message.senderId, message.receiverId);
      return true;
    } catch (e) {
      _messages.remove(message);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(MarkAsReadDto dto) async {
    try {
      await _chatService.markAsRead(dto);
      await fetchUnreadMessageCount(dto.senderId, dto.receiverId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchUnreadMessageCount(int senderId, int receiverId) async {
    try {
      final newUnreadCount =
          await _chatService.getUnreadMessageCount(senderId, receiverId);
      if (_unreadCount != newUnreadCount) {
        _unreadCount = newUnreadCount;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
