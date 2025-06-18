import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/firebase_service.dart';
import 'auth_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _partitaIvaController = TextEditingController();
  final TextEditingController _ragioneSocialeController = TextEditingController();
  UserModel? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  String _errorMessage = '';
  String? _tipoUtenteString;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _partitaIvaController.dispose();
    _ragioneSocialeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _userService.getCurrentUserData();
      setState(() {
        _userData = userData;
        if (userData != null) {
          _nomeController.text = userData.nome ?? '';
          _cognomeController.text = userData.cognome ?? '';
          _partitaIvaController.text = userData.partitaIva ?? '';
          _ragioneSocialeController.text = userData.ragioneSociale ?? '';
          _tipoUtenteString = userData.tipoUtente;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento dei dati: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      
      await _userService.updateUserProfile(
        nome: _nomeController.text,
        cognome: _cognomeController.text,
        tipoUtente: _tipoUtenteString,
        partitaIva: _tipoUtenteString == 'Business' ? _partitaIvaController.text : null,
        ragioneSociale: _tipoUtenteString == 'Business' ? _ragioneSocialeController.text : null,
      );

      await _loadUserData();
      setState(() => _isEditing = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel salvataggio dei dati: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      if (!mounted) return;

      // Redirect alla pagina di login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il logout: $e')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Questo campo è obbligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _tipoUtenteString,
      decoration: InputDecoration(
        labelText: 'Tipo Utente',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[200],
      ),
      items: ['Privato', 'Business'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _isEditing
          ? (String? newValue) {
              setState(() {
                _tipoUtenteString = newValue;
              });
            }
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleziona il tipo di utente';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFF8A800),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _userData?.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3F63),
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField(),
              const SizedBox(height: 16),
              _buildTextField('Nome', _nomeController),
              const SizedBox(height: 16),
              _buildTextField('Cognome', _cognomeController),
              if (_tipoUtenteString == 'Business') ...[
                const SizedBox(height: 16),
                _buildTextField('Partita IVA', _partitaIvaController),
                const SizedBox(height: 16),
                _buildTextField('Ragione Sociale', _ragioneSocialeController),
              ],
              const SizedBox(height: 24),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8A800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salva Modifiche',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Column(
                  children: [
                    // Pulsante Modifica Profilo
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifica Profilo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8A800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pulsante di logout
                    ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Esci dall\'account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 