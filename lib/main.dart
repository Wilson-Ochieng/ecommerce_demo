import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:test_app/constants/theme_data.dart';
import 'package:test_app/data/repositories/auth_repository.dart';
import 'package:test_app/data/repositories/category_repository.dart';
import 'package:test_app/data/repositories/notification_repository.dart';
import 'package:test_app/data/repositories/product_repository.dart';
import 'package:test_app/data/services/cloudinary_service.dart';
import 'package:test_app/data/services/notification_service.dart';
import 'package:test_app/firebase_options.dart';

import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/providers/UserProvider.dart';

import 'package:test_app/root_screen.dart';
import 'package:test_app/ui/screens/auth/login_screen.dart';
import 'package:test_app/ui/screens/auth/signup_screen.dart';
import 'package:test_app/ui/screens/auth/startup_screen.dart';
import 'package:test_app/ui/screens/home_screen.dart';

import 'package:test_app/ui/screens/viewmodels/admin_orders_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/checkout_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/login_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/notification_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/orders_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/profile_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/register_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/user_management_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/wishlist_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register FCM background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  notificationService.listenForForegroundMessages((RemoteMessage message) {
    debugPrint('MAIN: Foreground notification received');

    debugPrint('MAIN: Title: ${message.notification?.title}');

    debugPrint('MAIN: Body: ${message.notification?.body}');

    debugPrint('MAIN: Data: ${message.data}');
  });

  // Load saved user
  final userProvider = UserProvider();
  await userProvider.loadSavedUser();

  runApp(
    MultiProvider(
      providers: [
        // ==========================================================
        // THEME
        // ==========================================================
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // ==========================================================
        // USER
        // ==========================================================
        ChangeNotifierProvider.value(value: userProvider),

        // ==========================================================
        // AUTH REPOSITORY
        // ==========================================================
        Provider<AuthRepository>(create: (_) => AuthRepository()),

        // ==========================================================
        // NOTIFICATION REPOSITORY
        // ==========================================================
        Provider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),

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
            userProvider: context.read<UserProvider>(),
            notificationRepository: context.read<NotificationRepository>(),
          ),
        ),

        // ==========================================================
        // USER MANAGEMENT
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
        // CLOUDINARY
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

        // ==========================================================
        // CART
        // ==========================================================
        ChangeNotifierProvider<CartViewModel>(create: (_) => CartViewModel()),

        // ==========================================================
        // WISHLIST
        // ==========================================================
        ChangeNotifierProvider<WishlistViewModel>(
          create: (_) => WishlistViewModel(),
        ),

        // ==========================================================
        // PROFILE
        // ==========================================================
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
        ),

        // ==========================================================
        // ORDERS
        // ==========================================================
        ChangeNotifierProvider<OrdersViewModel>(
          create: (_) => OrdersViewModel(),
        ),

        // ==========================================================
        // ADMIN ORDERS
        // ==========================================================
        ChangeNotifierProvider<AdminOrdersViewModel>(
          create: (_) => AdminOrdersViewModel(),
        ),

        // ==========================================================
        // NOTIFICATIONS
        // ==========================================================


        // ==========================================================
        // CHECKOUT
        // ==========================================================
        ChangeNotifierProvider<CheckoutViewModel>(
          create: (context) =>
              CheckoutViewModel(userProvider: context.read<UserProvider>()),
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

              HomeScreen.routName: (context) => const HomeScreen(),
            },
          );
        },
      ),
    ),
  );
}
