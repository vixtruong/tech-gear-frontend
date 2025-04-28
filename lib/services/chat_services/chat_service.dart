import 'package:dio/dio.dart';
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
      var response = await _dioClient.instance
          .post('$apiUrl/send', data: message.toJson());

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      e.toString();
      return false;
    }
  }
}
