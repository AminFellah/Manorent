
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarService {
  // URL del server Flask
  // final String baseUrl = 'http://192.168.0.25:5000/auto';

  // Lista dei preferiti (gestita localmente)
  final Set<int> _favorites = {};

  // Ottiene tutte le auto da Firestore
  Future<List<Car>> getCars() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('auto').get();
      
      List<Car> cars = querySnapshot.docs.map((doc) {
        // Ottieni i dati del documento
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Aggiungi l'ID del documento se non presente nei dati (Firestore usa un ID stringa)
        // Potrebbe essere necessario adattare il modello Car se l'ID è int.
        // Per ora, assumiamo che l'ID numerico sia presente nei dati del documento.

        return Car.fromJson(data);
      }).toList();

      // Aggiorna lo stato dei preferiti
      _updateFavoritesStatus(cars);

      return cars;
    } catch (e) {
      throw Exception('Errore nel caricamento delle auto da Firestore: $e');
    }
  }

  // Ottiene i dettagli di una singola auto da Firestore
  Future<Car> getCarDetails(int carId) async {
    try {
      // Nota: Firestore utilizza ID documento stringa. Se il tuo carId è int,
      // dovrai trovare un modo per mappare l'ID int all'ID stringa del documento Firestore.
      // Per ora, assumiamo che tu possa cercare il documento per un campo 'id' numerico
      // o che il carId fornito corrisponda all'ID del documento Firestore (come stringa).
      // Userò una query per cercare l'ID numerico.

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('auto')
          .where('id', isEqualTo: carId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        Car car = Car.fromJson(data);

        // Aggiorna lo stato dei preferiti
        car.isFavorite = _favorites.contains(car.id);

        return car;
      } else {
        throw Exception('Auto non trovata in Firestore');
      }
    } catch (e) {
      throw Exception('Errore nel caricamento dei dettagli auto da Firestore: $e');
    }
  }

  // Aggiorna lo stato dei preferiti per le auto caricate
  void _updateFavoritesStatus(List<Car> cars) {
    for (var car in cars) {
      car.isFavorite = _favorites.contains(car.id);
    }
  }

  // Aggiunge o rimuove un'auto dai preferiti (gestito localmente)
  void toggleFavorite(int carId) {
    if (_favorites.contains(carId)) {
      _favorites.remove(carId);
    } else {
      _favorites.add(carId);
    }
  }

  // Ottiene solo le auto preferite
  Future<List<Car>> getFavoriteCars() async {
    // Questo metodo continuerà a funzionare leggendo da getCars()
    // e filtrando localmente in base ai preferiti gestiti in _favorites.
    // Se i preferiti dovessero essere persistiti in Firebase, questo metodo
    // andrebbe modificato di conseguenza.
    if (_favorites.isEmpty) {
      return [];
    }

    try {
      List<Car> allCars = await getCars();
      return allCars.where((car) => _favorites.contains(car.id)).toList();
    } catch (e) {
      throw Exception('Errore nel caricamento delle auto preferite da Firestore: $e');
    }
  }

  // Verifica se un'auto è tra i preferiti
  bool isFavorite(int carId) {
    return _favorites.contains(carId);
  }
} 