import '../core/api/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  const AuthService({
    required this.apiClient,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) {
    return apiClient.post(
      '/auth/password-reset/request',
      body: {'email': email},
    );
  }

  Future<Map<String, dynamic>> confirmPasswordReset({
    required String token,
    required String password,
  }) {
    return apiClient.post(
      '/auth/password-reset/confirm',
      body: {
        'token': token,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) {
    return apiClient.get(
      '/auth/me',
      token: token,
    );
  }
}

