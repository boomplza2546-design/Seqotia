import 'package:flutter/material.dart';

import '../../models/workspace_document.dart';
import '../../core/storage/auth_storage.dart';
import '../../services/document_service.dart';
import '../../services/workspace_store.dart';
import '../../services/ai_writer_service.dart';
import '../../models/structured_document.dart';

const _forest = Color(0xFF071B14);
const _emerald = Color(0xFF55D39B);
const _mint = Color(0xFFB8F5D8);

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturePage(
      title: 'Workspace',
      icon: Icons.folder_open_outlined,
      child: _WorkspaceHomeContent(),
    );
  }
}

class _WorkspaceHomeContent extends StatelessWidget {
  const _WorkspaceHomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your document workspace',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
            'Upload a document, generate a draft, or open your recent files.'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionButton(
              icon: Icons.upload_file_rounded,
              label: 'Upload document',
              onPressed: () => Navigator.pushNamed(context, '/documents'),
            ),
            _ActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'Open AI Writer',
              onPressed: () => Navigator.pushNamed(context, '/ai-writer'),
            ),
            _ActionButton(
              icon: Icons.description_outlined,
              label: 'Browse documents',
              onPressed: () => Navigator.pushNamed(context, '/documents'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AnimatedBuilder(
          animation: WorkspaceStore.instance,
          builder: (context, _) => Text(
            '${WorkspaceStore.instance.documents.length} documents in this session',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _typeFilter = 'All types';
  String _statusFilter = 'All status';
  String _sort = 'Recent';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkspaceDocument> _visibleDocuments(List<WorkspaceDocument> input) {
    final query = _searchController.text.trim().toLowerCase();
    final result = input.where((document) {
      final matchesQuery =
          query.isEmpty || document.name.toLowerCase().contains(query);
      final matchesType =
          _typeFilter == 'All types' || document.extension == _typeFilter;
      final matchesStatus =
          _statusFilter == 'All status' || document.status == _statusFilter;
      final matchesArchive =
          _statusFilter == 'archived' ? document.archived : !document.archived;
      return matchesQuery && matchesType && matchesStatus && matchesArchive;
    }).toList();
    result.sort((a, b) => _sort == 'Name'
        ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
        : b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WorkspaceStore.instance,
      builder: (context, _) {
        final allDocuments = WorkspaceStore.instance.documents;
        final documents = _visibleDocuments(allDocuments);
        return _FeaturePage(
          title: 'Documents',
          icon: Icons.description_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionButton(
                    icon: Icons.upload_file_rounded,
                    label: 'Upload document',
                    onPressed: _upload,
                  ),
                  _ActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Create with AI',
                    onPressed: () => Navigator.pushNamed(context, '/ai-writer'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search documents',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear)),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _FilterMenu(
                      label: _typeFilter,
                      values: const [
                        'All types',
                        'DOCX',
                        'PDF',
                        'PNG',
                        'JPG',
                        'TXT'
                      ],
                      onSelected: (value) =>
                          setState(() => _typeFilter = value)),
                  _FilterMenu(
                      label: _statusFilter,
                      values: const ['All status', 'ready', 'draft', 'local'],
                      onSelected: (value) =>
                          setState(() => _statusFilter = value)),
                  _FilterMenu(
                      label: 'Sort: $_sort',
                      values: const ['Recent', 'Name'],
                      onSelected: (value) => setState(() => _sort = value)),
                  TextButton.icon(
                      onPressed: () =>
                          setState(() => _statusFilter = 'archived'),
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('Archived')),
                ],
              ),
              const SizedBox(height: 18),
              if (allDocuments.isEmpty)
                const Text(
                    'No documents yet. Upload a DOCX, PDF, or image file to begin.')
              else if (documents.isEmpty)
                const Text('No documents match these filters.')
              else
                ...documents.map(
                  (document) => _DocumentTile(
                      document: document, onChanged: () => setState(() {})),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _upload() async {
    try {
      final document = await WorkspaceStore.instance.pickDocument();
      if (mounted && document != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${document.name} added to Documents')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $error')));
      }
    }
  }
}

class DocumentViewerScreen extends StatelessWidget {
  final WorkspaceDocument? document;

  const DocumentViewerScreen({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    final structuredData = document?.structuredData;
    return _FeaturePage(
      title: document?.name ?? 'Document viewer',
      icon: Icons.article_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (structuredData != null) ...[
            Text(
              '${structuredData.documentType.label} · ${document!.status}',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, color: _forest),
            ),
            const SizedBox(height: 12),
          ],
          SelectableText(
            document?.content?.isNotEmpty == true
                ? document!.content!
                : 'This document is ready for AI analysis and editing.',
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final format in const ['pdf', 'docx', 'png', 'jpg'])
                _ExportButton(document: document, format: format),
            ],
          ),
          if (structuredData != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StructuredDocumentEditorScreen(document: document!),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit document fields'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExportButton extends StatefulWidget {
  final WorkspaceDocument? document;
  final String format;

  const _ExportButton({required this.document, required this.format});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _exporting = false;

  Future<void> _export() async {
    final documentId = widget.document?.id;
    final token = await AuthStorage.readToken();
    if (!mounted) return;
    if (documentId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sign in and save this document before exporting.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      final bytes = await const DocumentService().exportDocument(
        documentId: documentId,
        format: widget.format,
        token: token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${widget.format.toUpperCase()} ready (${bytes.length} bytes)')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _exporting ? null : _export,
      icon: _exporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.download_outlined),
      label: Text(
          _exporting ? 'Exporting…' : 'Export ${widget.format.toUpperCase()}'),
    );
  }
}

class StructuredDocumentEditorScreen extends StatefulWidget {
  const StructuredDocumentEditorScreen({super.key, required this.document});

  final WorkspaceDocument document;

  @override
  State<StructuredDocumentEditorScreen> createState() =>
      _StructuredDocumentEditorScreenState();
}

class _StructuredDocumentEditorScreenState
    extends State<StructuredDocumentEditorScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _dateController = TextEditingController();
  final _companyController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  final _documentService = const DocumentService();
  String? _error;
  bool _saving = false;

  StructuredDocumentData get _original => widget.document.structuredData!;

  @override
  void initState() {
    super.initState();
    _titleController.text = _original.title ?? '';
    _numberController.text = _original.documentNumber ?? '';
    _dateController.text = _original.issueDate ?? '';
    _companyController.text = _original.company?.name ?? '';
    _supplierController.text = _original.supplier?.name ?? '';
    _notesController.text = _original.notes ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _dateController.dispose();
    _companyController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  DocumentParty? _partyWithName(DocumentParty? original, String? name) {
    if (name == null && original == null) return null;
    return DocumentParty(
      name: name,
      taxId: original?.taxId,
      email: original?.email,
      phone: original?.phone,
    );
  }

  StructuredDocumentData _editedData() => StructuredDocumentData(
        documentType: _original.documentType,
        title: _optional(_titleController),
        documentNumber: _optional(_numberController),
        issueDate: _optional(_dateController),
        dueDate: _original.dueDate,
        referenceNumber: _original.referenceNumber,
        company:
            _partyWithName(_original.company, _optional(_companyController)),
        supplier:
            _partyWithName(_original.supplier, _optional(_supplierController)),
        customer: _original.customer,
        lineItems: _original.lineItems,
        currency: _original.currency,
        paymentTerms: _original.paymentTerms,
        notes: _optional(_notesController),
      );

  Future<void> _save() async {
    final documentId = widget.document.id;
    final templateId = widget.document.templateId;
    final token = await AuthStorage.readToken();
    if (documentId == null || templateId == null || token == null) {
      setState(() =>
          _error = 'Unable to save this draft. Please sign in and try again.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await _documentService.updateStructuredDocument(
        documentId: documentId,
        templateId: templateId,
        data: _editedData(),
        token: token,
      );
      WorkspaceStore.instance.addStructuredDocument(
        id: updated.id,
        name: updated.filename,
        status: updated.status,
        templateId: updated.templateId,
        data: updated.data,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Structured document updated')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeaturePage(
      title: 'Edit ${_original.documentType.label}',
      icon: Icons.edit_document,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update the semantic fields. Seqotia recalculates and validates the document on save.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Document title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _numberController,
            decoration: const InputDecoration(
                labelText: 'Document number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Issue date (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _companyController,
            decoration: const InputDecoration(
                labelText: 'Your company', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supplierController,
            decoration: const InputDecoration(
                labelText: 'Supplier', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Notes', border: OutlineInputBorder()),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 16),
          _ActionButton(
            icon: Icons.save_outlined,
            label: _saving ? 'Saving…' : 'Save and validate',
            onPressed: _saving ? () {} : () => _save(),
          ),
        ],
      ),
    );
  }
}

class AIWriterScreen extends StatefulWidget {
  const AIWriterScreen({super.key});

  @override
  State<AIWriterScreen> createState() => _AIWriterScreenState();
}

class _AIWriterScreenState extends State<AIWriterScreen> {
  final promptController = TextEditingController();
  final AIWriterService aiWriterService = const AIWriterService();
  final DocumentService documentService = const DocumentService();
  DocumentGenerationProposal? proposal;
  String? errorMessage;
  bool isGenerating = false;
  bool isSaving = false;

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;
    final token = await AuthStorage.readToken();
    if (token == null) {
      setState(() => errorMessage = 'Sign in to generate a document proposal.');
      return;
    }
    setState(() {
      isGenerating = true;
      errorMessage = null;
      proposal = null;
    });
    try {
      final draft = await aiWriterService.generateDraft(
        prompt: prompt,
        token: token,
      );
      if (mounted) setState(() => proposal = draft);
    } catch (error) {
      if (mounted) setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Future<void> _saveProposal() async {
    final draft = proposal;
    if (draft == null) return;
    final token = await AuthStorage.readToken();
    if (token == null) {
      setState(() =>
          errorMessage = 'Your session has expired. Please sign in again.');
      return;
    }
    setState(() {
      isSaving = true;
      errorMessage = null;
    });
    try {
      final created = await documentService.createStructuredDocument(
        filename: '${draft.data.title ?? draft.data.documentType.label}.docx',
        proposal: draft,
        token: token,
      );
      WorkspaceStore.instance.addStructuredDocument(
        id: created.id,
        name: created.filename,
        status: created.status,
        templateId: created.templateId,
        data: created.data,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document draft saved to Workspace')),
      );
      await Navigator.pushNamed(context, '/documents');
    } catch (error) {
      if (mounted) setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeaturePage(
      title: 'AI Writer',
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: promptController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What should Seqotia write?',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          _ActionButton(
            icon: Icons.auto_awesome,
            label: isGenerating ? 'Generating…' : 'Generate proposal',
            onPressed: isGenerating ? () {} : _generate,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(errorMessage!,
                style: const TextStyle(color: Colors.redAccent)),
          ],
          if (proposal != null) ...[
            const SizedBox(height: 22),
            _ProposalCard(proposal: proposal!),
            const SizedBox(height: 14),
            _ActionButton(
              icon: Icons.save_outlined,
              label: isSaving ? 'Saving…' : 'Save reviewed draft',
              onPressed: isSaving ? () {} : () => _saveProposal(),
            ),
          ],
        ],
      ),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturePage(
      title: 'Activity',
      icon: Icons.history_rounded,
      child: _ActivityContent(),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  const _ActivityContent();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WorkspaceStore.instance,
      builder: (context, _) {
        final documents = WorkspaceStore.instance.documents;
        if (documents.isEmpty) {
          return const Text(
              'No activity yet. Upload a document or create an AI draft to begin.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent activity',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...documents.map(
              (document) => ListTile(
                leading:
                    const Icon(Icons.check_circle_outline, color: _emerald),
                title: Text(document.name),
                subtitle: Text('Added ${document.createdAt}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DocumentViewerScreen(document: document)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _FeaturePage(
      title: 'Workspace Tools',
      icon: Icons.build_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tools',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload Template',
                  onPressed: () => Navigator.pushNamed(context, '/documents')),
              _ActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Writer',
                  onPressed: () => Navigator.pushNamed(context, '/ai-writer')),
              _ActionButton(
                  icon: Icons.translate_rounded,
                  label: 'Translate',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Select text in a document to translate it.')))),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureScreen extends StatelessWidget {
  final String title;
  const FeatureScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return _FeaturePage(
      title: title,
      icon: _featureIcon(title),
      child: _FeatureContent(title: title),
    );
  }

  static IconData _featureIcon(String title) {
    switch (title) {
      case 'Projects':
        return Icons.work_outline_rounded;
      case 'Team Chat':
        return Icons.chat_bubble_outline_rounded;
      case 'Contacts':
        return Icons.people_outline_rounded;
      case 'Settings':
        return Icons.settings_outlined;
      default:
        return Icons.apps_outlined;
    }
  }
}

class _FeatureContent extends StatelessWidget {
  final String title;
  const _FeatureContent({required this.title});

  @override
  Widget build(BuildContext context) {
    if (title == 'Settings') {
      return AnimatedBuilder(
        animation: WorkspaceStore.instance,
        builder: (context, _) => SwitchListTile(
          title: const Text('Auto change theme'),
          subtitle: const Text('Allow Seqotia to rotate workspace themes.'),
          value: WorkspaceStore.instance.autoChangeTheme,
          onChanged: WorkspaceStore.instance.setAutoChangeTheme,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('$title is ready for your workspace.'),
        const SizedBox(height: 22),
        _ActionButton(
          icon: Icons.add_rounded,
          label: title == 'Team Chat' ? 'Start a conversation' : 'Create new',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title item created')),
          ),
        ),
      ],
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const _FeaturePage({required this.title, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _forest,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/forest.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.28),
            ),
          ),
          Positioned.fill(
              child: Container(color: _forest.withValues(alpha: .72))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      if (icon != null) ...[
                        Icon(icon, color: _mint),
                        const SizedBox(width: 10)
                      ],
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800))),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/dashboard', (route) => false),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Dashboard'),
                        style: TextButton.styleFrom(foregroundColor: _mint),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minHeight: 500, maxWidth: 1180),
                      child: _GlassSurface(child: child),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  final Widget child;
  const _GlassSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .34),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .24),
              blurRadius: 28,
              offset: const Offset(0, 14))
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: child,
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final WorkspaceDocument document;
  final VoidCallback onChanged;
  const _DocumentTile({required this.document, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          document.favorite ? Icons.star_rounded : Icons.description_outlined,
          color: document.favorite ? Colors.amber : _emerald,
        ),
        title: Text(document.name),
        subtitle: Text(
          '${document.structuredData?.documentType.label ?? document.extension}'
          '  •  ${document.status}  •  ${document.sizeBytes} bytes',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, action),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(
              value: 'favorite',
              child: Text(document.favorite ? 'Remove favorite' : 'Favorite'),
            ),
            PopupMenuItem(
              value: 'archive',
              child: Text(document.archived ? 'Unarchive' : 'Archive'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DocumentViewerScreen(document: document)),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final store = WorkspaceStore.instance;
    switch (action) {
      case 'rename':
        final controller = TextEditingController(text: document.name);
        final name = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rename document'),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: const Text('Save')),
            ],
          ),
        );
        controller.dispose();
        if (name != null && name.isNotEmpty) {
          store.renameDocument(document, name);
        }
      case 'duplicate':
        store.duplicateDocument(document);
      case 'favorite':
        store.setFavorite(document, !document.favorite);
      case 'archive':
        store.setArchived(document, !document.archived);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete document?'),
            content: Text(
                'Delete ${document.name}? This removes it from the current workspace.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete')),
            ],
          ),
        );
        if (confirmed == true) store.deleteDocument(document);
    }
    onChanged();
  }
}

class _FilterMenu extends StatelessWidget {
  final String label;
  final List<String> values;
  final ValueChanged<String> onSelected;

  const _FilterMenu(
      {required this.label, required this.values, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => values
          .map((value) => PopupMenuItem(value: value, child: Text(value)))
          .toList(),
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.tune_rounded),
        label: Text(label),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.proposal});

  final DocumentGenerationProposal proposal;

  @override
  Widget build(BuildContext context) {
    final errors = proposal.issues.where((issue) => issue.severity == 'error');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _mint.withValues(alpha: .2),
        border: Border.all(color: _emerald.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${proposal.data.documentType.label} proposal',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(proposal.explanation),
          const SizedBox(height: 12),
          SelectableText(proposal.data.previewText),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Needs your review before export',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            ...errors.map((issue) => Text('• ${issue.message}')),
          ],
          const SizedBox(height: 10),
          Text(
            'Confidence ${(proposal.confidence * 100).round()}% · Saving keeps this as a draft until required fields are complete.',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _ActionButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
          backgroundColor: _emerald, foregroundColor: _forest),
    );
  }
}
