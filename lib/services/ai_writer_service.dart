import '../core/api/api_client.dart';
import '../models/structured_document.dart';

class AIWriterService {
  const AIWriterService({this.apiClient = const ApiClient()});

  final ApiClient apiClient;

  Future<DocumentGenerationProposal> generateDraft({
    required String prompt,
    required String token,
  }) async {
    final response = await apiClient.post(
      '/ai/generate',
      token: token,
      body: {'prompt': prompt},
    );
    return DocumentGenerationProposal.fromJson(response);
  }
}
