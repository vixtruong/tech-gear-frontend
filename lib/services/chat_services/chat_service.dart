import 'package:dio/dio.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/environment.dart';
import 'package:techgear/models/chat/message.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert';

class ChatService {
  final String apiUrl = '/api/v1/chats';
  final String wsUrl = Environment.wsUrl;
  final DioClient _dioClient;
  WebSocketChannel? _webSocketChannel;
  final StreamController<Message> _messageController =
      StreamController.broadcast();
  final SessionProvider _sessionProvider;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;

  ChatService(this._sessionProvider) : _dioClient = DioClient(_sessionProvider);

  Stream<Message> get messageStream => _messageController.stream;

  void connectWebSocket(String userId, String? token) {
    _connectWebSocket(userId, token, isReconnect: false);
  }

  void _connectWebSocket(String userId, String? token,
      {required bool isReconnect}) {
    if (_isReconnecting) return;

    try {
      final uri = token != null
          ? Uri.parse('$wsUrl?userId=$userId&token=$token')
          : Uri.parse('$wsUrl?userId=$userId');
      _webSocketChannel = WebSocketChannel.connect(uri);
      print('WebSocket connecting to: $uri');

      _webSocketChannel!.stream.listen(
        (data) {
          try {
            final messageJson =
                jsonDecode(data as String) as Map<String, dynamic>;
            final message = Message.fromSocketJson(messageJson);
            _messageController.add(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) async {
          print('WebSocket error: $error');
          if (!_isReconnecting) {
            await _handleWebSocketError(userId);
          }
        },
        onDone: () async {
          print('WebSocket connection closed');
          if (!_isReconnecting) {
            await _handleWebSocketError(userId);
          }
        },
      );

      if (isReconnect) {
        print('WebSocket reconnected successfully for user $userId');
      }
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _scheduleReconnect(userId);
    }
  }

  Future<void> _handleWebSocketError(String userId) async {
    if (_isReconnecting) return;
    _isReconnecting = true;

    try {
      // Đóng kênh hiện tại nếu còn mở
      _webSocketChannel?.sink.close();

      // Thử làm mới token
      final refreshed = await _dioClient.refreshToken();
      if (refreshed) {
        final newToken = _sessionProvider.accessToken;
        if (newToken != null) {
          _connectWebSocket(userId, newToken, isReconnect: true);
        } else {
          print('No access token available after refresh');
          _scheduleReconnect(userId);
        }
      } else {
        print('Failed to refresh token');
        _scheduleReconnect(userId);
      }
    } catch (e) {
      print('Error handling WebSocket error: $e');
      _scheduleReconnect(userId);
    } finally {
      _isReconnecting = false;
    }
  }

  void _scheduleReconnect(String userId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isReconnecting && _sessionProvider.accessToken != null) {
        _connectWebSocket(userId, _sessionProvider.accessToken,
            isReconnect: true);
      }
    });
  }

  void disconnectWebSocket() {
    _reconnectTimer?.cancel();
    _webSocketChannel?.sink.close();
    _messageController.close();
    print('WebSocket disconnected');
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
      int senderId, int receiverId) async {
    final response =
        await _dioClient.instance.get('$apiUrl/$senderId/$receiverId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<bool> sendMessage(Message message) async {
    try {
      final response = await _dioClient.instance
          .post('$apiUrl/send', data: message.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      throw Exception(
          'Failed to send message: ${response.statusCode} - ${response.data}');
    } on DioException catch (e) {
      final errorMessage = e.response != null
          ? 'Failed to send message: ${e.response!.statusCode} - ${e.response!.data}'
          : 'Network error: ${e.message}';
      print(errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<int> getUnreadMessageCount(int senderId, int receiverId) async {
    try {
      final response = await _dioClient.instance
          .get('$apiUrl/unread-count/$senderId/$receiverId');
      if (response.statusCode == 200) {
        return response.data as int;
      }
      throw Exception(
          'Failed to fetch unread message count: ${response.statusCode}');
    } on DioException catch (e) {
      final errorMessage = e.response != null
          ? 'Error: ${e.response!.statusCode} - ${e.response!.data}'
          : 'Network error: ${e.message}';
      throw Exception('Error fetching unread message count: $errorMessage');
    }
  }

  Future<void> markAsRead(MarkAsReadDto dto) async {
    try {
      await _dioClient.instance
          .post('$apiUrl/mark-as-read', data: dto.toJson());
    } on DioException catch (e) {
      final errorMessage = e.response != null
          ? 'Failed to mark as read: ${e.response!.statusCode} - ${e.response!.data}'
          : 'Network error: ${e.message}';
      print(errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatUsers() async {
    try {
      var response = await _dioClient.instance.get('$apiUrl/users');
      final List data = response.data;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response != null
          ? 'Error: ${e.response!.statusCode} - ${e.response!.data}'
          : 'Network error: ${e.message}';
      throw Exception(errorMessage);
    }
  }
}
