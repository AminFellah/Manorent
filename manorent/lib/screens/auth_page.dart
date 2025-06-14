import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manorent/screens/info_form_page.dart';
import '../services/user_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';

  final _formKey = GlobalKey<FormState>();

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci un\'email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci una password';
    }
    if (value.length < 6) {
      return 'La password deve essere di almeno 6 caratteri';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isLogin) {
      if (value == null || value.isEmpty) {
        return 'Conferma la password';
      }
      if (value != _passwordController.text) {
        return 'Le password non coincidono';
      }
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Registrazione
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Crea il profilo utente iniziale
        await _userService.createNewUser(_emailController.text);
      }

      if (!mounted) return;

      // Naviga alla pagina del form informazioni
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const InfoFormPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Utente non trovato';
            break;
          case 'wrong-password':
            _errorMessage = 'Password errata';
            break;
          case 'email-already-in-use':
            _errorMessage = 'Email già in uso';
            break;
          case 'weak-password':
            _errorMessage = 'Password troppo debole';
            break;
          default:
            _errorMessage = 'Errore: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : (isConfirmPassword ? _obscureConfirmPassword : false),
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Color(0x59000000), fontSize: 16),
            border: InputBorder.none,
            suffixIcon: isPassword || isConfirmPassword
                ? IconButton(
                    icon: Icon(
                      isPassword
                          ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                          : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isPassword) {
                          _obscurePassword = !_obscurePassword;
                        } else {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 96),
                Center(
                  child: Image.asset(
                    'lib/assets/logo_full.png',
                    width: 297,
                    height: 51,
                  ),
                ),
                const SizedBox(height: 56),
                Text(
                  _isLogin ? 'Accedi al tuo Account' : 'Crea un nuovo Account',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
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
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  validator: _validateEmail,
                ),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  validator: _validatePassword,
                  isPassword: true,
                ),
                if (!_isLogin)
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Conferma Password',
                    validator: _validateConfirmPassword,
                    isConfirmPassword: true,
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8A800),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Accedi' : 'Registrati',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isLogin
                          ? 'Non hai un account? Registrati'
                          : 'Hai già un account? Accedi',
                      style: const TextStyle(
                        color: Color(0xFF2F3F63),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Oppure accedi con',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialButton(
                      icon: Icons.g_mobiledata,
                      onTap: () {
                        // TODO: Implementare login con Google
                      },
                    ),
                    _SocialButton(
                      icon: Icons.facebook,
                      onTap: () {
                        // TODO: Implementare login con Facebook
                      },
                    ),
                    _SocialButton(
                      icon: Icons.alternate_email,
                      onTap: () {
                        // TODO: Implementare login con Twitter/X
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 32,
          color: const Color(0xFF2F3F63),
        ),
      ),
    );
  }
} 