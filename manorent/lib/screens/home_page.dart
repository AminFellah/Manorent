import 'package:flutter/material.dart';
import 'package:manorent/screens/info_form_page.dart';
import '../components/car_card.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import '../services/commercial_service.dart';
import '../services/firebase_service.dart';
import '../services/business_service.dart';
//import 'info_form_page.dart';
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
  final BusinessService _businessService = BusinessService();
  final FirebaseService _firebaseService = FirebaseService();

  // Lista dei veicoli caricati dal server
  List<Car> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isCommercial = false; // Toggle per veicoli commerciali
  bool _isBusiness = false; // Toggle per veicoli aziendali

  // Variabili per la ricerca e i filtri
  String _searchQuery = '';
  bool _onlyAutomaticTransmission = false;
  bool _onlyManualTransmission = false;
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
      List<Car> fetchedVehicles;
      if (_isBusiness) {
        fetchedVehicles = await _businessService.getBusinessVehicles();
      } else if (_isCommercial) {
        fetchedVehicles = await _commercialService.getCommercialVehicles();
      } else {
        // Modalità Privato
        fetchedVehicles = await _carService.getCars();
      }

      // Determina il prezzo massimo e i tipi di carburante disponibili
      double maxPrice = 0;
      Set<String> fuelTypes = {};

      for (var vehicle in fetchedVehicles) {
        if (vehicle.prezzoMensile > maxPrice) {
          maxPrice = vehicle.prezzoMensile.toDouble();
        }
        fuelTypes.add(vehicle.alimentazione);
      }

      // Arrotonda il prezzo massimo al centinaio più vicino per lo slider
      maxPrice = (maxPrice / 100).ceil() * 100;

      setState(() {
        _vehicles = fetchedVehicles;
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

      bool matchesTransmission =
          true; // Assume true by default if no filter is active
      if (_onlyAutomaticTransmission) {
        matchesTransmission = vehicle.isAutomatico;
      } else if (_onlyManualTransmission) {
        matchesTransmission = !vehicle.isAutomatico; // Manual is not automatic
      }
      bool matchesFuelType = _selectedFuelType.isEmpty ||
          vehicle.alimentazione == _selectedFuelType;
      bool matchesSeats = _minSeats == 0 || vehicle.posti >= _minSeats;
      bool matchesPrice = _selectedMaxPrice >= _maxPrice ||
          vehicle.prezzoMensile <= _selectedMaxPrice;

      return matchesSearch &&
          matchesTransmission &&
          matchesFuelType &&
          matchesSeats &&
          matchesPrice;
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
  } else if (_isBusiness) {
    _businessService.toggleFavorite(vehicleId); // Aggiungi questo servizio
  } else {
    // Solo per veicoli privati
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
        MaterialPageRoute(builder: (context) => const InfoFormPage()),
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
            icon: Icon(Icons.calendar_month),
            label: 'Prenotazioni',
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
          Container(
            height: 50, // Altezza fissa per i bottoni
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding * 0.5),
              child: Row(
                children: [
                  // Bottone Privato
                  Container(
                    margin: EdgeInsets.only(right: horizontalPadding * 0.75),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isCommercial || _isBusiness) {
                          setState(() {
                            _isCommercial = false;
                            _isBusiness = false;
                            _loadVehicles();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (!_isCommercial && !_isBusiness)
                            ? const Color(0xFFF8A800)
                            : Colors.grey[300],
                        foregroundColor: (!_isCommercial && !_isBusiness)
                            ? Colors.white
                            : Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.06,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: (!_isCommercial && !_isBusiness) ? 4 : 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 18,
                            color: (!_isCommercial && !_isBusiness)
                                ? Colors.white
                                : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Privato',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: (!_isCommercial && !_isBusiness)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottone Autocarri
                  Container(
                    margin: EdgeInsets.only(right: horizontalPadding * 0.75),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isCommercial || _isBusiness) {
                          setState(() {
                            _isCommercial = true;
                            _isBusiness = false;
                            _loadVehicles();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isCommercial && !_isBusiness)
                            ? const Color(0xFFF8A800)
                            : Colors.grey[300],
                        foregroundColor: (_isCommercial && !_isBusiness)
                            ? Colors.white
                            : Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.06,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: (_isCommercial && !_isBusiness) ? 4 : 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 18,
                            color: (_isCommercial && !_isBusiness)
                                ? Colors.white
                                : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Autocarri',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: (_isCommercial && !_isBusiness)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottone Business
                  Container(
                    margin: EdgeInsets.only(right: horizontalPadding * 0.5),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isBusiness || _isCommercial) {
                          setState(() {
                            _isBusiness = true;
                            _isCommercial = false;
                            _loadVehicles();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isBusiness && !_isCommercial)
                            ? const Color(0xFFF8A800)
                            : Colors.grey[300],
                        foregroundColor: (_isBusiness && !_isCommercial)
                            ? Colors.white
                            : Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.06,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: (_isBusiness && !_isCommercial) ? 4 : 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            size: 18,
                            color: (_isBusiness && !_isCommercial)
                                ? Colors.white
                                : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Business',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: (_isBusiness && !_isCommercial)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
           SizedBox(height: verticalSpacing),
          // Barra di ricerca e filtro
          Row(
            children: [
              // Barra di ricerca
              Expanded(
                flex: 4, // Dai priorità alla searchbar
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cerca veicolo per marca o modello',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF2F3F63)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFF2F3F63)),
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
                      borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color(0xFFF8A800), width: 1.5),
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
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: const Color(0xFF2F3F63),
                  ),
                ),
              ),
              const SizedBox(width: 12), // Spazio fisso
              // Bottone filtri con spazio garantito
              SizedBox(
                width: 50, // Larghezza fissa garantita
                height: 50, // Altezza fissa
                child: ElevatedButton(
                  onPressed: () {
                    _showFilterModal(context, screenSize);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F3F63),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets
                        .zero, // Rimuovi padding per massimizzare spazio
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    size: 20,
                    color: Colors.white,
                  ),
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
                      separatorBuilder: (context, index) =>
                          SizedBox(height: verticalSpacing),
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
                          onDetailsPressed: () =>
                              _showVehicleDetails(vehicle.id),
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
                          if (selected) {
                            _onlyManualTransmission =
                                false; // Deseleziona manuale
                          }
                        });
                        this.setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: horizontalPadding * 0.5),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Manuale'),
                      selected: _onlyManualTransmission,
                      selectedColor: const Color(0xFFF8A800),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _onlyManualTransmission = selected;
                          if (selected) {
                            _onlyAutomaticTransmission =
                                false; // Deseleziona automatica
                          }
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text('Tutti',
                        style: TextStyle(fontSize: smallFontSize)),
                  ),
                  ..._availableFuelTypes
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type,
                                style: TextStyle(fontSize: smallFontSize)),
                          ))
                      .toList(),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Tutti',
                        style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child:
                        Text('2+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 4,
                    child:
                        Text('4+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 5,
                    child:
                        Text('5+', style: TextStyle(fontSize: smallFontSize)),
                  ),
                  DropdownMenuItem<int>(
                    value: 7,
                    child:
                        Text('7+', style: TextStyle(fontSize: smallFontSize)),
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
                  Text('€0',
                      style: TextStyle(
                          fontSize: smallFontSize,
                          color: const Color(0xFF2F3F63))),
                  Text('€${_maxPrice.toInt()}',
                      style: TextStyle(
                          fontSize: smallFontSize,
                          color: const Color(0xFF2F3F63))),
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
    final favoriteVehicles =
        _vehicles.where((vehicle) => vehicle.isFavorite).toList();

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
              separatorBuilder: (context, index) =>
                  SizedBox(height: verticalSpacing),
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
        vertical: screenSize.height * 0.015);

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
