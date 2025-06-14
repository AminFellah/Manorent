import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  
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
    _kmController.dispose();
    _cittaController.dispose();
    _telefonoController.dispose();
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
          _kmController.text = userData.kmAnnuali ?? '';
          _cittaController.text = userData.citta ?? '';
          _telefonoController.text = userData.telefono ?? '';
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
        kmAnnuali: _kmController.text,
        citta: _cittaController.text,
        telefono: _telefonoController.text,
        tipoUtente: _tipoUtenteString,
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
      appBar: AppBar(
        title: const Text('Profilo'),
        backgroundColor: const Color(0xFF2F3F63),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 16),
              _buildTextField('KM percorsi in media all\'anno', _kmController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('Telefono', _telefonoController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('Città', _cittaController),
              const SizedBox(height: 24),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8A800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salva Modifiche',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 