import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../services/preferences_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crea una nuova prenotazione
  Future<Booking> createBooking({
    required int carId,
    required String carName,
    required String carImage,
    required double monthlyPrice,
    required String duration,
    required String kmPerYear,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    // Calcola la data di scadenza in base alla durata
    final bookingDate = DateTime.now();
    final durationInMonths = int.parse(duration.split('_')[0]);
    final expiryDate = DateTime(
      bookingDate.year,
      bookingDate.month + durationInMonths,
      bookingDate.day,
    );

    // Crea il documento della prenotazione
    final docRef = _firestore.collection('bookings').doc();
    final booking = Booking(
      id: docRef.id,
      userId: user.uid,
      carId: carId,
      carName: carName,
      carImage: carImage,
      monthlyPrice: monthlyPrice,
      duration: duration,
      kmPerYear: kmPerYear,
      bookingDate: bookingDate,
      expiryDate: expiryDate,
      status: 'active',
    );

    // Salva la prenotazione nel database e nelle SharedPreferences
    await docRef.set(booking.toMap());
    final prefsService = await PreferencesService.getInstance();
    await prefsService.saveBooking(booking);

    return booking;
  }

  // Ottiene tutte le prenotazioni dell'utente
  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final bookings = snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();

          // Aggiorna le prenotazioni nelle SharedPreferences
          final prefsService = await PreferencesService.getInstance();
          for (var booking in bookings) {
            await prefsService.saveBooking(booking);
          }

          return bookings;
        });
  }

  // Cancella una prenotazione
  Future<void> cancelBooking(String bookingId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    // Aggiorna lo stato nel database
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'cancelled'});

    // Aggiorna lo stato nelle SharedPreferences
    final prefsService = await PreferencesService.getInstance();
    await prefsService.removeBooking(bookingId);
  }

  // Carica le prenotazioni dalle SharedPreferences quando offline
  Future<List<Booking>> getOfflineBookings() async {
    final prefsService = await PreferencesService.getInstance();
    return prefsService.getBookings();
  }
} 