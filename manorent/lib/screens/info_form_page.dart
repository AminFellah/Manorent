import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manorent/screens/privacy_policy_page.dart';

class InfoFormPage extends StatefulWidget {
  const InfoFormPage({super.key});

  @override
  State<InfoFormPage> createState() => _InfoFormPageState();
}

class _InfoFormPageState extends State<InfoFormPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _privacyAccepted = false;
  String _errorMessage = '';
  String? _tipoUtenteString; // "Privato" o "Business"

  void _handleSubmit() {
    setState(() => _errorMessage = '');

    if (_nomeController.text.isEmpty ||
        _cognomeController.text.isEmpty ||
        _kmController.text.isEmpty ||
        _cittaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _tipoUtenteString == null ||
        !_privacyAccepted) {
      setState(() {
        _errorMessage = 'Compila tutti i campi e accetta la privacy.';
      });
      return;
    }

    print('Nome: ${_nomeController.text}');
    print('Cognome: ${_cognomeController.text}');
    print('KM/anno: ${_kmController.text}');
    print('Città: ${_cittaController.text}');
    print('Email: ${_emailController.text}');
    print('Tipo utente: $_tipoUtenteString');
    print('Privacy accettata: $_privacyAccepted');
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
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
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x59000000), fontSize: 16),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      height: 54,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: DropdownButtonFormField<String>(
        value: _tipoUtenteString,
        decoration: const InputDecoration.collapsed(hintText: ''),
        hint: const Text(
          'Seleziona tipo utente',
          style: TextStyle(color: Color(0x59000000), fontSize: 16),
        ),
        icon: const Icon(Icons.arrow_drop_down),
        items: ['Privato', 'Business'].map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _tipoUtenteString = newValue;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _kmController.dispose();
    _cittaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                'Compila il form per soddisfare le tue richieste',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              _buildDropdownField(),
              _buildTextField('Nome', _nomeController),
              _buildTextField('Cognome', _cognomeController),
              _buildTextField('KM percorsi in media all’anno', _kmController,
                  keyboardType: TextInputType.number),
              _buildTextField('Telefono', _telefonoController,
                  keyboardType: TextInputType.phone),
              _buildTextField('Città', _cittaController),
              _buildTextField('Email', _emailController,
                  keyboardType: TextInputType.emailAddress),
              Row(
                children: [
                  Checkbox(
                    value: _privacyAccepted,
                    onChanged: (value) {
                      setState(() {
                        _privacyAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          const TextSpan(text:'Accetto la privacy '),
                          TextSpan(
                            text: 'policy',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8A800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Invia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
