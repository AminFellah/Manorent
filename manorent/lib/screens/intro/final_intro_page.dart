import 'package:flutter/material.dart';
import 'package:manorent/screens/auth_page.dart';
import 'package:manorent/screens/info_form_page.dart';
import 'package:manorent/screens/intro/intro_page_commercial.dart';

class FinalIntroPage extends StatelessWidget {
  const FinalIntroPage({super.key});

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
                  textAlign: TextAlign.left,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Benvenuto su ',
                        style: TextStyle(
                          color: Colors.white, // Giallo come il colore del pulsante
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Manorent, ',
                        style: TextStyle(
                          color: Color(0xFFF8A800),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'il tuo punto di riferimento per il noleggio auto a lungo termine. Esplora i nostri cataloghi e trova l’offerta perfetta ',
                        style : TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      TextSpan(
                        text:'per te.',
                        style: TextStyle(
                          color: Color(0xFFF8A800),
                          fontSize: 28,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Pulsante in basso
          Padding(
            padding: const EdgeInsets.only(bottom: 46, left: 46, right: 46),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8A800), // Colore arancione/giallo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Inizia',
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