class Car {
  final int id;
  final String marca;
  final String modello;
  final double cilindrata;
  final String img;
  final int km;
  final int cavalli;
  final int kilowat;
  final String cambio;
  final String alimentazione;
  final String descrizione;
  final Map<String, dynamic> prezzi;
  final List<String> servizi_inclusi;
  bool isFavorite;

  Car({
    required this.id,
    required this.marca,
    required this.modello,
    required this.cilindrata,
    required this.img,
    required this.km,
    required this.cavalli,
    required this.kilowat,
    required this.cambio,
    required this.alimentazione,
    required this.descrizione,
    required this.prezzi,
    required this.servizi_inclusi,
    this.isFavorite = false,
  });

  // Crea un'auto da un JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      marca: json['marca'] ?? '',
      modello: json['modello'] ?? '',
      cilindrata: (json['cilindrata'] ?? 0.0).toDouble(),
      img: json['img'] ?? '',
      km: json['km'] ?? 0,
      cavalli: json['cavalli'] ?? 0,
      kilowat: json['kilowat'] ?? 0,
      cambio: json['cambio'] ?? '',
      alimentazione: json['alimentazione'] ?? '',
      descrizione: json['descrizione'] ?? '',
      prezzi: json['prezzi'] ?? {},
      servizi_inclusi: List<String>.from(json['servizi_inclusi'] ?? []),
    );
  }

  // Ottiene il nome completo dell'auto (marca + modello)
  String get nome => '$marca $modello';
  
  // Ottiene il prezzo per 24 mesi
  int get prezzoMensile => prezzi['24_mesi'] ?? 0;
  
  // Determina se l'auto ha cambio automatico
  bool get isAutomatico => cambio.toLowerCase() == 'automatico';
  
  // Ottiene il numero di posti (valore fisso per ora)
  int get posti => 5;
} 