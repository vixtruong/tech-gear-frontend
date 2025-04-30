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

  ChatProvider(SessionProvider sessionProvider)
      : _chatService = ChatService(sessionProvider) {
    _chatService.messageStream.listen((message) {
      // Kiểm tra xem tin nhắn đã tồn tại chưa
      if (!_messages.any((m) => m.id == message.id && m.id != null)) {
        notifyListeners();
      }
    });
  }

  List<Message> get messages => _messages;
  List<ChatUserDto> get chatUsers => _chatUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void connectWebSocket(String userId, String? accessToken) {
    _chatService.connectWebSocket(userId, accessToken);
  }

  void disconnectWebSocket() {
    _chatService.disconnectWebSocket();
  }

  Future<void> fetchMessages(int senderId, int receiverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data =
          await _chatService.fetchMessages(senderId, receiverId);
      final newMessages = data.map((e) => Message.fromJson(e)).toList();

      // Đồng bộ tin nhắn: chỉ thêm tin nhắn chưa có trong _messages
      final updatedMessages = [..._messages];
      for (var newMessage in newMessages) {
        if (!updatedMessages
            .any((m) => m.id == newMessage.id && m.id != null)) {
          updatedMessages.add(newMessage);
        }
      }
      // Sắp xếp theo thời gian gửi
      updatedMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      _messages = updatedMessages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(Message message) async {
    _messages.add(message);
    notifyListeners();

    try {
      final success = await _chatService.sendMessage(message);
      if (!success) {
        _messages.remove(message);
        _error = 'Failed to send message';
        notifyListeners();
        return false;
      }
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

  Future<void> fetchChatUsers() async {
    try {
      var data = await _chatService.fetchChatUsers();

      _chatUsers = data.map((item) => ChatUserDto.fromJson(item)).toList();
    } catch (e) {
      _error = e.toString();
      print(_error);
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
