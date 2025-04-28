import 'package:dio/dio.dart';
import 'package:techgear/dtos/mark_as_read_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/chat/message.dart';

class ChatService {
  final String apiUrl = '/api/v1/chats';
  final DioClient _dioClient;

  ChatService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

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
}
