import 'dart:ui';

import 'package:flutter/material.dart';

const _deepForest = Color(0xFF071B14);
const _forest = Color(0xFF123B2A);
const _emerald = Color(0xFF55D39B);
const _mint = Color(0xFFB8F5D8);
const _paper = Color(0xFFF4F8F5);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7FBF8),
                    Color(0xFFEAF5EF),
                    Color(0xFFF4F8F5),
                  ],
                ),
              ),
            ),
          ),

          // Ambient green glow
          Positioned(
            top: -180,
            right: -120,
            child: _Glow(
              size: 430,
              color: _emerald.withValues(alpha: .12),
            ),
          ),

          Positioned(
            bottom: -180,
            left: -120,
            child: _Glow(
              size: 400,
              color: const Color(0xFF72B993).withValues(alpha: .08),
            ),
          ),

          // ============================================================
          // MAIN CONTENT
          // ============================================================

          SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  28,
                  98,
                  28,
                  120,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // GREETING
                        // ==================================================

                        const Text(
                          'Good afternoon.',
                          style: TextStyle(
                            color: _deepForest,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'What would you like to work on today?',
                          style: TextStyle(
                            color: _deepForest.withValues(alpha: .58),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // ASK SEQOTIA
                        // ==================================================

                        _AskSeqotiaCard(
                          onTap: () {
                            _showComingSoon(
                              context,
                              'Seqotia AI workspace',
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // QUICK ACTIONS
                        // ==================================================

                        const Text(
                          'Quick actions',
                          style: TextStyle(
                            color: _deepForest,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _QuickActionCard(
                              icon: Icons.upload_file_rounded,
                              title: 'Upload document',
                              subtitle: 'Add a document to Seqotia',
                              onTap: () {
                                _showComingSoon(
                                  context,
                                  'Document upload',
                                );
                              },
                            ),
                            _QuickActionCard(
                              icon: Icons.note_add_rounded,
                              title: 'Create document',
                              subtitle: 'Start a new document',
                              onTap: () {
                                _showComingSoon(
                                  context,
                                  'Create document',
                                );
                              },
                            ),
                            _QuickActionCard(
                              icon: Icons.folder_open_rounded,
                              title: 'Browse documents',
                              subtitle: 'Open your document library',
                              onTap: () {
                                _showComingSoon(
                                  context,
                                  'Document library',
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // RECENT DOCUMENTS
                        // ==================================================

                        Row(
                          children: [
                            const Text(
                              'Recent documents',
                              style: TextStyle(
                                color: _deepForest,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                _showComingSoon(
                                  context,
                                  'All documents',
                                );
                              },
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: _forest,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const _DocumentCard(
                          icon: Icons.description_outlined,
                          title: 'Project Proposal',
                          subtitle: 'Edited today',
                          type: 'DOCX',
                        ),

                        const SizedBox(height: 10),

                        const _DocumentCard(
                          icon: Icons.picture_as_pdf_outlined,
                          title: 'Company Agreement',
                          subtitle: 'Edited yesterday',
                          type: 'PDF',
                        ),

                        const SizedBox(height: 10),

                        const _DocumentCard(
                          icon: Icons.description_outlined,
                          title: 'Meeting Notes',
                          subtitle: 'Edited 3 days ago',
                          type: 'DOCX',
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // FOLDERS
                        // ==================================================

                        const Text(
                          'Folders',
                          style: TextStyle(
                            color: _deepForest,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _FolderCard(
                              name: 'Projects',
                              count: '12 documents',
                            ),
                            _FolderCard(
                              name: 'Work',
                              count: '8 documents',
                            ),
                            _FolderCard(
                              name: 'Personal',
                              count: '5 documents',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // TOP GLASS BAR
          // ============================================================

          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: _HomeTopBar(
              onProfileTap: () {
                _showComingSoon(
                  context,
                  'Profile',
                );
              },
            ),
          ),

          // ============================================================
          // BOTTOM DOCK
          // ============================================================

          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 620,
                ),
                child: const _BottomDock(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(
    BuildContext context,
    String title,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title — coming soon'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

// ========================================================================
// TOP BAR
// ========================================================================

class _HomeTopBar extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const _HomeTopBar({
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: .80),
            ),
            boxShadow: [
              BoxShadow(
                color: _deepForest.withValues(alpha: .08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/ICON.jpg',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 38,
                      height: 38,
                      color: _emerald.withValues(alpha: .15),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: _forest,
                        size: 21,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seqotia',
                    style: TextStyle(
                      color: _deepForest,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'WorkSpace',
                    style: TextStyle(
                      color: _deepForest,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                'Home',
                style: TextStyle(
                  color: _deepForest.withValues(alpha: .58),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 18),

              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _deepForest.withValues(alpha: .06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _deepForest.withValues(alpha: .08),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _deepForest,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// ASK SEQOTIA
// ========================================================================

class _AskSeqotiaCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AskSeqotiaCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _forest.withValues(alpha: .96),
                  _deepForest.withValues(alpha: .98),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: .14),
              ),
              boxShadow: [
                BoxShadow(
                  color: _forest.withValues(alpha: .20),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _mint.withValues(alpha: .12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _mint.withValues(alpha: .24),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: _mint,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask Seqotia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ask anything about your documents or tell Seqotia what to change.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _emerald,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _deepForest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// QUICK ACTION
// ========================================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: .90),
            ),
            boxShadow: [
              BoxShadow(
                color: _deepForest.withValues(alpha: .05),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _emerald.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _forest,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _deepForest,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _deepForest.withValues(alpha: .50),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// DOCUMENT CARD
// ========================================================================

class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String type;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: .92),
        ),
        boxShadow: [
          BoxShadow(
            color: _deepForest.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _forest.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _forest,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _deepForest,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _deepForest.withValues(alpha: .48),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: _forest.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: _forest.withValues(alpha: .72),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 10),

          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// FOLDER CARD
// ========================================================================

class _FolderCard extends StatelessWidget {
  final String name;
  final String count;

  const _FolderCard({
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: .90),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _emerald.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: _forest,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _deepForest,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    color: _deepForest.withValues(alpha: .46),
                    fontSize: 9,
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

// ========================================================================
// BOTTOM DOCK
// ========================================================================

class _BottomDock extends StatelessWidget {
  const _BottomDock();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .76),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: .90),
            ),
            boxShadow: [
              BoxShadow(
                color: _deepForest.withValues(alpha: .10),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DockItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: true,
              ),
              _DockItem(
                icon: Icons.description_outlined,
                label: 'Documents',
              ),
              _DockItem(
                icon: Icons.auto_awesome_rounded,
                label: 'AI',
              ),
              _DockItem(
                icon: Icons.folder_outlined,
                label: 'Projects',
              ),
              _DockItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// DOCK ITEM
// ========================================================================

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _DockItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: active
            ? _emerald.withValues(alpha: .14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? _forest : _deepForest.withValues(alpha: .55),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? _forest
                  : _deepForest.withValues(alpha: .55),
              fontSize: 10,
              fontWeight: active
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// GLOW
// ========================================================================

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}