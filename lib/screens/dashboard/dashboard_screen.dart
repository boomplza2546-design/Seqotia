import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../models/dashboard_summary.dart';
import '../../models/workspace_document.dart';
import '../../services/dashboard_service.dart';
import '../../services/workspace_store.dart';

const _deepForest = Color(0xFF071B14);
const _emerald = Color(0xFF55D39B);
const _mint = Color(0xFFB8F5D8);
const _lime = Color(0xFFB8F47A);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary?> summaryFuture = _loadSummary();

  Future<DashboardSummary?> _loadSummary() async {
    final token = await AuthStorage.readToken();
    if (token == null) return null;
    try {
      return await const DashboardService(apiClient: ApiClient())
          .loadSummary(token);
    } catch (error) {
      debugPrint('Dashboard load error: $error');
      return null;
    }
  }

  Future<void> _action(String action) async {
    if (!mounted) return;
    if (action == 'Sign out') {
      await AuthStorage.clear();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
      return;
    }
    if (action == 'Upload Template' || action == 'Upload document') {
      WorkspaceDocument? document;
      try {
        document = await WorkspaceStore.instance.pickDocument();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $error')),
          );
        }
        return;
      }
      if (!mounted || document == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${document.name} added to Documents')),
      );
      setState(() => summaryFuture = _loadSummary());
      await Navigator.pushNamed(context, AppRoutes.documents);
      return;
    }
    final routes = <String, String>{
      'Dashboard': AppRoutes.dashboard,
      'Workspace': AppRoutes.workspace,
      'Template AI': AppRoutes.aiWriter,
      'AI Writer': AppRoutes.aiWriter,
      'Documents': AppRoutes.documents,
      'Projects': AppRoutes.projects,
      'Team Chat': AppRoutes.teamChat,
      'Contacts': AppRoutes.contacts,
      'Settings': AppRoutes.settings,
      'Activity': AppRoutes.activity,
      'More Tools': AppRoutes.tools,
    };
    final route = routes[action];
    if (route != null && route != AppRoutes.dashboard) {
      await Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WorkspaceStore.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _deepForest,
          body: Stack(
            children: [
              const Positioned.fill(child: _DashboardBackground()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 980;
                    return Padding(
                      padding:
                          EdgeInsets.fromLTRB(14, 14, 14, compact ? 86 : 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!compact) ...[
                            SizedBox(
                              width: 238,
                              child: _Sidebar(onAction: _action),
                            ),
                            const SizedBox(width: 14),
                          ],
                          Expanded(
                            child: FutureBuilder<DashboardSummary?>(
                              future: summaryFuture,
                              builder: (context, snapshot) => _DashboardContent(
                                summary: snapshot.data,
                                compact: compact,
                                onAction: _action,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (MediaQuery.sizeOf(context).width < 980)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: _BottomNavigation(onAction: _action),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/forest.png', fit: BoxFit.cover),
        Container(color: Colors.black.withValues(alpha: .22)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: .08),
                Colors.transparent,
                Colors.black.withValues(alpha: .24)
              ],
              stops: const [0, .55, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardSummary? summary;
  final bool compact;
  final Future<void> Function(String action) onAction;

  const _DashboardContent(
      {required this.summary, required this.compact, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final store = WorkspaceStore.instance;
    final documentCount = store.documents.length + (summary?.documents ?? 0);
    final aiJobs = summary?.aiJobs ?? 0;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 14),
          _WelcomeStrip(summary: summary, onAction: onAction),
          const SizedBox(height: 14),
          _StatsGrid(
              documentCount: documentCount, aiJobs: aiJobs, compact: compact),
          const SizedBox(height: 14),
          const _ThemePanel(),
          const SizedBox(height: 14),
          if (compact)
            Column(
              children: [
                _ActivityCard(onAction: onAction),
                const SizedBox(height: 14),
                _PreviewCard(onAction: onAction),
                const SizedBox(height: 14),
                _ToolsCard(onAction: onAction),
              ],
            )
          else
            SizedBox(
              height: 330,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _ActivityCard(onAction: onAction)),
                  const SizedBox(width: 14),
                  Expanded(flex: 6, child: _PreviewCard(onAction: onAction)),
                  const SizedBox(width: 4),
                  Expanded(flex: 4, child: _ToolsCard(onAction: onAction)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          _RecentDocuments(onAction: onAction),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Logo(size: 52),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8)),
              SizedBox(height: 3),
              Text('Your command center for intelligent work',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFE5C77D).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE5C77D).withValues(alpha: .30),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFE5C77D), size: 16),
              SizedBox(width: 7),
              Text('SECURE',
                  style: TextStyle(
                      color: Color(0xFFE5C77D),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeStrip extends StatelessWidget {
  final DashboardSummary? summary;
  final Future<void> Function(String action) onAction;
  const _WelcomeStrip({required this.summary, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _emerald.withValues(alpha: .16),
              shape: BoxShape.circle,
              border: Border.all(color: _emerald.withValues(alpha: .35)),
            ),
            child: const Icon(Icons.waving_hand_rounded, color: _mint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good to see you, ${summary?.userName ?? 'Seqotia User'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                const Text('Everything important is in view.',
                    style: TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => onAction('Upload document'),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New document'),
            style: TextButton.styleFrom(
              foregroundColor: _mint,
              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int documentCount;
  final int aiJobs;
  final bool compact;
  const _StatsGrid(
      {required this.documentCount,
      required this.aiJobs,
      required this.compact});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData(
          Icons.description_outlined, 'Documents', '$documentCount', _mint),
      _StatData(Icons.auto_awesome_outlined, 'AI Processing', '$aiJobs', _mint),
      const _StatData(
          Icons.check_circle_outline, 'Work Status', 'On Track', _lime),
      const _StatData(Icons.battery_5_bar_rounded, 'Workspace', 'Ready', _mint),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: compact ? 1.55 : 1.45,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _StatCard(data: cards[index]),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(data.icon, color: data.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(data.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis))
          ]),
          const Spacer(),
          Text(data.value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WorkspaceStore.instance,
      builder: (context, _) {
        final store = WorkspaceStore.instance;
        return _GlassPanel(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('Theme',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              _ThemeChoice(
                  label: 'Forest',
                  active: store.activeTheme == 'forest',
                  onTap: () => store.setTheme('forest')),
              _ThemeChoice(
                  label: 'Mist',
                  active: store.activeTheme == 'mist',
                  onTap: () => store.setTheme('mist')),
              _ThemeChoice(
                  label: 'Canopy',
                  active: store.activeTheme == 'canopy',
                  onTap: () => store.setTheme('canopy')),
              const Text('Auto Change',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              Switch.adaptive(
                  value: store.autoChangeTheme,
                  onChanged: store.setAutoChangeTheme,
                  activeThumbColor: _emerald),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ThemeChoice(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? _emerald.withValues(alpha: .24)
              : Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _mint : Colors.white12),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? _mint : Colors.white70, fontSize: 10)),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _ActivityCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Uploaded Template',
        'Open document library',
        Icons.description_outlined,
        'Documents'
      ),
      (
        'AI Generated Document',
        'Open AI Writer',
        Icons.auto_awesome_rounded,
        'AI Writer'
      ),
      (
        'Reviewed Document',
        'Open document library',
        Icons.article_outlined,
        'Documents'
      ),
      (
        'Team Chat',
        'Open team chat',
        Icons.chat_bubble_outline_rounded,
        'Team Chat'
      ),
    ];
    return _GlassPanel(
      child: Column(
        children: [
          _SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
              onTap: () => onAction('Activity')),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    leading: Icon(item.$3, color: _mint, size: 19),
                    title: Text(item.$1,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                    subtitle: Text(item.$2,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 9)),
                    onTap: () => onAction(item.$4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _PreviewCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        children: [
          _SectionHeader(
              title: 'Document Preview',
              actionLabel: 'View All',
              onTap: () => onAction('Documents')),
          const SizedBox(height: 8),
          Expanded(
            child: InkWell(
              onTap: () => onAction('Documents'),
              borderRadius: BorderRadius.circular(10),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 220, maxHeight: 245),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Business Proposal',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 16),
                        Expanded(child: _DocumentLines()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentLines extends StatelessWidget {
  const _DocumentLines();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          7,
          (index) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: FractionallySizedBox(
                  widthFactor: .55 + (index % 3) * .13,
                  child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xFFB8DCCE),
                          borderRadius: BorderRadius.circular(4))),
                ),
              )),
    );
  }
}

class _ToolsCard extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _ToolsCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Upload Template', Icons.description_rounded, 'AI Auto Detect'),
      ('AI Writer', Icons.edit_note_rounded, 'Generate Content'),
      ('More Tools', Icons.article_outlined, 'Format Editor'),
      ('More Tools', Icons.translate_rounded, 'Translate'),
    ];
    return _GlassPanel(
      child: Column(
        children: [
          _SectionHeader(
              title: 'Workspace Tools',
              actionLabel: 'More',
              onTap: () => onAction('More Tools')),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: tools.length,
              itemBuilder: (context, index) => _ToolTile(
                title: tools[index].$1 == 'More Tools'
                    ? tools[index].$3
                    : tools[index].$1,
                subtitle: tools[index].$3,
                icon: tools[index].$2,
                onTap: () => onAction(tools[index].$1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDocuments extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _RecentDocuments({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final documents = WorkspaceStore.instance.documents;
    return _GlassPanel(
      child: Column(
        children: [
          _SectionHeader(
              title: 'Workspace - Recent Documents',
              actionLabel: 'View All',
              onTap: () => onAction('Documents')),
          const SizedBox(height: 10),
          SizedBox(
            height: 154,
            child: documents.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Upload a document to see it here.',
                        style: TextStyle(color: Colors.white70, fontSize: 11)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: documents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _DocumentTile(
                      documentName: documents[index].name,
                      extension: documents[index].extension,
                      onTap: () => onAction('Documents'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String documentName;
  final String extension;
  final VoidCallback onTap;
  const _DocumentTile(
      {required this.documentName,
      required this.extension,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(
              child: Icon(Icons.description_rounded, color: _mint, size: 34)),
          Text(documentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          Text(extension,
              style: const TextStyle(color: Colors.white60, fontSize: 9)),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  const _SectionHeader(
      {required this.title, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700))),
      TextButton(
          onPressed: onTap,
          child: Text(actionLabel,
              style: const TextStyle(color: _mint, fontSize: 10))),
    ]);
  }
}

class _Sidebar extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _Sidebar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Dashboard', Icons.home_rounded),
      ('Workspace', Icons.folder_open_outlined),
      ('Template AI', Icons.auto_awesome_outlined),
      ('Documents', Icons.description_outlined),
      ('Projects', Icons.work_outline_rounded),
      ('Team Chat', Icons.chat_bubble_outline_rounded),
      ('Contacts', Icons.people_outline_rounded),
      ('Settings', Icons.settings_outlined),
      ('Sign out', Icons.logout_rounded),
    ];
    return Column(children: [
      Expanded(
        child: _GlassPanel(
          padding: EdgeInsets.zero,
          child: Column(children: [
            const Padding(
                padding: EdgeInsets.all(20),
                child: Row(children: [
                  _Logo(size: 44),
                  SizedBox(width: 10),
                  Text('Seqotia\nWorkSpace',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.25))
                ])),
            Expanded(
                child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: items
                        .map((item) => _NavItem(
                            label: item.$1,
                            icon: item.$2,
                            active: item.$1 == 'Dashboard',
                            onTap: () => onAction(item.$1)))
                        .toList())),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      _GlassPanel(
          child: InkWell(
              onTap: () => onAction('Team Chat'),
              child: const Row(children: [
                Icon(Icons.chat_rounded, color: _mint),
                SizedBox(width: 8),
                Text('Team Chat',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700))
              ]))),
    ]);
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.label,
      required this.icon,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? _emerald.withValues(alpha: .20) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              child: Row(children: [
                Icon(icon, color: active ? _mint : Colors.white70, size: 19),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        style: TextStyle(
                            color: active ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500)))
              ])),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final Future<void> Function(String action) onAction;
  const _BottomNavigation({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _BottomItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            onTap: () => onAction('Dashboard'),
            active: true),
        _BottomItem(
            icon: Icons.folder_open_outlined,
            label: 'Workspace',
            onTap: () => onAction('Workspace')),
        _BottomItem(
            icon: Icons.description_outlined,
            label: 'Documents',
            onTap: () => onAction('Documents')),
        _BottomItem(
            icon: Icons.auto_awesome_outlined,
            label: 'AI Writer',
            onTap: () => onAction('AI Writer')),
        _BottomItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => onAction('Settings')),
      ]),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _BottomItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.active = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onTap,
        tooltip: label,
        icon: Icon(icon, color: active ? _mint : Colors.white70));
  }
}

class _ToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ToolTile(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: _mint),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            Text(subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 7),
                textAlign: TextAlign.center)
          ])),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassPanel(
      {required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .34),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: .16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]),
          child: child,
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final double size;
  const _Logo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
        child: ClipOval(
            child: Image.asset('assets/images/ICON.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.eco_rounded, color: _mint))));
  }
}
