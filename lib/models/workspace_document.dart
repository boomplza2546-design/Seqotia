import 'structured_document.dart';

class WorkspaceDocument {
  final int? id;
  final String name;
  final String extension;
  final int sizeBytes;
  final DateTime createdAt;
  final String? path;
  final String? content;
  final String status;
  final String? templateId;
  final StructuredDocumentData? structuredData;
  final bool archived;
  final bool favorite;
  final DateTime? updatedAt;

  const WorkspaceDocument({
    this.id,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.createdAt,
    this.path,
    this.content,
    this.status = 'ready',
    this.templateId,
    this.structuredData,
    this.archived = false,
    this.favorite = false,
    this.updatedAt,
  });

  WorkspaceDocument copyWith({
    String? name,
    String? status,
    bool? archived,
    bool? favorite,
    DateTime? updatedAt,
  }) {
    return WorkspaceDocument(
      id: id,
      name: name ?? this.name,
      extension: extension,
      sizeBytes: sizeBytes,
      createdAt: createdAt,
      path: path,
      content: content,
      status: status ?? this.status,
      templateId: templateId,
      structuredData: structuredData,
      archived: archived ?? this.archived,
      favorite: favorite ?? this.favorite,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
