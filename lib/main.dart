import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/theme_data.dart';
import 'package:test_app/data/repositories/product_repository.dart';
import 'package:test_app/data/services/cloudinary_service.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/providers/UserProvider.dart';
import 'package:test_app/root_screen.dart';
import 'package:test_app/ui/screens/auth/login_screen.dart';
import 'package:test_app/ui/screens/auth/signup_screen.dart';
import 'package:test_app/ui/screens/auth/startup_screen.dart';
import 'package:test_app/ui/screens/home_screen.dart';
import 'package:test_app/ui/screens/profilescreen.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/login_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/register_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/user_management_viewmodel.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // ==========================================================
        // THEME
        // ==========================================================
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // ==========================================================
        // USER PROVIDER
        // ==========================================================
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // ==========================================================
        // AUTH REPOSITORY
        // ==========================================================
        Provider<AuthRepository>(create: (_) => AuthRepository()),

        // ==========================================================
        // LOGIN VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) =>
              LoginViewModel(authRepository: context.read<AuthRepository>()),
        ),

        // ==========================================================
        // REGISTER VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) =>
              RegisterViewModel(authRepository: context.read<AuthRepository>()),
        ),

        // ==========================================================
        // AUTH STARTUP VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<AuthStartupViewModel>(
          create: (context) => AuthStartupViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        // ==========================================================
        // USER MANAGEMENT VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<UserManagementViewModel>(
          create: (context) => UserManagementViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        // ==========================================================
        // PRODUCT REPOSITORY
        // ==========================================================
        Provider<ProductRepository>(create: (_) => ProductRepository()),

        // ==========================================================
        // CLOUDINARY SERVICE
        // ==========================================================
        Provider<CloudinaryService>(create: (_) => CloudinaryService()),

        // ==========================================================
        // PRODUCT VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
            productRepository: context.read<ProductRepository>(),
            cloudinaryService: context.read<CloudinaryService>(),
          ),
        ),

        // ==========================================================
        // CATEGORY REPOSITORY
        // ==========================================================
        Provider<CategoryRepository>(create: (_) => CategoryRepository()),

        // ==========================================================
        // CATEGORY VIEW MODEL
        // ==========================================================
        ChangeNotifierProvider<CategoryViewModel>(
          create: (context) =>
              CategoryViewModel(repository: context.read<CategoryRepository>()),
        ),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTHeme,
              context: context,
            ),

            home: const AuthStartupScreen(),

            routes: {
              LoginScreen.routName: (context) => const LoginScreen(),

              RegisterScreen.routName: (context) => const RegisterScreen(),

              RootsScreen.routName: (context) => const RootsScreen(),

              Profilescreen.routName: (context) => const Profilescreen(),

              HomeScreen.routName: (context) => const HomeScreen(),
            },
          );
        },
      ),
    ),
  );
}
