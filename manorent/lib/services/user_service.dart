import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ottiene l'utente corrente
  User? get currentUser => _auth.currentUser;

  // Ottiene i dati dell'utente corrente
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  // Salva o aggiorna i dati dell'utente
  Future<void> saveUserData(UserModel userData) async {
    if (currentUser == null) throw Exception('Nessun utente autenticato');

    await _firestore.collection('users').doc(currentUser!.uid).set(
      userData.toMap(),
      SetOptions(merge: true),
    );
  }

  // Crea un nuovo utente dopo la registrazione
  Future<void> createNewUser(String email) async {
    if (currentUser == null) throw Exception('Nessun utente autenticato');

    final userData = UserModel(
      uid: currentUser!.uid,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveUserData(userData);
  }

  // Aggiorna i dati del profilo utente
  Future<void> updateUserProfile({
    String? nome,
    String? cognome,
    String? kmAnnuali,
    String? citta,
    String? telefono,
    String? tipoUtente,
  }) async {
    final currentData = await getCurrentUserData();
    if (currentData == null) throw Exception('Dati utente non trovati');

    final updatedData = currentData.copyWith(
      nome: nome,
      cognome: cognome,
      kmAnnuali: kmAnnuali,
      citta: citta,
      telefono: telefono,
      tipoUtente: tipoUtente,
    );

    await saveUserData(updatedData);
  }
} 