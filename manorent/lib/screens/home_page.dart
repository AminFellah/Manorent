import 'package:flutter/material.dart';
import '../components/car_card.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
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
  final FirebaseService _firebaseService = FirebaseService();
  
  // Lista delle auto caricate dal server
  List<Car> _cars = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Variabili per la ricerca e i filtri
  String _searchQuery = '';
  bool _onlyAutomaticTransmission = false;
  String _selectedFuelType = '';
  double _maxPrice = 0;
  double _selectedMaxPrice = 0; // Valore selezionato per il prezzo massimo
  List<String> _availableFuelTypes = [];
  int _minSeats = 0;
  bool _showPriceFilter = false; // Per mostrare/nascondere il filtro prezzo
  
  @override
  void initState() {
    super.initState();
    _loadCars();
  }
  
  // Carica le auto dal server
  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final cars = await _carService.getCars();
      
      // Determina il prezzo massimo e i tipi di carburante disponibili
      double maxPrice = 0;
      Set<String> fuelTypes = {};
      
      for (var car in cars) {
        if (car.prezzoMensile > maxPrice) {
          maxPrice = car.prezzoMensile.toDouble();
        }
        fuelTypes.add(car.alimentazione);
      }
      
      // Arrotonda il prezzo massimo al centinaio più vicino per lo slider
      maxPrice = (maxPrice / 100).ceil() * 100;
      
      setState(() {
        _cars = cars;
        _isLoading = false;
        _maxPrice = maxPrice;
        if (_selectedMaxPrice == 0) {
          _selectedMaxPrice = maxPrice;
        }
        _availableFuelTypes = fuelTypes.toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento delle auto: $e';
        _isLoading = false;
      });
    }
  }
  
  // Filtra le auto in base ai criteri selezionati
  List<Car> _getFilteredCars() {
    return _cars.where((car) {
      // Verifica se l'auto corrisponde alla query di ricerca
      bool matchesSearch = _searchQuery.isEmpty ||
          car.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.marca.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.modello.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Verifica se l'auto corrisponde al filtro per tipo di trasmissione
      bool matchesTransmission = !_onlyAutomaticTransmission || car.isAutomatico;
      
      // Verifica se l'auto corrisponde al filtro per tipo di carburante
      bool matchesFuelType = _selectedFuelType.isEmpty || car.alimentazione == _selectedFuelType;
      
      // Verifica se l'auto ha abbastanza posti
      bool matchesSeats = _minSeats == 0 || car.posti >= _minSeats;
      
      // Verifica se l'auto rientra nel budget
      bool matchesPrice = _selectedMaxPrice >= _maxPrice || car.prezzoMensile <= _selectedMaxPrice;
      
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
  void _toggleFavorite(int carId) {
    _carService.toggleFavorite(carId);
    setState(() {
      final carIndex = _cars.indexWhere((car) => car.id == carId);
      if (carIndex != -1) {
        _cars[carIndex].isFavorite = !_cars[carIndex].isFavorite;
      }
    });
  }
  
  // Mostra i dettagli dell'auto
  void _showCarDetails(int carId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarDetailPage(carId: carId),
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
            onPressed: _loadCars,
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
              onPressed: _loadCars,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    
    if (_cars.isEmpty) {
      return Center(
        child: Text(
          'Nessuna auto disponibile',
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF2F3F63),
          ),
        ),
      );
    }
    
    // Lista filtrata di auto
    final filteredCars = _getFilteredCars();
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: verticalSpacing),
          
          // Barra di ricerca
          TextField(
            decoration: InputDecoration(
              hintText: 'Cerca auto per marca o modello',
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
          SizedBox(height: verticalSpacing),
          
          // Filtri
          Row(
            children: [
              Text(
                'Filtri:',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F3F63),
                ),
              ),
              SizedBox(width: horizontalPadding),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Adatta i filtri in base alla larghezza disponibile
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Filtro trasmissione
                          FilterChip(
                            label: Text(
                              'Automatica',
                              style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                            ),
                            selected: _onlyAutomaticTransmission,
                            selectedColor: const Color(0xFFF8A800),
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _onlyAutomaticTransmission = selected;
                              });
                            },
                          ),
                          SizedBox(width: horizontalPadding * 0.5),
                          
                          // Dropdown per tipo di carburante
                          DropdownButton<String>(
                            hint: Text(
                              'Alimentazione',
                              style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                            ),
                            value: _selectedFuelType.isEmpty ? null : _selectedFuelType,
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text(
                                  'Tutti',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                              ..._availableFuelTypes.map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              )).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedFuelType = value ?? '';
                              });
                            },
                          ),
                          SizedBox(width: horizontalPadding * 0.5),
                          
                          // Filtro posti
                          DropdownButton<int>(
                            hint: Text(
                              'Min. posti',
                              style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                            ),
                            value: _minSeats == 0 ? null : _minSeats,
                            items: [
                              DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'Tutti',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 2,
                                child: Text(
                                  '2+',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 4,
                                child: Text(
                                  '4+',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 5,
                                child: Text(
                                  '5+',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 7,
                                child: Text(
                                  '7+',
                                  style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _minSeats = value ?? 0;
                              });
                            },
                          ),
                          SizedBox(width: horizontalPadding * 0.5),
                          
                          // Pulsante di reset
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(
                              'Reset',
                              style: TextStyle(fontSize: screenSize.width < 360 ? smallFontSize : fontSize),
                            ),
                            onPressed: _resetFilters,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2F3F63),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacingSmall),
          
          // Filtro prezzo
          Row(
            children: [
              TextButton.icon(
                icon: Icon(
                  _showPriceFilter ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: fontSize,
                ),
                label: Text(
                  'Prezzo max: €${_selectedMaxPrice.toInt()}',
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  setState(() {
                    _showPriceFilter = !_showPriceFilter;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2F3F63),
                ),
              ),
            ],
          ),
          
          // Slider per il prezzo
          if (_showPriceFilter) ...[
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
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '€0', 
                  style: TextStyle(fontSize: smallFontSize, color: const Color(0xFF2F3F63))
                ),
                Text(
                  '€${_maxPrice.toInt()}', 
                  style: TextStyle(fontSize: smallFontSize, color: const Color(0xFF2F3F63))
                ),
              ],
            ),
            SizedBox(height: verticalSpacingSmall),
          ],
          
          // Numero di risultati
          Text(
            '${filteredCars.length} risultati trovati',
            style: TextStyle(
              fontSize: smallFontSize,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2F3F63),
            ),
          ),
          SizedBox(height: verticalSpacingSmall),
          
          // Lista delle auto
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCars,
              child: filteredCars.isEmpty
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
                    itemCount: filteredCars.length,
                    separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      return CarCard(
                        imageUrl: car.img,
                        carName: car.nome,
                        seats: car.posti,
                        isAutomatic: car.isAutomatico,
                        fuelType: car.alimentazione,
                        pricePerMonth: car.prezzoMensile.toDouble(),
                        isFavorite: car.isFavorite,
                        onFavoritePressed: () => _toggleFavorite(car.id),
                        onDetailsPressed: () => _showCarDetails(car.id),
                      );
                    },
                  ),
            ),
          ),
        ],
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
    
    // Filtra le auto preferite dalla lista locale
    final favoriteCars = _cars.where((car) => car.isFavorite).toList();
    
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
              onPressed: _loadCars,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    
    if (favoriteCars.isEmpty) {
      return Center(
        child: Text(
          'Non hai auto preferite',
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
              itemCount: favoriteCars.length,
              separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
              itemBuilder: (context, index) {
                final car = favoriteCars[index];
                return CarCard(
                  imageUrl: car.img,
                  carName: car.nome,
                  seats: car.posti,
                  isAutomatic: car.isAutomatico,
                  fuelType: car.alimentazione,
                  pricePerMonth: car.prezzoMensile.toDouble(),
                  isFavorite: car.isFavorite,
                  onFavoritePressed: () => _toggleFavorite(car.id),
                  onDetailsPressed: () => _showCarDetails(car.id),
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
              'Qui potrai comunicare con i proprietari delle auto',
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