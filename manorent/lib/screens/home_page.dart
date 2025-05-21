import 'package:flutter/material.dart';
import '../components/car_card.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import '../services/commercial_service.dart';
import '../services/firebase_service.dart';
import 'login_page.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final CarService _carService = CarService();
  final CommercialService _commercialService = CommercialService();
  final FirebaseService _firebaseService = FirebaseService();
  
  // Lista dei veicoli caricati dal server
  List<Car> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isCommercial = false; // Toggle per veicoli commerciali
  
  // Variabili per la ricerca e i filtri
  String _searchQuery = '';
  bool _onlyAutomaticTransmission = false;
  String _selectedFuelType = '';
  double _maxPrice = 0;
  double _selectedMaxPrice = 0;
  List<String> _availableFuelTypes = [];
  int _minSeats = 0;
  bool _showPriceFilter = false;
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }
  
  // Carica i veicoli dal server
  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final vehicles = _isCommercial 
          ? await _commercialService.getCommercialVehicles()
          : await _carService.getCars();
      
      // Determina il prezzo massimo e i tipi di carburante disponibili
      double maxPrice = 0;
      Set<String> fuelTypes = {};
      
      for (var vehicle in vehicles) {
        if (vehicle.prezzoMensile > maxPrice) {
          maxPrice = vehicle.prezzoMensile.toDouble();
        }
        fuelTypes.add(vehicle.alimentazione);
      }
      
      // Arrotonda il prezzo massimo al centinaio più vicino per lo slider
      maxPrice = (maxPrice / 100).ceil() * 100;
      
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        _maxPrice = maxPrice;
        if (_selectedMaxPrice == 0) {
          _selectedMaxPrice = maxPrice;
        }
        _availableFuelTypes = fuelTypes.toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento dei veicoli: $e';
        _isLoading = false;
      });
    }
  }
  
  // Filtra i veicoli in base ai criteri selezionati
  List<Car> _getFilteredVehicles() {
    return _vehicles.where((vehicle) {
      bool matchesSearch = _searchQuery.isEmpty ||
          vehicle.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.marca.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.modello.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesTransmission = !_onlyAutomaticTransmission || vehicle.isAutomatico;
      bool matchesFuelType = _selectedFuelType.isEmpty || vehicle.alimentazione == _selectedFuelType;
      bool matchesSeats = _minSeats == 0 || vehicle.posti >= _minSeats;
      bool matchesPrice = _selectedMaxPrice >= _maxPrice || vehicle.prezzoMensile <= _selectedMaxPrice;
      
      return matchesSearch && matchesTransmission && matchesFuelType && matchesSeats && matchesPrice;
    }).toList();
  }
  
  // Reset dei filtri
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _onlyAutomaticTransmission = false;
      _selectedFuelType = '';
      _minSeats = 0;
      _selectedMaxPrice = _maxPrice;
      _showPriceFilter = false;
    });
  }
  
  // Toggle preferito
  void _toggleFavorite(int vehicleId) {
    if (_isCommercial) {
      _commercialService.toggleFavorite(vehicleId);
    } else {
      _carService.toggleFavorite(vehicleId);
    }
    setState(() {
      final vehicleIndex = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
      if (vehicleIndex != -1) {
        _vehicles[vehicleIndex].isFavorite = !_vehicles[vehicleIndex].isFavorite;
      }
    });
  }
  
  // Mostra i dettagli del veicolo
  void _showVehicleDetails(int vehicleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarDetailPage(
          carId: vehicleId,
          isCommercial: _isCommercial,
        ),
      ),
    );
  }

  // Funzione per effettuare il logout
  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      if (!mounted) return;
      
      // Redirect alla pagina di login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ottieni le dimensioni dello schermo per il responsive design
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MANORENT'),
        backgroundColor: const Color(0xFF2F3F63),
        foregroundColor: Colors.white,
        actions: [
          // Pulsante di refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      body: _buildCurrentPage(screenSize),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFF8A800),
        unselectedItemColor: const Color(0xFF2F3F63),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Esplora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Preferiti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentPage(Size screenSize) {
    switch (_currentIndex) {
      case 0:
        return _buildExploreTab(screenSize);
      case 1:
        return _buildFavoritesTab(screenSize);
      case 2:
        return _buildChatTab(screenSize);
      case 3:
        return _buildProfileTab(screenSize);
      default:
        return _buildExploreTab(screenSize);
    }
  }
  
  Widget _buildExploreTab(Size screenSize) {
    // Calcola valori responsivi
    final horizontalPadding = screenSize.width * 0.04;
    final verticalPadding = screenSize.height * 0.02;
    final fontSize = screenSize.width * 0.04;
    final titleFontSize = screenSize.width * 0.055;
    final smallFontSize = screenSize.width * 0.035;
    final verticalSpacing = screenSize.height * 0.015;
    final verticalSpacingSmall = screenSize.height * 0.008;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    
    if (_vehicles.isEmpty) {
      return Center(
        child: Text(
          'Nessun veicolo disponibile',
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF2F3F63),
          ),
        ),
      );
    }
    
    // Lista filtrata di veicoli
    final filteredVehicles = _getFilteredVehicles();
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: verticalSpacing),
          
          // Toggle per tipo di veicolo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_isCommercial) {
                    setState(() {
                      _isCommercial = false;
                      _loadVehicles();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isCommercial ? const Color(0xFFF8A800) : Colors.grey[300],
                  foregroundColor: !_isCommercial ? Colors.white : Colors.black,
                ),
                child: const Text('Privato'),
              ),
              SizedBox(width: horizontalPadding),
              ElevatedButton(
                onPressed: () {
                  if (!_isCommercial) {
                    setState(() {
                      _isCommercial = true;
                      _loadVehicles();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCommercial ? const Color(0xFFF8A800) : Colors.grey[300],
                  foregroundColor: _isCommercial ? Colors.white : Colors.black,
                ),
                child: const Text('Business'),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing),
          
          // Barra di ricerca e filtro
          Row(
            children: [
              // Barra di ricerca
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cerca veicolo per marca o modello',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2F3F63)),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF2F3F63)),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFF8A800), width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: TextStyle(
                    fontSize: fontSize,
                    color: const Color(0xFF2F3F63),
                  ),
                ),
              ),
              SizedBox(width: horizontalPadding * 0.5),
              // Bottone filtri
              ElevatedButton.icon(
                onPressed: () {
                  _showFilterModal(context, screenSize);
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filtri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F3F63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing),
          
          // Numero di risultati
          Text(
            '${filteredVehicles.length} risultati trovati',
            style: TextStyle(
              fontSize: smallFontSize,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2F3F63),
            ),
          ),
          SizedBox(height: verticalSpacingSmall),
          
          // Lista dei veicoli
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVehicles,
              child: filteredVehicles.isEmpty
                ? Center(
                    child: Text(
                      'Nessun risultato per i filtri selezionati',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: const Color(0xFF2F3F63),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredVehicles.length,
                    separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return CarCard(
                        imageUrl: vehicle.img,
                        carName: vehicle.nome,
                        seats: vehicle.posti,
                        isAutomatic: vehicle.isAutomatico,
                        fuelType: vehicle.alimentazione,
                        pricePerMonth: vehicle.prezzoMensile.toDouble(),
                        isFavorite: vehicle.isFavorite,
                        onFavoritePressed: () => _toggleFavorite(vehicle.id),
                        onDetailsPressed: () => _showVehicleDetails(vehicle.id),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterModal(BuildContext context, Size screenSize) {
    final fontSize = screenSize.width * 0.04;
    final smallFontSize = screenSize.width * 0.035;
    final verticalSpacing = screenSize.height * 0.015;
    final horizontalPadding = screenSize.width * 0.04;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtri',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3F63),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
              
              // Tipo di cambio
              Text(
                'Tipo di cambio',
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3F63),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Automatica'),
                      selected: _onlyAutomaticTransmission,
                      selectedColor: const Color(0xFFF8A800),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _onlyAutomaticTransmission = selected;
                        });
                        this.setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
              
              // Tipo di carburante
              Text(
                'Alimentazione',
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3F63),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              DropdownButtonFormField<String>(
                value: _selectedFuelType.isEmpty ? null : _selectedFuelType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text('Tutti', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  ..._availableFuelTypes.map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: TextStyle(fontSize: smallFontSize)),
                  )).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value ?? '';
                  });
                  this.setState(() {});
                },
              ),
              SizedBox(height: verticalSpacing),
              
              // Numero di posti
              Text(
                'Numero di posti',
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3F63),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              DropdownButtonFormField<int>(
                value: _minSeats == 0 ? null : _minSeats,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Tutti', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('2+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 4,
                    child: Text('4+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 5,
                    child: Text('5+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 7,
                    child: Text('7+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _minSeats = value ?? 0;
                  });
                  this.setState(() {});
                },
              ),
              SizedBox(height: verticalSpacing),
              
              // Prezzo massimo
              Text(
                'Prezzo massimo: €${_selectedMaxPrice.toInt()}',
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3F63),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Slider(
                value: _selectedMaxPrice,
                min: 0,
                max: _maxPrice > 0 ? _maxPrice : 1000,
                divisions: 10,
                activeColor: const Color(0xFFF8A800),
                inactiveColor: const Color(0xFFD9D9D9),
                label: '€${_selectedMaxPrice.toInt()}',
                onChanged: (value) {
                  setState(() {
                    _selectedMaxPrice = value;
                  });
                  this.setState(() {});
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('€0', style: TextStyle(fontSize: smallFontSize, color: const Color(0xFF2F3F63))),
                  Text('€${_maxPrice.toInt()}', style: TextStyle(fontSize: smallFontSize, color: const Color(0xFF2F3F63))),
                ],
              ),
              SizedBox(height: verticalSpacing * 2),
              
              // Pulsanti di azione
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _resetFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF2F3F63)),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  SizedBox(width: horizontalPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8A800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Applica'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoritesTab(Size screenSize) {
    // Calcola valori responsivi
    final horizontalPadding = screenSize.width * 0.04;
    final verticalPadding = screenSize.height * 0.02;
    final fontSize = screenSize.width * 0.04;
    final titleFontSize = screenSize.width * 0.055;
    final verticalSpacing = screenSize.height * 0.015;
    
    // Filtra i veicoli preferiti dalla lista locale
    final favoriteVehicles = _vehicles.where((vehicle) => vehicle.isFavorite).toList();
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    
    if (favoriteVehicles.isEmpty) {
      return Center(
        child: Text(
          'Non hai veicoli preferiti',
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF2F3F63),
          ),
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I tuoi Preferiti',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3F63),
            ),
          ),
          SizedBox(height: verticalSpacing),
          Expanded(
            child: ListView.separated(
              itemCount: favoriteVehicles.length,
              separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
              itemBuilder: (context, index) {
                final vehicle = favoriteVehicles[index];
                return CarCard(
                  imageUrl: vehicle.img,
                  carName: vehicle.nome,
                  seats: vehicle.posti,
                  isAutomatic: vehicle.isAutomatico,
                  fuelType: vehicle.alimentazione,
                  pricePerMonth: vehicle.prezzoMensile.toDouble(),
                  isFavorite: vehicle.isFavorite,
                  onFavoritePressed: () => _toggleFavorite(vehicle.id),
                  onDetailsPressed: () => _showVehicleDetails(vehicle.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatTab(Size screenSize) {
    // Calcola valori responsivi
    final fontSize = screenSize.width * 0.04;
    final titleFontSize = screenSize.width * 0.055;
    final iconSize = screenSize.width * 0.15;
    final verticalSpacing = screenSize.height * 0.015;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: iconSize,
            color: const Color(0xFF2F3F63),
          ),
          SizedBox(height: verticalSpacing),
          Text(
            'Chat in arrivo',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3F63),
            ),
          ),
          SizedBox(height: verticalSpacing * 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
            child: Text(
              'Qui potrai comunicare con i proprietari dei veicoli',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab(Size screenSize) {
    // Calcola valori responsivi
    final fontSize = screenSize.width * 0.04;
    final titleFontSize = screenSize.width * 0.055;
    final avatarRadius = screenSize.width * 0.12;
    final iconSize = avatarRadius * 0.8;
    final verticalSpacing = screenSize.height * 0.02;
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: screenSize.width * 0.06,
      vertical: screenSize.height * 0.015
    );
    
    final currentUser = _firebaseService.currentUser;
    final email = currentUser?.email ?? 'Utente non autenticato';
    
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: const Color(0xFF2F3F63),
              child: Icon(
                Icons.person,
                size: iconSize,
                color: Colors.white,
              ),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              email,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2F3F63),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing),
            Text(
              'Il tuo profilo',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2F3F63),
              ),
            ),
            SizedBox(height: verticalSpacing * 0.4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
              child: Text(
                'Qui potrai gestire le tue informazioni personali',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 1.5),
            
            // Responsive logout button
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Esci dall\'account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: buttonPadding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenSize.width * 0.025),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 