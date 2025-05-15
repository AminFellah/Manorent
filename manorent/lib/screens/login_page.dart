import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import '../services/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Reset dello stato
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    // Validazione di base
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi';
        _isLoading = false;
      });
      return;
    }

    try {
      // Autenticazione con Firebase
      await _firebaseService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Login avvenuto con successo, naviga alla home page
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // Gestione degli errori
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSocialLogin(String platform) {
    // Gestione del login social (qui andrebbero implementati i vari provider)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login con $platform non ancora implementato'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToRegister() {
    // Navigate to registration page
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width to make layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 80) / 3; // 80 accounts for padding and spacing
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 96),
              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/logo_full.png',
                  width: 297,
                  height: 51,
                ),
              ),
              const SizedBox(height: 56),
              
              // Login Form Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Accedi al tuo Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Visualizza messaggio di errore se presente
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  
                  // Email field
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _errorMessage.contains('email') 
                            ? Colors.red 
                            : const Color(0xFFD9D9D9),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color(0x59000000),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Password field
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _errorMessage.contains('password') 
                            ? Colors.red 
                            : const Color(0xFFD9D9D9),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Color(0x59000000),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Login button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8A800), // Orange color from design
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFF8A800).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accedi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Social Login Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'Oppure accedi con',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Social buttons row - responsive layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Google
                      _buildSocialButton(
                        onTap: () => _handleSocialLogin('Google'),
                        icon: Icons.g_mobiledata,
                        iconColor: Colors.red,
                        width: buttonWidth,
                      ),
                      
                      // Facebook
                      _buildSocialButton(
                        onTap: () => _handleSocialLogin('Facebook'),
                        icon: Icons.facebook,
                        iconColor: const Color(0xFF1877F2),
                        width: buttonWidth,
                      ),
                      
                      // Twitter/X
                      _buildSocialButton(
                        onTap: () => _handleSocialLogin('Twitter'),
                        icon: Icons.close,
                        iconColor: Colors.black,
                        width: buttonWidth,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Register button - replaced text with proper button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Non hai un account? ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToRegister,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Registrati',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8A800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 40,
            color: iconColor,
          ),
        ),
      ),
    );
  }
} 