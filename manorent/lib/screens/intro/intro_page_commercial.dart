import 'package:flutter/material.dart';
import 'package:manorent/screens/intro/final_intro_page.dart';
//import 'package:manorent/screens/info_form_page.dart';

class IntroPageCommercial extends StatelessWidget {
  const IntroPageCommercial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3F63), // Colore di sfondo blu scuro come specificato nel design
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Il noleggio che segue ',
                        style: TextStyle(
                          color: Colors.white, // Giallo come il colore del pulsante
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'il ritmo del tuo business.',
                        style: TextStyle(
                          color: Color(0xFFF8A800),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Immagine grande in alto (Frame 139)
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 54),
              child: Image.asset(
                'lib/assets/commercial_van.png', // Sostituire con l'immagine corretta
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          
          // Testo sotto l'immagine
          
          
          // Pulsante in basso
          Padding(
            padding: const EdgeInsets.only(bottom: 46, left: 46, right: 46),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const FinalIntroPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8A800), // Colore arancione/giallo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 