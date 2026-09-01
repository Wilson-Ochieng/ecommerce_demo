import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/root_screen.dart';
import 'package:test_app/ui/screens/admin/admin_screen.dart';
import 'package:test_app/ui/screens/auth/login_screen.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';

class AuthStartupScreen extends StatefulWidget {
  const AuthStartupScreen({super.key});

  @override
  State<AuthStartupScreen> createState() => _AuthStartupScreenState();
}

class _AuthStartupScreenState extends State<AuthStartupScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStartupViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStartupViewModel>(
      builder: (context, viewModel, child) {
        // ======================================================
        // CHECKING AUTHENTICATION
        // ======================================================

        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ======================================================
        // NOT AUTHENTICATED
        // ======================================================

        if (!viewModel.isAuthenticated) {
          return const LoginScreen();
        }

        // ======================================================
        // ADMIN
        // ======================================================

        if (viewModel.isAdmin) {
          return const AdminScreen();
        }

        // ======================================================
        // CUSTOMER
        // ======================================================

        return const RootsScreen();
      },
    );
  }
}
