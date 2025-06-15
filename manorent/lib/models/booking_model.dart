import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final int carId;
  final String carName;
  final String carImage;
  final double monthlyPrice;
  final String duration;
  final String kmPerYear;
  final DateTime bookingDate;
  final DateTime expiryDate;
  final String status; // 'active', 'expired', 'cancelled'

  Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.monthlyPrice,
    required this.duration,
    required this.kmPerYear,
    required this.bookingDate,
    required this.expiryDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carName': carName,
      'carImage': carImage,
      'monthlyPrice': monthlyPrice,
      'duration': duration,
      'kmPerYear': kmPerYear,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      carId: map['carId'] ?? 0,
      carName: map['carName'] ?? '',
      carImage: map['carImage'] ?? '',
      monthlyPrice: (map['monthlyPrice'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '',
      kmPerYear: map['kmPerYear'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
    );
  }
} 