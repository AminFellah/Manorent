// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/intro_page.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Verifica se Firebase è già inizializzato
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Errore durante l\'inizializzazione di Firebase: $e');
  }
  
  runApp(const ManorentApp());
}

class ManorentApp extends StatelessWidget {
  const ManorentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manorent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2F3F63),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F3F63),
          primary: const Color(0xFF2F3F63),
          secondary: const Color(0xFFF8A800),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F3F63),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F3F63),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget per controllare lo stato di autenticazione
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    
    // Utilizziamo un controllo più sicuro
    try {
      final currentUser = firebaseService.currentUser;
      if (currentUser != null) {
        return const HomePage();
      }
    } catch (e) {
      print('Errore nel controllo utente: $e');
    }
    
    return const LoadingScreen();
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onStartPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const IntroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animato
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'lib/assets/logo_full.png',
                  width: 500,
                  height: 500,
                ),
              ),
            ),
            const SizedBox(height: 80),
            // Pulsante per iniziare (appare dopo l'animazione)
            FadeTransition(
              opacity: _buttonOpacityAnimation,
              child: ElevatedButton(
                onPressed: _onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F3F63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'ENTRA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
