
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class BusinessService {
  // URL del server Flask
  // final String baseUrl = 'http://192.168.0.25:5000/business';
  
  // Lista dei preferiti (gestita localmente)
  final Set<int> _favorites = {};
  
  // Ottiene tutti i veicoli aziendali da Firestore
  Future<List<Car>> getBusinessVehicles() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('business').get();
      
      List<Car> vehicles = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Assumiamo che l'ID numerico sia presente nei dati del documento.
        return Car.fromJson(data);
      }).toList();

      // Aggiorna lo stato dei preferiti
      _updateFavoritesStatus(vehicles);

      return vehicles;
    } catch (e) {
      throw Exception('Errore nel caricamento dei veicoli aziendali da Firestore: $e');
    }
  }

  // Ottiene i dettagli di un singolo veicolo aziendale da Firestore
  Future<Car> getBusinessVehicleDetails(int vehicleId) async {
    try {
      // Usiamo una query per cercare l'ID numerico.
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('business')
          .where('id', isEqualTo: vehicleId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        Car vehicle = Car.fromJson(data);

        // Aggiorna lo stato dei preferiti
        vehicle.isFavorite = _favorites.contains(vehicle.id);

        return vehicle;
      } else {
        throw Exception('Veicolo aziendale non trovato in Firestore');
      }
    } catch (e) {
      throw Exception('Errore nel caricamento dei dettagli veicolo aziendale da Firestore: $e');
    }
  }
  
  // Aggiorna lo stato dei preferiti per i veicoli caricati
  void _updateFavoritesStatus(List<Car> vehicles) {
    for (var vehicle in vehicles) {
      vehicle.isFavorite = _favorites.contains(vehicle.id);
    }
  }
  
  // Aggiunge o rimuove un veicolo dai preferiti (gestito localmente)
  void toggleFavorite(int vehicleId) {
    if (_favorites.contains(vehicleId)) {
      _favorites.remove(vehicleId);
    } else {
      _favorites.add(vehicleId);
    }
  }
  
  // Ottiene solo i veicoli aziendali preferiti
  Future<List<Car>> getFavoriteBusinessVehicles() async {
    if (_favorites.isEmpty) {
      return [];
    }
    
    try {
      List<Car> allVehicles = await getBusinessVehicles();
      return allVehicles.where((vehicle) => _favorites.contains(vehicle.id)).toList();
    } catch (e) {
      throw Exception('Errore nel caricamento dei veicoli aziendali preferiti da Firestore: $e');
    }
  }
  
  // Verifica se un veicolo è tra i preferiti
  bool isFavorite(int vehicleId) {
    return _favorites.contains(vehicleId);
  }
} 