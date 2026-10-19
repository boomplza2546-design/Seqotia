import 'package:flutter/material.dart';

import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/workspace/workspace_screens.dart';

class AppRoutes {
  static const login = '/login';
  static const signUp = '/sign-up';
  static const resetPassword = '/reset-password';
  static const dashboard = '/dashboard';
  static const workspace = '/workspace';
  static const documents = '/documents';
  static const aiWriter = '/ai-writer';
  static const activity = '/activity';
  static const tools = '/tools';
  static const projects = '/projects';
  static const teamChat = '/team-chat';
  static const contacts = '/contacts';
  static const settings = '/settings';

  static final routes = <String, WidgetBuilder>{
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    dashboard: (context) => const DashboardScreen(),
    workspace: (context) => const WorkspaceScreen(),
    documents: (context) => const DocumentsScreen(),
    aiWriter: (context) => const AIWriterScreen(),
    activity: (context) => const ActivityScreen(),
    tools: (context) => const ToolsScreen(),
    projects: (context) => const FeatureScreen(title: 'Projects'),
    teamChat: (context) => const FeatureScreen(title: 'Team Chat'),
    contacts: (context) => const FeatureScreen(title: 'Contacts'),
    settings: (context) => const FeatureScreen(title: 'Settings'),
  };
}
