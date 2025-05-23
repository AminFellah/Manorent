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
COMMERCIAL_COLLECTION = "autocarri"
BUSINESS_COLLECTION = "business"

class BusinessResource(Resource):
    def get(self, car_id=None):
        """Recupera i dati di una singola auto o di tutte le auto."""
        if car_id:
            doc = db.collection(BUSINESS_COLLECTION).document(car_id).get()
            if doc.exists:
                return jsonify(doc.to_dict())
            return {"message": "Car not found"}, 404
        
        cars = [doc.to_dict() for doc in db.collection(BUSINESS_COLLECTION).stream()]
        return jsonify(cars)

    def post(self):
        """Aggiunge una nuova auto al database."""
        data = request.get_json()
        car_id = str(data.get("id"))  # Converte l'ID in stringa per Firestore
        if not car_id:
            return {"error": "ID is required"}, 400
        db.collection(BUSINESS_COLLECTION).document(car_id).set(data)
        return {"message": f"Business Car {car_id} added successfully"}, 201

    def delete(self, car_id):
        """Elimina un'auto dal database."""
        db.collection(BUSINESS_COLLECTION).document(car_id).delete()
        return {"message": f"Business car {car_id} deleted successfully"}, 200

# Route
api.add_resource(BusinessResource, "/business", "/business/<string:car_id>")


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

# Route
api.add_resource(CarResource, "/auto", "/auto/<string:car_id>")

class CommercialResource(Resource):
    def get(self, car_id=None):
        """Recupera i dati di una singola auto o di tutte le auto."""
        if car_id:
            doc = db.collection(COMMERCIAL_COLLECTION).document(car_id).get()
            if doc.exists:
                return jsonify(doc.to_dict())
            return {"message": "Commercial car not found"}, 404
        
        cars = [doc.to_dict() for doc in db.collection(COMMERCIAL_COLLECTION).stream()]
        return jsonify(cars)

    def post(self):
        """Aggiunge una nuova auto al database."""
        data = request.get_json()
        car_id = str(data.get("id"))  # Converte l'ID in stringa per Firestore
        if not car_id:
            return {"error": "ID is required"}, 400
        db.collection(COMMERCIAL_COLLECTION).document(car_id).set(data)
        return {"message": f"Commercial car {car_id} added successfully"}, 201

    def delete(self, car_id):
        """Elimina un'auto dal database."""
        db.collection(COMMERCIAL_COLLECTION).document(car_id).delete()
        return {"message": f"Commercial car {car_id} deleted successfully"}, 200

# Route
api.add_resource(CommercialResource, "/autocarri", "/autocarri/<string:car_id>")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

