"""
Fraud Detection API - Backend Service
Handles SMS and Call fraud detection using fine-tuned transformer models
"""

from obs import ObsClient
import os
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime
from functools import wraps
import time

# == LOGGING SETUP ==
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# == CONFIG ==
ACCESS_KEY = os.getenv("OBS_ACCESS_KEY", "HPUAYTSYVFNEUTEDY5QA")
SECRET_KEY = os.getenv("OBS_SECRET_KEY", "Zsnl3aS2EboEla20TofUE4EPnot5qATqhkHxxu3M")
ENDPOINT = os.getenv("OBS_ENDPOINT", "https://obs.ap-southeast-3.myhuaweicloud.com")
BUCKET_NAME = os.getenv("OBS_BUCKET_NAME", "smgyusal")
REMOTE_FOLDER = "fine_tuned_model"
LOCAL_BASE_PATH = os.path.join(os.getcwd(), "fine_tuned_model")
MAX_TEXT_LENGTH = 1000
MODEL_MAX_LENGTH = 512

request_counts = {}
RATE_LIMIT = 100 

def rate_limit(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        ip = request.remote_addr
        current_time = time.time()
        
        if ip not in request_counts:
            request_counts[ip] = []
        
        request_counts[ip] = [req_time for req_time in request_counts[ip] 
                             if current_time - req_time < 60]
        
        if len(request_counts[ip]) >= RATE_LIMIT:
            return jsonify({
                "error": "Rate limit exceeded. Please try again later.",
                "retry_after": 60
            }), 429
        
        request_counts[ip].append(current_time)
        return f(*args, **kwargs)
    return decorated_function

def download_from_obs():
    """Download fine-tuned models from Huawei Cloud OBS"""
    try:
        logger.info("Starting download from OBS...")
        client = ObsClient(
            access_key_id=ACCESS_KEY,
            secret_access_key=SECRET_KEY,
            server=ENDPOINT
        )
        
        if not os.path.exists(LOCAL_BASE_PATH):
            os.makedirs(LOCAL_BASE_PATH)
            logger.info(f"Created directory: {LOCAL_BASE_PATH}")
        
        resp = client.listObjects(BUCKET_NAME, prefix=REMOTE_FOLDER)
        
        if not resp.body.contents:
            logger.error(f"No objects found in bucket {BUCKET_NAME} with prefix {REMOTE_FOLDER}")
            return False
        
        download_count = 0
        for obj in resp.body.contents:
            key = obj.key
            if key.endswith("/"):
                continue
            
            local_path = os.path.join(".", key)
            local_dir = os.path.dirname(local_path)
            
            if not os.path.exists(local_dir):
                os.makedirs(local_dir)
            
            client.getObject(BUCKET_NAME, key, downloadPath=local_path)
            logger.info(f"Downloaded: {key}")
            download_count += 1
        
        client.close()
        logger.info(f"Download complete. Total files: {download_count}")
        return True
        
    except Exception as e:
        logger.error(f"Error downloading from OBS: {str(e)}")
        return False

def ensure_models_exist():
    """Ensure models are downloaded and available"""
    sms_path = os.path.join(LOCAL_BASE_PATH, "sms_model")
    calls_path = os.path.join(LOCAL_BASE_PATH, "calls_model")
    
    sms_exists = os.path.exists(sms_path) and os.listdir(sms_path)
    calls_exists = os.path.exists(calls_path) and os.listdir(calls_path)
    
    if not sms_exists or not calls_exists:
        logger.info("Models not found locally. Downloading...")
        success = download_from_obs()
        if not success:
            logger.error("Failed to download models from OBS")
            return False
    else:
        logger.info("Models found locally. Skipping download.")
    
    return True

if not ensure_models_exist():
    logger.error("CRITICAL: Models not available. Server may not function properly.")

def load_models():
    """Load SMS and Calls models into memory"""
    try:
        sms_path = os.path.join(LOCAL_BASE_PATH, "sms_model")
        calls_path = os.path.join(LOCAL_BASE_PATH, "calls_model")
        
        logger.info("Loading SMS model...")
        sms_tokenizer = AutoTokenizer.from_pretrained(sms_path)
        sms_model = AutoModelForSequenceClassification.from_pretrained(sms_path)
        
        logger.info("Loading Calls model...")
        calls_tokenizer = AutoTokenizer.from_pretrained(calls_path)
        calls_model = AutoModelForSequenceClassification.from_pretrained(calls_path)
        
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        logger.info(f"Using device: {device}")
        
        sms_model.to(device)
        calls_model.to(device)
        
        sms_model.eval()
        calls_model.eval()
        
        logger.info("Models loaded successfully!")
        
        return {
            'sms_tokenizer': sms_tokenizer,
            'sms_model': sms_model,
            'calls_tokenizer': calls_tokenizer,
            'calls_model': calls_model,
            'device': device
        }
    except Exception as e:
        logger.error(f"Error loading models: {str(e)}")
        raise

# Load models globally
try:
    models = load_models()
    sms_tokenizer = models['sms_tokenizer']
    sms_model = models['sms_model']
    calls_tokenizer = models['calls_tokenizer']
    calls_model = models['calls_model']
    device = models['device']
except Exception as e:
    logger.error(f"Failed to load models: {str(e)}")
    sms_tokenizer = None
    sms_model = None
    calls_tokenizer = None
    calls_model = None
    device = None

def predict_text(text, tokenizer, model, model_type="unknown"):
    """Generic prediction function for text classification"""
    try:
        if not text or not isinstance(text, str):
            raise ValueError("Text must be a non-empty string")
        
        if len(text) > MAX_TEXT_LENGTH:
            raise ValueError(f"Text too long. Maximum length is {MAX_TEXT_LENGTH} characters")
        
        inputs = tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            padding=True,
            max_length=MODEL_MAX_LENGTH
        )
        
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        # Predict
        with torch.no_grad():
            outputs = model(**inputs)
            probs = torch.nn.functional.softmax(outputs.logits, dim=-1)
            label = torch.argmax(probs, dim=1).item()
            confidence = probs[0][label].item()
        
        result = {
            "prediction": int(label),
            "confidence": float(confidence),
            "is_fraud": bool(label == 1),
            "label_name": "spam" if label == 1 else "ham",
            "model_type": model_type,
            "timestamp": datetime.now().isoformat(),
            "text_length": len(text)
        }
        
        logger.info(f"{model_type} prediction: {result['label_name']} (confidence: {confidence:.2%})")
        return result
        
    except Exception as e:
        logger.error(f"Prediction error in {model_type}: {str(e)}")
        raise

