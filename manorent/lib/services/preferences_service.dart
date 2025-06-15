import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/booking_model.dart';

class PreferencesService {
  static const String _userKey = 'user_data';
  static const String _favoritesKey = 'favorites';
  static const String _bookingsKey = 'bookings';
  static const String _lastLoginKey = 'last_login';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Singleton pattern
  static PreferencesService? _instance;
  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = PreferencesService(prefs);
    }
    return _instance!;
  }

  // Gestione dati utente
  Future<void> saveUserData(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toMap()));
    await _prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  UserModel? getUserData() {
    final userStr = _prefs.getString(_userKey);
    if (userStr == null) return null;
    return UserModel.fromMap(jsonDecode(userStr));
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_lastLoginKey);
  }

  // Gestione preferiti
  Future<void> saveFavorite(Car car) async {
    final favorites = getFavorites();
    if (!favorites.any((fav) => fav.id == car.id)) {
      favorites.add(car);
      await _prefs.setString(_favoritesKey, jsonEncode(
        favorites.map((car) => car.toJson()).toList(),
      ));
    }
  }

  Future<void> removeFavorite(int carId) async {
    final favorites = getFavorites();
    favorites.removeWhere((car) => car.id == carId);
    await _prefs.setString(_favoritesKey, jsonEncode(
      favorites.map((car) => car.toJson()).toList(),
    ));
  }

  List<Car> getFavorites() {
    final favoritesStr = _prefs.getString(_favoritesKey);
    if (favoritesStr == null) return [];
    final List<dynamic> decoded = jsonDecode(favoritesStr);
    return decoded.map((item) => Car.fromJson(item)).toList();
  }

  // Gestione prenotazioni
  Future<void> saveBooking(Booking booking) async {
    final bookings = getBookings();
    if (!bookings.any((b) => b.id == booking.id)) {
      bookings.add(booking);
      await _prefs.setString(_bookingsKey, jsonEncode(
        bookings.map((booking) => booking.toJson()).toList(),
      ));
    }
  }

  Future<void> removeBooking(String bookingId) async {
    final bookings = getBookings();
    bookings.removeWhere((booking) => booking.id == bookingId);
    await _prefs.setString(_bookingsKey, jsonEncode(
      bookings.map((booking) => booking.toJson()).toList(),
    ));
  }

  List<Booking> getBookings() {
    final bookingsStr = _prefs.getString(_bookingsKey);
    if (bookingsStr == null) return [];
    final List<dynamic> decoded = jsonDecode(bookingsStr);
    return decoded.map((item) => Booking.fromMap(item)).toList();
  }

  // Verifica se l'utente era già loggato
  bool wasLoggedIn() {
    final lastLogin = _prefs.getString(_lastLoginKey);
    return lastLogin != null;
  }
} 