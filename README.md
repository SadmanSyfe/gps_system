# 📡 Flutter GPS Location Broadcaster (LAN Socket)

This project is a real-time GPS location tracking system that uses a **Flutter app** to periodically fetch device GPS coordinates and send them over a **raw TCP socket** to a **Python server** on the same LAN. The Python server then broadcasts these coordinates to a web interface via **Socket.IO**, displaying the live location on a **Google Map**.

---

## 📑 Project Overview

- 📱 **Flutter app**:
    - Takes **IP address** and **TCP port number** as input.
    - Connects to a TCP socket server.
    - Starts a **timer** that fetches the current GPS position every 5 seconds.
    - Sends the latitude and longitude as a JSON object via a raw socket connection.

- 🐍 **Python server**:
    - Listens for incoming TCP connections from the Flutter app on a specified TCP port.
    - Receives location data in JSON format.
    - Uses **Flask** and **Socket.IO** to serve a web page that displays a live Google Map.
    - When new location data is received from the Flutter app, it updates a global `latest_location` variable and emits this data to all connected web clients via Socket.IO, allowing for real-time tracking on the map.

- 🌐 **Web Interface (index.html)**:
    - A simple HTML page that embeds a Google Map.
    - Uses JavaScript and **Socket.IO** to connect to the Python server.
    - Receives live location updates from the server and dynamically updates a marker on the Google Map, also drawing a trace path of the device's movement.

---

## 📦 Tech Stack

- **Flutter** (Dart)
- **Geolocator** package (for GPS)
- **Python 3**
- **Raw TCP sockets**
- **Flask** (Python web framework)
- **Flask-SocketIO** (for real-time web communication)
- **Google Maps JavaScript API**





---

## 🚀 How to Run

### 🔹 1. Obtain a Google Maps API Key

You'll need a Google Maps JavaScript API key to display the map.
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one.
3. Enable the **Maps JavaScript API** for your project.
4. Create API credentials (an API key).
5. **Important**: Secure your API key by restricting it to your domain or IP address.

### 🔹 2. Python Server

1. **Save the Python script**: Save the provided Python code as `live_track.py`.
2. **Save the HTML file**: Save the provided HTML code as `index.html` in the same directory as `live_track.py`.
3. **Install Python dependencies**:
   ```bash
   pip install Flask Flask-SocketIO
   ```
4. **Update Google Maps API Key**: Open live_track.py and replace "THIS_NEEDS_TO_BE_CHANGED" with your actual Google Maps API Key:
```python
Maps_API_KEY = "THIS_NEEDS_TO_BE_CHANGED"
```
5. **Run the server**:
```bash
python live_track.py
```
The server will start listening for TCP connections on 0.0.0.0:8081 (default TCP port) and serve the web interface on http://127.0.0.1:5000 (default web server port). The console will display the URL for the web interface.
### 🔹 3. Flutter App

1.  **Install Flutter & dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run on your mobile device**:
    ```bash
    flutter run
    ```
    Ensure your mobile device has location permissions granted for the app.
3.  **Enter server details**: In the Flutter app, enter the **LAN IP address** of the machine running the Python server and the **TCP port number** (default: `8081`).
4.  **Start broadcasting**: Press the **Start** button to begin broadcasting location data every 5 seconds.
### 🔹 4. View Live Tracking

1.  Open a web browser on your computer (or any device on the same LAN as the Python server) and navigate to the URL printed in the Python server's console (e.g., `http://127.0.0.1:5000`).
2.  You should see a Google Map, and as the Flutter app sends location data, a marker will appear and update in real-time, tracing the device's path.