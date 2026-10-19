import 'package:flutter/material.dart';

import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/pages/analytics_page.dart';
import '../screens/dashboard/pages/users_page.dart';
import '../screens/dashboard/pages/settings_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String users = '/users';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    analytics: (context) => const AnalyticsPage(),
    users: (context) => const UsersPage(),
    settings: (context) => const SettingsPage(),
  };
}
