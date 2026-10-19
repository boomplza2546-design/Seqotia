import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/storage/auth_storage.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/login/login_screen.dart';
import '../services/auth_service.dart';
import 'routes.dart';

const _paper = Color(0xFFF8FAF8);
const _forest = Color.fromRGBO(36, 218, 142, 1);

class SeqotiaApp extends StatefulWidget {
  const SeqotiaApp({super.key});

  @override
  State<SeqotiaApp> createState() => _SeqotiaAppState();
}

class _SeqotiaAppState extends State<SeqotiaApp> {
  late final Future<Widget> _initialScreenFuture;

  @override
  void initState() {
    super.initState();
    _initialScreenFuture = _resolveInitialScreen();
  }

  Future<Widget> _resolveInitialScreen() async {
    final token = await AuthStorage.readToken();
    if (token == null || token.isEmpty) {
      return const LoginScreen();
    }

    try {
      await const AuthService(apiClient: ApiClient()).getCurrentUser(token);
      return const DashboardScreen();
    } catch (error) {
      if (error is ApiException &&
          (error.statusCode == 401 || error.statusCode == 403)) {
        await AuthStorage.clear();
        return const LoginScreen();
      }
      return const _SessionUnavailableScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seqotia',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _paper,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: _forest),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _initialScreenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}

class _SessionUnavailableScreen extends StatelessWidget {
  const _SessionUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seqotia is temporarily unavailable.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Continue to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
