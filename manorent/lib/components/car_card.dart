import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String imageUrl;
  final String carName;
  final int seats;
  final bool isAutomatic;
  final String fuelType;
  final double pricePerMonth;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDetailsPressed;
  final bool isFavorite;

  const CarCard({
    super.key,
    required this.imageUrl,
    required this.carName,
    required this.seats,
    required this.isAutomatic,
    required this.fuelType,
    required this.pricePerMonth,
    required this.onFavoritePressed,
    required this.onDetailsPressed,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ottieni le dimensioni dello schermo
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 500 ? 347.0 : screenWidth * 0.85;
    
    // Rimuovo l'altezza fissa della card per evitare l'overflow
    final horizontalPadding = cardWidth * 0.08;
    final smallPadding = cardWidth * 0.025;

    return Container(
      width: cardWidth,
      // Rimuovo height: cardHeight per permettere alla card di espandersi in base al contenuto
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Impedisce alla colonna di espandersi troppo
        children: [
          // Top section with image and favorite button
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, smallPadding * 1.5, horizontalPadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Favorite button and car image
                SizedBox(
                  height: cardWidth * 0.5, // Altezza proporzionale all'immagine
                  child: Stack(
                    children: [
                      // Favorite button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite 
                              ? Colors.red 
                              : const Color(0xFF3F3F3F),
                            size: cardWidth * 0.07,
                          ),
                          onPressed: onFavoritePressed,
                          padding: EdgeInsets.zero, // Riduco il padding del pulsante
                        ),
                      ),
                      
                      // Car image
                      Positioned(
                        top: cardWidth * 0.1,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Car name
                SizedBox(height: smallPadding),
                Text(
                  carName,
                  style: TextStyle(
                    fontSize: cardWidth * 0.046,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F3F63),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Orange divider
          SizedBox(height: smallPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              height: 2, // Ridotto da 3
              decoration: BoxDecoration(
                color: const Color(0xFFF8A800),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Car specs
          SizedBox(height: smallPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Seats
                _buildSpecItem(
                  context: context,
                  cardWidth: cardWidth,
                  icon: Icon(
                    Icons.person,
                    color: const Color(0xFF2F3F63),
                    size: cardWidth * 0.05,
                  ),
                  text: '$seats posti',
                  textColor: const Color(0xFF2F3F63),
                ),
                
                // Transmission
                _buildSpecItem(
                  context: context,
                  cardWidth: cardWidth,
                  icon: Icon(
                    Icons.settings,
                    color: const Color(0xFF2F3F63),
                    size: cardWidth * 0.05,
                  ),
                  text: isAutomatic ? 'Auto' : 'Man', // Abbrevio per risparmiare spazio
                  textColor: const Color(0xFF2F3F63),
                ),
                
                // Fuel type
                _buildSpecItem(
                  context: context,
                  cardWidth: cardWidth,
                  icon: Icon(
                    Icons.local_gas_station,
                    color: const Color(0xFF2F3F63),
                    size: cardWidth * 0.05,
                  ),
                  text: fuelType,
                  textColor: const Color(0xFF2F3F63),
                ),
              ],
            ),
          ),
          
          // Price and details button
          Padding(
            padding: EdgeInsets.fromLTRB(smallPadding, smallPadding, smallPadding, smallPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Padding(
                  padding: EdgeInsets.only(left: smallPadding),
                  child: Text(
                    '€${pricePerMonth.toStringAsFixed(0)}/mese',
                    style: TextStyle(
                      fontSize: cardWidth * 0.046,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3F63),
                    ),
                  ),
                ),
                
                // Details button
                Container(
                  width: cardWidth * 0.11,
                  height: cardWidth * 0.1,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3F63),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: cardWidth * 0.06,
                    ),
                    onPressed: onDetailsPressed,
                    padding: EdgeInsets.zero, // Riduco il padding del pulsante
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecItem({
    required BuildContext context,
    required double cardWidth,
    required Icon icon,
    required String text,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: cardWidth * 0.015, 
        vertical: cardWidth * 0.01
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Impedisce alla riga di espandersi troppo
        children: [
          icon,
          SizedBox(width: cardWidth * 0.01), // Ridotto
          Text(
            text,
            style: TextStyle(
              fontSize: cardWidth * 0.035, // Ridotto da 0.04
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 