class UserModel {
  final String uid;
  final String email;
  final String? nome;
  final String? cognome;
  final String? kmAnnuali;
  final String? citta;
  final String? telefono;
  final String? tipoUtente;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.nome,
    this.cognome,
    this.kmAnnuali,
    this.citta,
    this.telefono,
    this.tipoUtente,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converte il modello in Map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nome': nome,
      'cognome': cognome,
      'kmAnnuali': kmAnnuali,
      'citta': citta,
      'telefono': telefono,
      'tipoUtente': tipoUtente,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Crea un'istanza da Map di Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nome: map['nome'],
      cognome: map['cognome'],
      kmAnnuali: map['kmAnnuali'],
      citta: map['citta'],
      telefono: map['telefono'],
      tipoUtente: map['tipoUtente'],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Crea una copia del modello con alcuni campi aggiornati
  UserModel copyWith({
    String? nome,
    String? cognome,
    String? kmAnnuali,
    String? citta,
    String? telefono,
    String? tipoUtente,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      kmAnnuali: kmAnnuali ?? this.kmAnnuali,
      citta: citta ?? this.citta,
      telefono: telefono ?? this.telefono,
      tipoUtente: tipoUtente ?? this.tipoUtente,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 