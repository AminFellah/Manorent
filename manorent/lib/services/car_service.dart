import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../services/preferences_service.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URL del server Flask
  // final String baseUrl = 'http://192.168.0.25:5000/auto';

  // Ottiene tutte le auto
  Future<List<Car>> getCars() async {
    final prefsService = await PreferencesService.getInstance();
    final favorites = prefsService.getFavorites();

    final snapshot = await _firestore.collection('auto').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      final car = Car.fromJson(data);
      // Imposta il flag dei preferiti in base ai dati locali
      car.isFavorite = favorites.any((fav) => fav.id == car.id);
      return car;
    }).toList();
  }

  // Ottiene i dettagli di una specifica auto
  Future<Car> getCarDetails(int carId) async {
    final prefsService = await PreferencesService.getInstance();
    final favorites = prefsService.getFavorites();

    final querySnapshot = await _firestore
        .collection('auto')
        .where('id', isEqualTo: carId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Auto non trovata');
    }

    Map<String, dynamic> data = querySnapshot.docs.first.data();
    final car = Car.fromJson(data);
    // Imposta il flag dei preferiti in base ai dati locali
    car.isFavorite = favorites.any((fav) => fav.id == car.id);
    return car;
  }

  // Aggiunge/rimuove un'auto dai preferiti
  Future<void> toggleFavorite(int carId) async {
    final prefsService = await PreferencesService.getInstance();
    final car = await getCarDetails(carId);
    
    if (car.isFavorite) {
      await prefsService.removeFavorite(carId);
    } else {
      await prefsService.saveFavorite(car);
    }
  }

  // Ottiene le auto preferite
  Future<List<Car>> getFavoriteCars() async {
    final prefsService = await PreferencesService.getInstance();
    return prefsService.getFavorites();
  }

  // Verifica se un'auto è tra i preferiti
  bool isFavorite(int carId) {
    // This method is no longer used in the updated implementation
    throw UnimplementedError();
  }
} 