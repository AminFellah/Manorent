import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ottieni l'utente corrente
  User? get currentUser => _auth.currentUser;

  // Stream per monitorare i cambiamenti dello stato di autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrazione con email e password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Gestione degli errori generici
      throw 'Si è verificato un errore: $e';
    }
  }

  // Login con email e password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Gestione degli errori generici
      throw 'Si è verificato un errore: $e';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

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
