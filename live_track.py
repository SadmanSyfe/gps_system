import socket
import json
import threading
from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import time
import os

HOST = '0.0.0.0'
TCP_PORT = 8081

WEB_SERVER_PORT = 5000


Maps_API_KEY = "THIS_NEEDS_TO_BE_CHANGED"


latest_location = None

location_lock = threading.Lock()


app = Flask(__name__, template_folder='.')
app.config['SECRET_KEY'] = 'livekey'
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')


@app.route('/')
def index():

    return render_template(
        'index.html',
        Maps_api_key=Maps_API_KEY
    )


@socketio.on('connect')
def handle_connect():
    with location_lock:

        if latest_location:
            emit('update_location', latest_location)


@socketio.on('disconnect')
def handle_disconnect():
    print('Web client disconnected from Socket.IO')


def start_tcp_server():
    global latest_location

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            s.bind((HOST, TCP_PORT))
        except OSError as e:
            os._exit(1)

        s.listen()
        print(f"Listening for GPS coordinates...")

        while True:
            conn, addr = s.accept()
            with conn:
                print(f"App succesffully connected")
                while True:
                    data = conn.recv(1024)
                    if not data:
                        print(f"Connection Closed")
                        break

                    try:
                        decoded_data = data.decode('utf-8')
                        json_strings = decoded_data.split('}{')
                        for i, line in enumerate(json_strings):
                            if i > 0:
                                line = '{' + line
                            if i < len(json_strings) - 1:
                                line = line + '}'
                            try:
                                json_data = json.loads(line)
                                latitude = json_data.get('latitude')
                                longitude = json_data.get('longitude')

                                if latitude is not None and longitude is not None:
                                    with location_lock:
                                        latest_location = {
                                            'latitude': latitude, 'longitude': longitude}

                                    socketio.emit(
                                        'update_location', latest_location)
                                else:
                                    print(
                                        f"Improper Data: {json_data}")
                            except json.JSONDecodeError as e:
                                print(
                                    f"JSON Decode Error: {e} - Data: {line}")
                    except UnicodeDecodeError as e:
                        print(
                            f"Decode Error : {e} - Raw Data: {data}")
                    except Exception as e:
                        print(
                            f"An unexpected error occurred during Flutter data processing: {e}")


if __name__ == "__main__":

    tcp_server_thread = threading.Thread(target=start_tcp_server)
    tcp_server_thread.daemon = True
    tcp_server_thread.start()

    print(f"\nWeb server starting on http://127.0.0.1:{WEB_SERVER_PORT}")
    print("Open this URL in your web browser to view the live Google Map.\n")

    socketio.run(app, host='0.0.0.0', port=WEB_SERVER_PORT,
                 allow_unsafe_werkzeug=True, debug=False)
