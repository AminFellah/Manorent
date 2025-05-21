from flask import Flask, request, jsonify
from flask_restful import Api, Resource
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

# Inizializza l'app Flask
app = Flask(__name__)
CORS(app)
api = Api(app)

# Configura Firebase
cred = credentials.Certificate("manorentKey.json")  # Sostituisci con il tuo file JSON
firebase_admin.initialize_app(cred)
db = firestore.client()

# Collezione Firestore
CARS_COLLECTION = "auto"
COMMERCIAL_COLLECTION = "commerciali"

class CarResource(Resource):
    def get(self, car_id=None):
        """Recupera i dati di una singola auto o di tutte le auto."""
        if car_id:
            doc = db.collection(CARS_COLLECTION).document(car_id).get()
            if doc.exists:
                return jsonify(doc.to_dict())
            return {"message": "Car not found"}, 404
        
        cars = [doc.to_dict() for doc in db.collection(CARS_COLLECTION).stream()]
        return jsonify(cars)

    def post(self):
        """Aggiunge una nuova auto al database."""
        data = request.get_json()
        car_id = str(data.get("id"))  # Converte l'ID in stringa per Firestore
        if not car_id:
            return {"error": "ID is required"}, 400
        db.collection(CARS_COLLECTION).document(car_id).set(data)
        return {"message": f"Car {car_id} added successfully"}, 201

    def delete(self, car_id):
        """Elimina un'auto dal database."""
        db.collection(CARS_COLLECTION).document(car_id).delete()
        return {"message": f"Car {car_id} deleted successfully"}, 200

class CommercialResource(Resource):
    def get(self, car_id=None):
        """Recupera i dati di un singolo veicolo commerciale o di tutti i veicoli commerciali."""
        if car_id:
            doc = db.collection(COMMERCIAL_COLLECTION).document(car_id).get()
            if doc.exists:
                return jsonify(doc.to_dict())
            return {"message": "Commercial vehicle not found"}, 404
        
        vehicles = [doc.to_dict() for doc in db.collection(COMMERCIAL_COLLECTION).stream()]
        return jsonify(vehicles)

    def post(self):
        """Aggiunge un nuovo veicolo commerciale al database."""
        data = request.get_json()
        vehicle_id = str(data.get("id"))  # Converte l'ID in stringa per Firestore
        if not vehicle_id:
            return {"error": "ID is required"}, 400
        db.collection(COMMERCIAL_COLLECTION).document(vehicle_id).set(data)
        return {"message": f"Commercial vehicle {vehicle_id} added successfully"}, 201

    def delete(self, car_id):
        """Elimina un veicolo commerciale dal database."""
        db.collection(COMMERCIAL_COLLECTION).document(car_id).delete()
        return {"message": f"Commercial vehicle {car_id} deleted successfully"}, 200

# Route
api.add_resource(CarResource, "/auto", "/auto/<string:car_id>")
api.add_resource(CommercialResource, "/commerciali", "/commerciali/<string:car_id>")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 