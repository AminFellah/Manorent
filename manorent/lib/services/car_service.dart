import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';

class CarService {
  // URL del server Flask
  final String baseUrl = 'http://192.168.0.25:5000/auto';

  
  // Lista dei preferiti (gestita localmente)
  final Set<int> _favorites = {};
  
  // Ottiene tutte le auto dal server
  Future<List<Car>> getCars() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> carsJson = jsonDecode(response.body);
        List<Car> cars = carsJson.map((json) => Car.fromJson(json)).toList();
        
        // Aggiorna lo stato dei preferiti
        _updateFavoritesStatus(cars);
        
        return cars;
      } else {
        throw Exception('Errore nel caricamento delle auto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta: $e');
    }
  }
  
  // Ottiene i dettagli di una singola auto
  Future<Car> getCarDetails(int carId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$carId'));
      
      if (response.statusCode == 200) {
        final carJson = jsonDecode(response.body);
        Car car = Car.fromJson(carJson);
        
        // Aggiorna lo stato dei preferiti
        car.isFavorite = _favorites.contains(car.id);
        
        return car;
      } else {
        throw Exception('Auto non trovata');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta: $e');
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
    if (_favorites.isEmpty) {
      return [];
    }
    
    try {
      List<Car> allCars = await getCars();
      return allCars.where((car) => _favorites.contains(car.id)).toList();
    } catch (e) {
      throw Exception('Errore nel caricamento delle auto preferite: $e');
    }
  }
  
  // Verifica se un'auto è tra i preferiti
  bool isFavorite(int carId) {
    return _favorites.contains(carId);
  }
} 