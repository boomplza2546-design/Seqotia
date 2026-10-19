import 'package:flutter/material.dart';

import '../../screens/login/top_glass_bar.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool showTopBar = true;

  void _handleScroll(ScrollNotification notification) {
    // We only care about actual scroll updates.
    if (notification is! ScrollUpdateNotification) {
      return;
    }

    final double delta = notification.scrollDelta ?? 0;

    // ------------------------------------------------------------
    // SCROLL DOWN
    // Positive delta = content moves up / user scrolls down
    // ------------------------------------------------------------
    if (delta > 6 && showTopBar) {
      setState(() {
        showTopBar = false;
      });
      return;
    }

    // ------------------------------------------------------------
    // SCROLL UP
    // Negative delta = content moves down / user scrolls up
    // ------------------------------------------------------------
    if (delta < -6 && !showTopBar) {
      setState(() {
        showTopBar = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================================
          // PAGE CONTENT
          // ==========================================================

          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _handleScroll(notification);

              // Let the notification continue to bubble.
              return false;
            },
            child: widget.child,
          ),

          // ==========================================================
          // TOP GLASS BAR
          // ==========================================================

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            top: showTopBar ? 14 : -90,
            left: 14,
            right: 14,
            child: const TopGlassBar(
              userName: 'Narin',
              status: 'Logged On',
            ),
          ),
        ],
      ),
    );
  }
}