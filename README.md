# gps_system
# 📡 Flutter GPS Location Broadcaster (LAN Socket)

This project is a simple GPS location tracking system that uses a **Flutter app** to periodically fetch device GPS coordinates and send them over a **raw TCP socket** to a **Python server** on the same LAN.

---

## 📑 Project Overview

- 📱 **Flutter app**:
  - Takes **IP address** and **port number** as input.
  - Connects to a TCP socket server.
  - Starts a **timer** that fetches the current GPS position every 5 seconds.
  - Sends the latitude and longitude as a JSON object via a raw socket connection.

- 🐍 **Python server**:
  - Listens for incoming TCP connections.
  - Receives location data in JSON format.
  - Decodes and prints the data to the console.

---

## 📦 Tech Stack

- **Flutter** (Dart)
- **Geolocator** package (for GPS)
- **Python 3**
- **Raw TCP sockets**

---

## 📸 Screenshots

| Flutter App (Mockup) | Python Server (Console Output) |
|:---------------------|:-----------------------------|
| `IP:` and `Port:` input fields + Start button | JSON location data being printed |

---

## 🚀 How to Run

### 🔹 Flutter App

1. Install Flutter & dependencies:

```bash
flutter pub get
```
2. Run on your mobile device (with location permission):

```bash
flutter run
```
3. Enter the **LAN IP address** and **port** of the Python server.

4. Press the **Start** button to begin broadcasting location data every 5 seconds.

---

### 🔹 Python Server

1. Run the server:
```bash
python server.py
```
2.The server will listen for incoming connections and print any received JSON location data.
