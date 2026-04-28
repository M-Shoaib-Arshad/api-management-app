import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<User>> fetchUsers() async {
    final uri = Uri.parse('$_baseUrl/users');
    try {
      final response = await _client.get(uri);
      return _parseUsers(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to connect to the server. Check your internet connection.');
    }
  }

  Future<User> fetchUser(int id) async {
    final uri = Uri.parse('$_baseUrl/users/$id');
    try {
      final response = await _client.get(uri);
      return _parseUser(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to connect to the server. Check your internet connection.');
    }
  }

  List<User> _parseUsers(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      _statusMessage(response.statusCode),
      statusCode: response.statusCode,
    );
  }

  User _parseUser(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(json);
    }
    throw ApiException(
      _statusMessage(response.statusCode),
      statusCode: response.statusCode,
    );
  }

  String _statusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'Unexpected error (HTTP $statusCode).';
    }
  }

  void dispose() => _client.close();
}
