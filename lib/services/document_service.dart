import '../core/api/api_client.dart';
import '../models/structured_document.dart';

class CreatedStructuredDocument {
  const CreatedStructuredDocument({
    required this.id,
    required this.filename,
    required this.status,
    required this.templateId,
    required this.data,
  });

  final int id;
  final String filename;
  final String status;
  final String templateId;
  final StructuredDocumentData data;

  factory CreatedStructuredDocument.fromJson(Map<String, dynamic> json) =>
      CreatedStructuredDocument(
        id: json['document_id'] as int,
        filename: json['filename'] as String,
        status: json['status'] as String? ?? 'draft',
        templateId: json['template_id'] as String? ?? '',
        data: StructuredDocumentData.fromJson(
            Map<String, dynamic>.from(json['data'] as Map)),
      );
}

class DocumentService {
  const DocumentService({this.apiClient = const ApiClient()});

  final ApiClient apiClient;

  Future<Map<String, dynamic>> uploadFile({
    required String filename,
    required List<int> bytes,
    required String token,
  }) {
    return apiClient.upload(
      '/documents',
      filename: filename,
      bytes: bytes,
      token: token,
    );
  }

  Future<List<int>> exportDocument({
    required int documentId,
    required String format,
    required String token,
  }) {
    return apiClient.getBytes(
      '/documents/$documentId/export?format=$format',
      token: token,
    );
  }

  Future<CreatedStructuredDocument> createStructuredDocument({
    required String filename,
    required DocumentGenerationProposal proposal,
    required String token,
  }) async {
    final response = await apiClient.post(
      '/documents/structured',
      token: token,
      body: {
        'filename': filename,
        'template_id': proposal.templateId,
        'data': proposal.data.toJson(),
      },
    );
    return CreatedStructuredDocument.fromJson(response);
  }

  Future<CreatedStructuredDocument> updateStructuredDocument({
    required int documentId,
    required String templateId,
    required StructuredDocumentData data,
    required String token,
  }) async {
    final response = await apiClient.put(
      '/documents/$documentId/structure',
      token: token,
      body: {
        'template_id': templateId,
        'data': data.toJson(),
      },
    );
    return CreatedStructuredDocument.fromJson(response);
  }
}
