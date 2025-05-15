# Manorent App

Un'applicazione Flutter per il noleggio di auto.

## Configurazione del Server Flask

Questa applicazione utilizza un server Flask locale per fornire i dati delle auto. Per configurare il server:

1. **Assicurati di avere Python installato** sul tuo sistema.

2. **Installa le dipendenze necessarie**:
   ```bash
   pip install flask flask-restful flask-cors firebase-admin
   ```

3. **Avvia il server Flask**:
   ```bash
   python cars_database.py
   ```
   Il server sarà disponibile all'indirizzo `http://localhost:5000`.

4. **Endpoint disponibili**:
   - `GET /auto`: Restituisce tutte le auto disponibili
   - `GET /auto/{id}`: Restituisce i dettagli di una specifica auto
   - `POST /auto`: Aggiunge una nuova auto (richiede autenticazione)
   - `DELETE /auto/{id}`: Elimina un'auto (richiede autenticazione)

## Struttura dell'applicazione

L'applicazione Flutter è strutturata come segue:

- `lib/models/car_model.dart`: Definisce il modello dei dati delle auto
- `lib/services/car_service.dart`: Gestisce la comunicazione con il server Flask
- `lib/screens/home_page.dart`: Schermata principale con la lista delle auto e la navigazione a schede
- `lib/components/car_card.dart`: Componente riutilizzabile per visualizzare le informazioni di un'auto

## Funzionalità

- Visualizzazione delle auto disponibili dal server Flask
- Gestione dei preferiti (salvati localmente)
- Interfaccia con navigazione a schede (Esplora, Preferiti, Chat, Profilo)
- Dettagli completi delle auto

## Esecuzione dell'app

```bash
flutter pub get
flutter run
```

## Note per lo sviluppo

- Il server Flask deve essere in esecuzione prima di avviare l'applicazione Flutter.
- I preferiti sono gestiti localmente e non vengono sincronizzati con il server.
- Per modificare l'URL del server, modifica la variabile `baseUrl` nel file `lib/services/car_service.dart`.
