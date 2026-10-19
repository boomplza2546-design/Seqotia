import 'package:flutter/foundation.dart';

import 'layout_service.dart';
import 'navigation_service.dart';


class WorkspaceService extends ChangeNotifier {
  final LayoutService layout;
  final NavigationService navigation;

  bool _initialized = false;

  WorkspaceService({
    required this.layout,
    required this.navigation,
  }) {
    layout.addListener(notifyListeners);
    navigation.addListener(notifyListeners);
  }

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await Future.wait([
      layout.load(),
      navigation.initialize(),
    ]);

    _initialized = true;

    notifyListeners();
  }

  Future<void> saveWorkspace() async {
    await Future.wait([
      layout.save(),
      navigation.save(),
    ]);
  }

  void registerDefaultCards() {
    layout.registerCard(
      id: 'welcome',
      x: 32,
      y: 32,
      width: 420,
      height: 240,
    );

    layout.registerCard(
      id: 'documents',
      x: 480,
      y: 32,
      width: 420,
      height: 320,
    );

    layout.registerCard(
      id: 'ai',
      x: 32,
      y: 300,
      width: 420,
      height: 300,
    );
  }

  void resetWorkspace() {
    layout.reset();

    navigation.reset();

    notifyListeners();
  }

  @override
  void dispose() {
    layout.removeListener(notifyListeners);
    navigation.removeListener(notifyListeners);

    layout.dispose();
    navigation.dispose();

    super.dispose();
  }
}