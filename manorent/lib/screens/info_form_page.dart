import 'package:flutter/material.dart';
import 'package:manorent/screens/privacy_policy_page.dart';
import '../services/user_service.dart';
import 'home_page.dart';
 // <--- Assicurati di creare questo file

class InfoFormPage extends StatefulWidget {
  const InfoFormPage({super.key});

  @override
  State<InfoFormPage> createState() => _InfoFormPageState();
}

class _InfoFormPageState extends State<InfoFormPage> {
  final UserService _userService = UserService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _tipoUtenteString;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _privacyAccepted = false; // <-- Nuovo stato per checkbox

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final user = _userService.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      if (_nomeController.text.isEmpty ||
          _cognomeController.text.isEmpty ||
          _tipoUtenteString == null) {
        setState(() {
          _errorMessage = 'Compila tutti i campi richiesti.';
          _isLoading = false;
        });
        return;
      }

      if (!_privacyAccepted) {
        setState(() {
          _errorMessage = 'Devi accettare la Privacy Policy per continuare.';
          _isLoading = false;
        });
        return;
      }

      await _userService.updateUserProfile(
        nome: _nomeController.text,
        cognome: _cognomeController.text,
        tipoUtente: _tipoUtenteString,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            initialSection: _tipoUtenteString == 'Business' ? 1 : 0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel salvataggio dei dati: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool? enabled}) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: enabled == false ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x59000000), fontSize: 16),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Seleziona il tipo di utente:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3F63),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                'Privato',
                _tipoUtenteString == 'Privato',
                () => setState(() => _tipoUtenteString = 'Privato'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeButton(
                'Business',
                _tipoUtenteString == 'Business',
                () => setState(() => _tipoUtenteString = 'Business'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F3F63) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F3F63)
                : const Color(0xFFD9D9D9),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2F3F63),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                  const Text(
                    'Benvenuto in Manorent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3F63),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 16),
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
                  _buildUserTypeSelection(),
                  const SizedBox(height: 32),
                  _buildTextField('Nome', _nomeController),
                  _buildTextField('Cognome', _cognomeController),
                  _buildTextField('Email', _emailController, enabled: false),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _privacyAccepted,
                        onChanged: (bool? value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Ho letto e accetto la '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF2F3F63),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continua',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
