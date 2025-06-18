import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatelessWidget {
  final BookingService _bookingService = BookingService();

  BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna prenotazione attiva',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2F3F63),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isExpired = booking.expiryDate.isBefore(DateTime.now());
              final isCancelled = booking.status == 'cancelled';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Immagine dell'auto
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        booking.carImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome dell'auto
                          Text(
                            booking.carName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3F63),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Aggiungo l'ID della prenotazione
                          Text(
                            'ID Prenotazione: ${booking.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2F3F63),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Dettagli della prenotazione
                          _buildDetailRow('Prezzo mensile', '€${booking.monthlyPrice.toStringAsFixed(2)}'),
                          _buildDetailRow('Durata', '${booking.duration.split('_')[0]} mesi'),
                          _buildDetailRow('Chilometraggio', '${booking.kmPerYear} km'),
                          _buildDetailRow('Data prenotazione', DateFormat('dd/MM/yyyy').format(booking.bookingDate)),
                          _buildDetailRow('Scadenza', DateFormat('dd/MM/yyyy').format(booking.expiryDate)),
                          const SizedBox(height: 8),
                          // Badge stato
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? Colors.red[100]
                                  : isExpired
                                      ? Colors.orange[100]
                                      : Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCancelled
                                  ? 'Cancellata'
                                  : isExpired
                                      ? 'Scaduta'
                                      : 'Attiva',
                              style: TextStyle(
                                color: isCancelled
                                    ? Colors.red[900]
                                    : isExpired
                                        ? Colors.orange[900]
                                        : Colors.green[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isExpired && !isCancelled) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Cancella prenotazione'),
                                      content: const Text('Sei sicuro di voler cancellare questa prenotazione?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _bookingService.cancelBooking(booking.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Sì'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Cancella prenotazione'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2F3F63),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F3F63),
            ),
          ),
        ],
      ),
    );
  }
} 