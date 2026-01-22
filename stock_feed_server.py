import json
import struct
import logging
import websocket
import urllib.parse
import threading
import time
import os
from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime
import credentials

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Flask app
app = Flask(__name__)
CORS(app)

# Store live stock data
live_stock_data = {
    '1333': {'name': 'HDFC', 'price': 0, 'change': 0, 'history': []},
    '3045': {'name': 'SBIN', 'price': 0, 'change': 0, 'history': []},
    '4963': {'name': 'ICICI', 'price': 0, 'change': 0, 'history': []},
    '1922': {'name': 'KOTAK', 'price': 0, 'change': 0, 'history': []},
    '5900': {'name': 'AXIS', 'price': 0, 'change': 0, 'history': []}
}

def load_tokens_from_file():
    """Load tokens from jwt.json file"""
    try:
        jwt_file = 'data/jwt_tokens/jwt.json'
        if not os.path.exists(jwt_file):
            logger.error(f"JWT file not found: {jwt_file}")
            logger.error("Please run: python generate_token.py")
            return None, None, None
        
        with open(jwt_file, 'r') as f:
            data = json.load(f)
        
        jwt_token = data['data']['jwtToken']
        feed_token = data['data']['feedToken']
        totp = credentials.vaild_totp
        
        logger.info("✓ Tokens loaded from file")
        return jwt_token, feed_token, totp
    except Exception as e:
        logger.error(f"Failed to load tokens: {e}")
        return None, None, None

class SmartAPIWebSocket:
    def __init__(self):
        self.ws = None
        self.feed_token = None
        self.auth_token = None
        self.totp = None
        
    def load_tokens(self):
        """Load tokens from credentials"""
        try:
            auth_token, feed_token, totp = load_tokens_from_file()
            
            if not auth_token or not feed_token:
                logger.error("Cannot load tokens")
                return False
            
            self.auth_token = auth_token
            self.feed_token = feed_token
            self.totp = totp
            logger.info("Tokens loaded successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to load tokens: {e}")
            return False
    
    def parse_binary_data(self, binary_data):
        """Parse binary data from WebSocket"""
        try:
            # Extract token (bytes 2-27)
            token = ""
            for b in binary_data[2:27]:
                if chr(b) == '\x00':
                    break
                token += chr(b)
            
            # Extract LTP (bytes 43-51, Little Endian)
            ltp_bytes = binary_data[43:51]
            ltp_in_paise = struct.unpack('<q', ltp_bytes)[0]
            ltp = ltp_in_paise / 100.0
            
            return token, ltp
        except Exception as e:
            logger.error(f"Error parsing binary data: {e}")
            return None, None
    
    def update_stock_data(self, token, price):
        """Update stock data with new price"""
        if token in live_stock_data:
            old_price = live_stock_data[token]['price']
            live_stock_data[token]['price'] = price
            
            # Calculate change percentage
            if old_price > 0:
                change = ((price - old_price) / old_price) * 100
                live_stock_data[token]['change'] = round(change, 2)
            
            # Store price history (last 50 points)
            history = live_stock_data[token]['history']
            history.append({'time': datetime.now().isoformat(), 'price': price})
            if len(history) > 50:
                history.pop(0)
            
            logger.info(f"{live_stock_data[token]['name']}: ₹{price:.2f} ({live_stock_data[token]['change']:+.2f}%)")
    
    def on_message(self, ws, message):
        """Handle WebSocket message"""
        try:
            if isinstance(message, bytes):
                token, price = self.parse_binary_data(message)
                if token and price:
                    self.update_stock_data(token, price)
        except Exception as e:
            logger.error(f"Error in on_message: {e}")
    
    def on_error(self, ws, error):
        logger.error(f"WebSocket error: {error}")
    
    def on_close(self, ws, close_status_code, close_msg):
        logger.info(f"WebSocket closed: {close_status_code}")
    
    def on_open(self, ws):
        logger.info("WebSocket connection opened")
        
        # Subscribe to 5 stocks (LTP mode)
        subscribe_request = {
            "correlationID": "stock_feed_001",
            "action": 1,
            "params": {
                "mode": 1,  # LTP mode
                "tokenList": [
                    {
                        "exchangeType": 1,  # NSE
                        "tokens": ["1333", "3045", "4963", "1922", "5900"]
                    }
                ]
            }
        }
        ws.send(json.dumps(subscribe_request))
        logger.info("Subscribed to 5 stocks")
        
        # Start heartbeat
        def heartbeat():
            while True:
                try:
                    time.sleep(30)
                    ws.send("ping")
                except:
                    break
        
        threading.Thread(target=heartbeat, daemon=True).start()
    
    def connect(self):
        """Connect to Smart API WebSocket"""
        if not self.load_tokens():
            logger.error("Cannot connect without tokens")
            return
        
        params = {
            "feedToken": self.feed_token,
            "authToken": self.auth_token,
            "totp": self.totp
        }
        query_string = urllib.parse.urlencode(params)
        ws_url = f"wss://smartapisocket.angelone.in/smart-stream?{query_string}"
        
        self.ws = websocket.WebSocketApp(
            ws_url,
            on_open=self.on_open,
            on_message=self.on_message,
            on_error=self.on_error,
            on_close=self.on_close
        )
        
        logger.info("Starting WebSocket connection...")
        self.ws.run_forever()

# Flask routes
@app.route('/api/stocks', methods=['GET'])
def get_stocks():
    """Get current stock data"""
    return jsonify(live_stock_data)

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "running", "timestamp": datetime.now().isoformat()})

def run_flask():
    """Run Flask server"""
    logger.info("Starting Flask server on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)

def run_websocket():
    """Run WebSocket connection"""
    while True:
        try:
            ws_client = SmartAPIWebSocket()
            ws_client.connect()
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            logger.info("Reconnecting in 5 seconds...")
            time.sleep(5)

if __name__ == '__main__':
    # Start Flask in separate thread
    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()
    
    # Start WebSocket in main thread
    logger.info("Stock Feed Server Starting...")
    run_websocket()
