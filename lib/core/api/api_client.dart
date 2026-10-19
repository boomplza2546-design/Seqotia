import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  const ApiClient();

  // ======================================================================
  // POST
  // ======================================================================

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // ======================================================================
  // GET
  // ======================================================================

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  // ======================================================================
  // PUT
  // ======================================================================

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // ======================================================================
  // DELETE
  // ======================================================================

  Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> upload(
    String path, {
    required String filename,
    required List<int> bytes,
    required String token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}$path'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

    final response = await http.Response.fromStream(await request.send());
    return _handleResponse(response);
  }

  Future<List<int>> getBytes(String path, {String? token}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Export failed (${response.statusCode})');
    }
    return response.bodyBytes;
  }

  // ======================================================================
  // RESPONSE HANDLER
  // ======================================================================

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    final dynamic decodedBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      throw Exception(
        'Invalid response format from server',
      );
    }

    String message = 'Request failed';

    if (decodedBody is Map<String, dynamic>) {
      message = decodedBody['detail']?.toString() ??
          decodedBody['message']?.toString() ??
          message;
    }

    throw ApiException(response.statusCode, message);
  }
}