# == FLASK APP ==
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web/mobile apps

# == HEALTH CHECK ==
@app.route('/', methods=['GET'])
def home():
    """Health check endpoint"""
    models_loaded = all([sms_tokenizer, sms_model, calls_tokenizer, calls_model])
    return jsonify({
        "status": "running",
        "message": "Fraud Detection API is operational",
        "models_loaded": models_loaded,
        "device": str(device),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/health', methods=['GET'])
def health():
    """Detailed health check"""
    return jsonify({
        "status": "healthy",
        "models": {
            "sms_model": sms_model is not None,
            "calls_model": calls_model is not None
        },
        "device": str(device),
        "cuda_available": torch.cuda.is_available(),
        "timestamp": datetime.now().isoformat()
    })

# == SMS PREDICTION ==
@app.route('/predict_sms', methods=['POST'])
@rate_limit
def predict_sms():
    """Predict if SMS message is fraudulent"""
    try:
        # Check if models are loaded
        if sms_model is None or sms_tokenizer is None:
            return jsonify({
                "error": "SMS model not loaded. Please contact administrator."
            }), 503
        
        # Get request data
        data = request.get_json()
        if not data:
            return jsonify({"error": "Request body must be JSON"}), 400
        
        text = data.get("text", "")
        
        if not text:
            return jsonify({"error": "Missing 'text' field in request"}), 400
        
        # Make prediction
        result = predict_text(text, sms_tokenizer, sms_model, "SMS")
        
        return jsonify(result), 200
        
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"Error in predict_sms: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

# == CALL PREDICTION ==
@app.route('/predict_call', methods=['POST'])
@rate_limit
def predict_call():
    """Predict if call transcript is fraudulent"""
    try:
        # Check if models are loaded
        if calls_model is None or calls_tokenizer is None:
            return jsonify({
                "error": "Calls model not loaded. Please contact administrator."
            }), 503
        
        # Get request data
        data = request.get_json()
        if not data:
            return jsonify({"error": "Request body must be JSON"}), 400
        
        text = data.get("text", "")
        
        if not text:
            return jsonify({"error": "Missing 'text' field in request"}), 400
        
        # Make prediction
        result = predict_text(text, calls_tokenizer, calls_model, "Call")
        
        return jsonify(result), 200
        
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"Error in predict_call: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

# == BATCH PREDICTION ==
@app.route('/predict_batch', methods=['POST'])
@rate_limit
def predict_batch():
    """Predict multiple texts at once"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "Request body must be JSON"}), 400
        
        texts = data.get("texts", [])
        model_type = data.get("type", "sms")  # 'sms' or 'call'
        
        if not texts or not isinstance(texts, list):
            return jsonify({"error": "Missing 'texts' array in request"}), 400
        
        if len(texts) > 10:
            return jsonify({"error": "Maximum 10 texts per batch"}), 400
        
        # Select model
        if model_type.lower() == "sms":
            tokenizer, model = sms_tokenizer, sms_model
        elif model_type.lower() == "call":
            tokenizer, model = calls_tokenizer, calls_model
        else:
            return jsonify({"error": "Invalid type. Use 'sms' or 'call'"}), 400
        
        if model is None or tokenizer is None:
            return jsonify({"error": f"{model_type} model not loaded"}), 503
        
        # Predict all texts
        results = []
        for i, text in enumerate(texts):
            try:
                result = predict_text(text, tokenizer, model, model_type.upper())
                result['index'] = i
                results.append(result)
            except Exception as e:
                results.append({
                    "index": i,
                    "error": str(e)
                })
        
        return jsonify({
            "results": results,
            "total": len(texts),
            "timestamp": datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error in predict_batch: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

# == ERROR HANDLERS ==
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(405)
def method_not_allowed(e):
    return jsonify({"error": "Method not allowed"}), 405

@app.errorhandler(500)
def internal_error(e):
    return jsonify({"error": "Internal server error"}), 500

# == WARM UP MODELS ==
def warm_up_models():
    """Warm up models with dummy predictions"""
    try:
        if sms_model and sms_tokenizer:
            logger.info("Warming up SMS model...")
            _ = predict_text("test message", sms_tokenizer, sms_model, "SMS")
        
        if calls_model and calls_tokenizer:
            logger.info("Warming up Calls model...")
            _ = predict_text("test call transcript", calls_tokenizer, calls_model, "Call")
        
        logger.info("Models warmed up successfully!")
    except Exception as e:
        logger.warning(f"Model warm-up failed: {str(e)}")

# == MAIN ==
if __name__ == '__main__':
    logger.info("=" * 50)
    logger.info("Starting Fraud Detection API Server")
    logger.info("=" * 50)
    
    # Warm up models
    warm_up_models()
    
    # Get configuration
    host = os.getenv("FLASK_HOST", "0.0.0.0")
    port = int(os.getenv("FLASK_PORT", 5000))
    debug = os.getenv("FLASK_DEBUG", "False").lower() == "true"
    
    logger.info(f"Server starting on {host}:{port}")
    logger.info(f"Debug mode: {debug}")
    
    # Run server
    app.run(host=host, port=port, debug=debug)
