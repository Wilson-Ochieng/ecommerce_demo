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
import 'package:test_app/ui/screens/home_screen.dart';
import 'package:test_app/ui/screens/profilescreen.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/login_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/register_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return UserProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: LoginScreen(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(),
          child: RegisterScreen(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(
            productRepository: ProductRepository(),
            cloudinaryService: CloudinaryService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthStartupViewModel()),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTHeme,
              context: context,
            ),

            initialRoute: FirebaseAuth.instance.currentUser == null
                ? LoginScreen.routName
                : RootsScreen.routName,

            routes: {
              LoginScreen.routName: (context) => const LoginScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              RootsScreen.routName: (context) => const RootsScreen(),
              Profilescreen.routName: (context) => const Profilescreen(),
              HomeScreen.routName: (context) => HomeScreen(),
            },

            // home: LoginScreen(),
          );
        },
      ),
    ),
  );
}
