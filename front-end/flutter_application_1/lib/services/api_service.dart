import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.5.82:5000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<dynamic>> getContatos() async {
    try {
      final response = await _dio.get('/contacts/');
      return response.data;
    } catch (e) {
      print("ERROR>>>>>>>${e}");
      throw Exception('Erro ao conectar na API: $e');
    }
  }
  Future<Map<String, dynamic>> getContatosById(int id) async {
    try {
      final response = await _dio.get('/contacts/$id');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<List<dynamic>> showAllCalls() async {
    try {
      final response = await _dio.get('/calls/');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await _dio.get('/contacts/favorites');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<Map<String, dynamic>> createCall(int idContact, int duration) async {
    try {
      final response = await _dio.post(
        '/calls/',
        data: {'idContact': idContact, 'duration': duration},
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<Map<String, dynamic>> deleteCall(int id) async {
    try {
      final response = await _dio.delete('/calls/$id');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<Map<String, dynamic>> createContact(
    String name,
    String? photoUrl,
    List<Map<String, String>> phones,
    int categoryId,
    bool isFavorite,
  ) async {
    try {
      final response = await _dio.post('/contacts/', data: {
          'name': name,
          'photoUrl': photoUrl ?? '',
          'phones': phones,
          'isFavorite': isFavorite,
          'categoryId': categoryId,
        });
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<Map<String, dynamic>> editContact(
    int id,
    String name,
    String? photoUrl,
    List<Map<String, String>> phones,
    int categoryId,
    bool isFavorite,
  ) async {
    try {
      final response = await _dio.put('/contacts/$id', data: {
          'name': name,
          'photoUrl': photoUrl ?? '',
          'phones': phones,
          'isFavorite': isFavorite,
          'categoryId': categoryId,
        });
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }

  Future<void> deleteContacts(int id) async {
    try {
      final response = await _dio.delete('/contacts/$id');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao conectar na API: $e');
    }
  }
}
