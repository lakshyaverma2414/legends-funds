import os
import socket
import uuid
import requests
import pyotp
import json

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def get_mac_address():
    return ':'.join(['{:02x}'.format((uuid.getnode() >> elements) & 0xff) 
                     for elements in range(0,2*6,2)][::-1])

def get_public_address():
    ip=requests.get('https://checkip.amazonaws.com').text.strip()
    return ip

def load_jwt_token(file_path='data/jwt_tokens/jwt.json'):
    """Load JWT token from jwt.json file"""
    with open(file_path, 'r') as file:
        jwt_data = json.load(file)
    jwt_token = jwt_data['data']['jwtToken']
    return jwt_token

def load_feed_token(file_path='data/jwt_tokens/jwt.json'):
    with open(file_path, 'r') as file:
        feed_token = json.load(file)
    feed_token = feed_token['data']['feedToken']
    return feed_token

# ============================================
# REPLACE THESE WITH YOUR ACTUAL CREDENTIALS
# ============================================

# Get your API key from Angel One Developer Portal
apiKey = 'YOUR_API_KEY_HERE'

# Your TOTP secret from Angel One
totp = 'YOUR_TOTP_SECRET_HERE'

# Your Angel One user ID
userid = 'YOUR_USER_ID_HERE'

# Your Angel One PIN
pin = 'YOUR_PIN_HERE'

# ============================================
# DO NOT MODIFY BELOW THIS LINE
# ============================================

local_ip = get_local_ip()
public_ip = get_public_address()
mac_address = get_mac_address()
api_key = apiKey

vaild_totp = pyotp.TOTP(totp).now()

headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-UserType': 'USER',
    'X-SourceID': 'WEB',
    'X-ClientLocalIP': local_ip,
    'X-ClientPublicIP': public_ip,
    'X-MACAddress': mac_address,
    'X-PrivateKey': api_key
}

# OneSignal configuration (optional - for notifications)
APP_ID = 'YOUR_ONESIGNAL_APP_ID'
API_KEY_ONE_SIGNAL = 'YOUR_ONESIGNAL_API_KEY'

# Logging configuration
LOG_LEVEL = "INFO"
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# OneSignal configuration
ONESIGNAL_APP_ID = APP_ID
ONESIGNAL_API_KEY = API_KEY_ONE_SIGNAL

# Token refresh configuration
TOKEN_REFRESH_TIME = "08:30"
TOKEN_CHECK_INTERVAL = 6

# Web server configuration
WEB_SERVER_HOST = "0.0.0.0"
WEB_SERVER_PORT = 5000
