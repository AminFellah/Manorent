import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import '../services/commercial_service.dart';

class CarDetailPage extends StatefulWidget {
  final int carId;
  final bool isCommercial;
  
  const CarDetailPage({
    Key? key, 
    required this.carId,
    required this.isCommercial,
  }) : super(key: key);

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late Future<Car> _carFuture;
  final ScrollController _scrollController = ScrollController();
  String _selectedPriceKey = '24_mesi'; // Stato per l'opzione di prezzo selezionata

  @override
  void initState() {
    super.initState();
    _carFuture = widget.isCommercial
        ? CommercialService().getCommercialVehicleDetails(widget.carId)
        : CarService().getCarDetails(widget.carId);
    // Inizializza la chiave del prezzo selezionato alla prima chiave disponibile se car.prezzi non è vuoto
    _carFuture.then((car) {
      if (car.prezzi.isNotEmpty) {
        setState(() {
          _selectedPriceKey = car.prezzi.keys.first;
        });
      }
    }).catchError((_) {}); // Gestisci eventuali errori nel caricamento iniziale
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.04;
    final verticalPadding = screenSize.height * 0.02;
    final fontSize = screenSize.width * 0.04;
    final titleFontSize = screenSize.width * 0.055;
    final smallFontSize = screenSize.width * 0.035;
    final verticalSpacing = screenSize.height * 0.015;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Auto'),
        backgroundColor: const Color(0xFF2F3F63),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Car>(
        future: _carFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Auto non trovata'));
          }

          final car = snapshot.data!;

          // Altezza della sezione sticky
          final stickyHeight = MediaQuery.of(context).size.height * 0.32;

          return Stack(
            children: [
              // Contenuto principale scrollabile
              SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: horizontalPadding, 
                  right: horizontalPadding,
                  top: verticalPadding,
                  // Aggiunge spazio in fondo per evitare che il contenuto venga nascosto dal footer sticky
                  bottom: stickyHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Immagine
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          car.img,
                          width: screenSize.width * 0.8,
                          height: screenSize.width * 0.5,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            width: screenSize.width * 0.8,
                            height: screenSize.width * 0.5,
                            child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    // Nome
                    Text(
                      car.nome,
                      style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63)),
                    ),
                    SizedBox(height: verticalSpacing),
                    // Descrizione
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Descrizione completa'),
                            content: SingleChildScrollView(
                              child: Text(
                                car.descrizione,
                                style: TextStyle(fontSize: fontSize, color: const Color(0xFF2F3F63)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Chiudi'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        car.descrizione,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSize, color: const Color(0xFF2F3F63)),
                      ),
                    ),
                    // Seleziona i mesi
                    Text('Seleziona i mesi', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63))),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriceKey = '24_mesi';
                            });
                          },
                          child: _buildOptionBox('24 mesi', car.prezzi['24_mesi'], isSelected: _selectedPriceKey == '24_mesi'),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriceKey = '36_mesi';
                            });
                          },
                          child: _buildOptionBox('36 mesi', car.prezzi['36_mesi'], isSelected: _selectedPriceKey == '36_mesi'),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriceKey = '48_mesi';
                            });
                          },
                          child: _buildOptionBox('48 mesi', car.prezzi['48_mesi'], isSelected: _selectedPriceKey == '48_mesi'),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),
                    // Seleziona i KM interessati
                    Text('Seleziona i KM interessati', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63))),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildOptionBox('10.000', car.prezzi['10k_km']),
                          SizedBox(width: 10),
                          _buildOptionBox('20.000', car.prezzi['20k_km']),
                          SizedBox(width: 10),
                          _buildOptionBox('30.000', car.prezzi['30k_km']),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    // Specifiche tecniche
                    Text('Specifiche tecniche', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63))),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSpecBox('Cilindrata', '${car.cilindrata} L'),
                          SizedBox(width: 10),
                          _buildSpecBox('Cavalli', '${car.cavalli} CV'),
                          SizedBox(width: 10),
                          _buildSpecBox('kW', '${car.kilowat} kW'),
                          SizedBox(width: 10),
                          _buildSpecBox('Alimentazione', car.alimentazione),
                          SizedBox(width: 10),
                          _buildSpecBox('Cambio', car.cambio),
                          SizedBox(width: 10),
                          _buildSpecBox('Omologazione', 'EURO 6D'),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: verticalSpacing),
                    // Servizi inclusi
                    if (car.servizi_inclusi.isNotEmpty) ...[
                      Text('Servizi inclusi', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63))),
                      SizedBox(height: 8),
                      ...car.servizi_inclusi.map((s) => Row(
                        children: [
                          const Icon(Icons.check, color: Color(0xFFF8A800), size: 18),
                          SizedBox(width: 6),
                          Expanded(child: Text(s, style: TextStyle(fontSize: smallFontSize, color: const Color(0xFF2F3F63))))
                        ],
                      )),
                      SizedBox(height: verticalSpacing),
                      
                    ],
                  ],
                ),
              ),
               
              
              // Parte sticky in fondo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      SizedBox(height: verticalSpacing),
                      // Totale e bottone preventivo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('€${car.prezzi[_selectedPriceKey] ?? 'N/A'}/mese', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF2F3F63))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8A800),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Richiesta inviata'),
                                  content: const Text('La tua richiesta di preventivo è stata inviata!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Richiedi preventivo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionBox(String label, dynamic value, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF8A800) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFFF8A800) : const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize:14,color: isSelected ? Colors.white : const Color(0xFF2F3F63), fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSpecBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF2F3F63))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2F3F63))),
        ],
      ),
    );
  }
}