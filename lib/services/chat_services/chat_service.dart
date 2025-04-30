import 'package:dio/dio.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/environment.dart';
import 'package:techgear/models/chat/message.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert'; // Thêm để parse JSON

class ChatService {
  final String apiUrl = '/api/v1/chats';
  final String wsUrl =
      Environment.wsUrl; // Replace with your backend WebSocket URL
  final DioClient _dioClient;
  WebSocketChannel? _webSocketChannel;
  final StreamController<Message> _messageController =
      StreamController.broadcast();

  ChatService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  // Stream to listen for new messages
  Stream<Message> get messageStream => _messageController.stream;

  // Initialize WebSocket connection
  void connectWebSocket(String userId, String? token) {
    try {
      final uri = token != null
          ? Uri.parse('${Environment.wsUrl}?userId=$userId&token=$token')
          : Uri.parse('${Environment.wsUrl}?userId=$userId');
      print('Attempting to connect to WebSocket: $uri');
      _webSocketChannel = WebSocketChannel.connect(uri);
      print('WebSocket connection initiated');
      _webSocketChannel!.stream.listen(
        (data) {
          print('Received WebSocket data: $data');
          try {
            // Parse chuỗi JSON thành Map
            final messageJson =
                jsonDecode(data as String) as Map<String, dynamic>;
            final message = Message.fromSocketJson(messageJson);
            print('Parsed message: ${message.toString()}');
            _messageController.add(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  // Close WebSocket connection
  void disconnectWebSocket() {
    _webSocketChannel?.sink.close();
    _messageController.close();
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
      final errorMessage = e.response;
      throw Exception(errorMessage);
    }
  }
}
