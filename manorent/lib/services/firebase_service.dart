import 'package:firebase_auth/firebase_auth.dart';
import '../services/preferences_service.dart';
import '../services/user_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Ottiene l'utente corrente
  User? get currentUser => _auth.currentUser;

  // Registra un nuovo utente
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // Effettua il login
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Salva i dati dell'utente nelle SharedPreferences
    final prefsService = await PreferencesService.getInstance();
    final userData = await _userService.getCurrentUserData();
    if (userData != null) {
      await prefsService.saveUserData(userData);
    }
  }

  // Effettua il logout
  Future<void> signOut() async {
    // Pulisci i dati dalle SharedPreferences
    final prefsService = await PreferencesService.getInstance();
    await prefsService.clearUserData();
    
    // Effettua il logout da Firebase
    await _auth.signOut();
  }

  // Verifica se l'utente è autenticato
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Gestione degli errori di autenticazione tradotti in italiano
  String _handleAuthException(FirebaseAuthException e) {
    print('Codice errore Firebase: ${e.code}'); // Log per debug

    switch (e.code) {
      case 'invalid-email':
        return 'L\'indirizzo email non è valido.';
      case 'user-disabled':
        return 'Questo utente è stato disabilitato.';
      case 'user-not-found':
        return 'Nessun utente trovato con questa email.';
      case 'wrong-password':
        return 'Password errata.';
      case 'email-already-in-use':
        return 'Esiste già un account con questa email.';
      case 'operation-not-allowed':
        return 'Operazione non consentita.';
      case 'weak-password':
        return 'La password è troppo debole.';
      case 'network-request-failed':
        return 'Errore di connessione. Verifica la tua connessione internet.';
      case 'too-many-requests':
        return 'Troppe richieste. Riprova più tardi.';
      default:
        return 'Si è verificato un errore: ${e.message}';
    }
  }
}
