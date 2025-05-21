import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';

class BusinessService {
  // URL del server Flask
  final String baseUrl = 'http://192.168.0.25:5000/business';
  
  // Lista dei preferiti (gestita localmente)
  final Set<int> _favorites = {};
  
  // Ottiene tutti i veicoli commerciali dal server
  Future<List<Car>> getBusinessVehicles() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> vehiclesJson = jsonDecode(response.body);
        List<Car> vehicles = vehiclesJson.map((json) => Car.fromJson(json)).toList();
        
        // Aggiorna lo stato dei preferiti
        _updateFavoritesStatus(vehicles);
        
        return vehicles;
      } else {
        throw Exception('Errore nel caricamento dei veicoli aziendali: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta: $e');
    }
  }

  // Ottiene i dettagli di un singolo veicolo commerciale
  Future<Car> getBusinessVehicleDetails(int vehicleId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$vehicleId'));
      
      if (response.statusCode == 200) {
        final vehicleJson = jsonDecode(response.body);
        Car vehicle = Car.fromJson(vehicleJson);
        
        // Aggiorna lo stato dei preferiti
        vehicle.isFavorite = _favorites.contains(vehicle.id);
        
        return vehicle;
      } else {
        throw Exception('Veicolo aziendale non trovato');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta: $e');
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
  
  // Ottiene solo i veicoli commerciali preferiti
  Future<List<Car>> getFavoriteBusinessVehicles() async {
    if (_favorites.isEmpty) {
      return [];
    }
    
    try {
      List<Car> allVehicles = await getBusinessVehicles();
      return allVehicles.where((vehicle) => _favorites.contains(vehicle.id)).toList();
    } catch (e) {
      throw Exception('Errore nel caricamento dei veicoli aziendali preferiti: $e');
    }
  }
  
  // Verifica se un veicolo è tra i preferiti
  bool isFavorite(int vehicleId) {
    return _favorites.contains(vehicleId);
  }
} 