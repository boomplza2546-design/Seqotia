import '../core/api/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final ApiClient apiClient;

  const DashboardService({
    required this.apiClient,
  });

  Future<DashboardSummary> loadSummary(String token) async {
    final response = await apiClient.get(
      '/dashboard/summary',
      token: token,
    );
    return DashboardSummary.fromJson(response);
  }
}
