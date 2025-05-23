import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/variant_value.dart';

class VariantValueService {
  final String apiUrl = '/api/v1/variationoptions';
  final DioClient _dioClient;

  VariantValueService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  /// Lấy tất cả variant values
  Future<List<Map<String, dynamic>>> fetchVariantValues() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Lấy variant value theo ID
  Future<Map<String, dynamic>?> fetchVariantValueById(String id) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Lấy variant value theo tên
  Future<Map<String, dynamic>?> fetchVariantValueByName(String name) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/by-value/$name');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Lấy danh sách variant value theo variationId
  Future<List<Map<String, dynamic>>> fetchVariantValuesByOptionId(
      String optionId) async {
    final response =
        await _dioClient.instance.get('$apiUrl/by-variationId/$optionId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Thêm variant value mới
  Future<void> addVariantValue(VariantValue value) async {
    final body = {
      'value': value.name,
      'variationId': int.parse(value.variantOptionId),
    };

    final response = await _dioClient.instance.post('$apiUrl/add', data: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add variant value');
    }
  }

  /// Xoá variant value
  Future<void> deleteVariantValue(String id) async {
    final response = await _dioClient.instance.delete('$apiUrl/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete variant value');
    }
  }
}
