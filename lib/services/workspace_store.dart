import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/workspace_document.dart';
import '../models/structured_document.dart';
import '../core/storage/auth_storage.dart';
import 'document_service.dart';

class WorkspaceStore extends ChangeNotifier {
  WorkspaceStore._();

  static final WorkspaceStore instance = WorkspaceStore._();

  final List<WorkspaceDocument> _documents = [];
  final DocumentService _documentService = const DocumentService();
  String _activeTheme = 'forest';
  bool _autoChangeTheme = false;

  List<WorkspaceDocument> get documents => List.unmodifiable(_documents);
  String get activeTheme => _activeTheme;
  bool get autoChangeTheme => _autoChangeTheme;

  Future<WorkspaceDocument?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'docx',
        'doc',
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'txt',
        'md'
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final name = file.name;
    final extension =
        name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE';
    final token = await AuthStorage.readToken();
    var serverId = 0;
    var serverStatus = 'local';
    if (token != null && file.bytes != null) {
      final response = await _documentService.uploadFile(
        filename: name,
        bytes: file.bytes!,
        token: token,
      );
      serverId = response['id'] as int? ?? 0;
      serverStatus = response['status'] as String? ?? 'ready';
    }

    final document = WorkspaceDocument(
      id: serverId == 0 ? null : serverId,
      name: name,
      extension: extension,
      sizeBytes: file.size,
      createdAt: DateTime.now(),
      path: file.path,
      content: file.bytes == null ? null : String.fromCharCodes(file.bytes!),
      status: serverStatus,
    );
    _documents.insert(0, document);
    notifyListeners();
    return document;
  }

  void addGeneratedDocument(String name, String content) {
    _documents.insert(
      0,
      WorkspaceDocument(
        name: name,
        extension: 'DOCX',
        sizeBytes: content.length,
        createdAt: DateTime.now(),
        content: content,
      ),
    );
    notifyListeners();
  }

  void renameDocument(WorkspaceDocument document, String name) {
    _replace(
        document, document.copyWith(name: name, updatedAt: DateTime.now()));
  }

  void duplicateDocument(WorkspaceDocument document) {
    _documents.insert(
      0,
      WorkspaceDocument(
        name:
            '${document.name.replaceFirst(RegExp(r'\.[^.]+$'), '')} copy.${document.extension.toLowerCase()}',
        extension: document.extension,
        sizeBytes: document.sizeBytes,
        createdAt: DateTime.now(),
        path: document.path,
        content: document.content,
        status: 'draft',
        templateId: document.templateId,
        structuredData: document.structuredData,
      ),
    );
    notifyListeners();
  }

  void setArchived(WorkspaceDocument document, bool archived) {
    _replace(document,
        document.copyWith(archived: archived, updatedAt: DateTime.now()));
  }

  void setFavorite(WorkspaceDocument document, bool favorite) {
    _replace(document,
        document.copyWith(favorite: favorite, updatedAt: DateTime.now()));
  }

  void deleteDocument(WorkspaceDocument document) {
    _documents.remove(document);
    notifyListeners();
  }

  void _replace(WorkspaceDocument oldDocument, WorkspaceDocument newDocument) {
    final index = _documents.indexOf(oldDocument);
    if (index == -1) return;
    _documents[index] = newDocument;
    notifyListeners();
  }

  void addStructuredDocument({
    required int id,
    required String name,
    required String status,
    required String templateId,
    required StructuredDocumentData data,
  }) {
    _documents.removeWhere((document) => document.id == id);
    _documents.insert(
      0,
      WorkspaceDocument(
        id: id,
        name: name,
        extension: 'DOCX',
        sizeBytes: data.previewText.length,
        createdAt: DateTime.now(),
        content: data.previewText,
        status: status,
        templateId: templateId,
        structuredData: data,
      ),
    );
    notifyListeners();
  }

  void setTheme(String theme) {
    _activeTheme = theme;
    notifyListeners();
  }

  void setAutoChangeTheme(bool value) {
    _autoChangeTheme = value;
    notifyListeners();
  }
}
