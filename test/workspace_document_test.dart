import 'package:flutter_test/flutter_test.dart';
import 'package:seqotia/models/workspace_document.dart';

void main() {
  test('workspace document keeps import metadata', () {
    final document = WorkspaceDocument(
      id: 7,
      name: 'proposal.docx',
      extension: 'DOCX',
      sizeBytes: 128,
      createdAt: DateTime(2026, 9, 21),
      status: 'ready',
    );

    expect(document.id, 7);
    expect(document.extension, 'DOCX');
    expect(document.status, 'ready');
  });
}
