import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class UserAddressService {
  final String apiUrl = '/api/v1/addresses';
  final DioClient _dioClient;

  UserAddressService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<Map<String, dynamic>>?> fetchUserAddresses(int userId) async {
    final response = await _dioClient.instance.get('$apiUrl/$userId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> addUserAddress(Map<String, dynamic> dto) async {
    final response = await _dioClient.instance.post('$apiUrl/add', data: dto);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> updateUserAddress(int id, Map<String, dynamic> dto) async {
    await _dioClient.instance.put('$apiUrl/update/$id', data: dto);
  }

  Future<void> deleteUserAddress(int id) async {
    await _dioClient.instance.delete('$apiUrl/$id');
  }
}
