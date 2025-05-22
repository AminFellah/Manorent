import os
import json
from flask import Flask
import firebase_admin
from firebase_admin import credentials

app = Flask(__name__)

# Recupera JSON da variabile d'ambiente
firebase_config = json.loads(os.environ["FIREBASE_CONFIG"])
cred = credentials.Certificate(firebase_config)
firebase_admin.initialize_app(cred)
