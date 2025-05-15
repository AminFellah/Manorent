import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _passwordsMatch = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Reset dello stato
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });
    
    // Validazione base
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi';
        _isLoading = false;
      });
      return;
    }

    // Verifica che le password corrispondano
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordsMatch = false;
        _errorMessage = 'Le password non corrispondono';
        _isLoading = false;
      });
      return;
    }
    
    // Validazione della password
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'La password deve contenere almeno 6 caratteri';
        _isLoading = false;
      });
      return;
    }

    // Reset dell'errore per le password
    setState(() {
      _passwordsMatch = true;
    });

    try {
      // Registrazione su Firebase
      await _firebaseService.registerWithEmailAndPassword(
        _emailController.text.trim(), 
        _passwordController.text
      );
      
      // Registrazione avvenuta con successo, naviga alla home page
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

  void _handleSocialRegister(String platform) {
    // Gestione del login social (qui andrebbero implementati i vari provider)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registrazione con $platform non ancora implementata'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ottieni la larghezza dello schermo per rendere il layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 80) / 3; // 80 tiene conto di padding e spaziatura
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2F3F63)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/logo_full.png',
                  width: 297,
                  height: 51,
                ),
              ),
              const SizedBox(height: 40),
              
              // Form di Registrazione
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Crea il tuo nuovo Account',
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
                  
                  // Campo Email
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
                  
                  // Campo Password
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (!_passwordsMatch || _errorMessage.contains('password')) 
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
                  
                  // Campo Conferma Password
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_passwordsMatch ? Colors.red : const Color(0xFFD9D9D9),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Conferma password',
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
                  
                  // Pulsante Registrati
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8A800), // Colore arancione dal design
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
                              'Registrati',
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
              
              // Sezione Login Social
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'Oppure registrati con',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Riga pulsanti social - layout responsive
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Google
                      _buildSocialButton(
                        onTap: () => _handleSocialRegister('Google'),
                        icon: Icons.g_mobiledata, 
                        iconColor: Colors.red,
                        width: buttonWidth,
                      ),
                      
                      // Facebook
                      _buildSocialButton(
                        onTap: () => _handleSocialRegister('Facebook'),
                        icon: Icons.facebook,
                        iconColor: const Color(0xFF1877F2),
                        width: buttonWidth,
                      ),
                      
                      // Twitter/X
                      _buildSocialButton(
                        onTap: () => _handleSocialRegister('Twitter'),
                        icon: Icons.close,
                        iconColor: Colors.black,
                        width: buttonWidth,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Pulsante Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hai già un account? ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: 16,
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