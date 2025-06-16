from bokeh.client import pull_session
from bokeh.models import ColumnDataSource
import json
import socket
import math

# Function to convert lat/lon to Web Mercator


def wgs84_to_web_mercator(lon, lat):
    k = 6378137
    x = lon * (k * math.pi / 180.0)
    y = math.log(math.tan((90 + lat) * math.pi / 360.0)) * k
    return x, y


# Connect to the Bokeh server session
session = pull_session(url="http://localhost:5006/vis")  # port 5006 by default
print(session)
source = session.document.select_one({'type': ColumnDataSource})

# Set up TCP server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('0.0.0.0', 8080))
server_socket.listen(1)

print("Listening for rover connections...")

client_socket, _ = server_socket.accept()
print("Rover connected.")

while True:
    try:
        data = client_socket.recv(1024)
        if not data:
            break

        message = data.decode()
        try:
            location = json.loads(message)
            print(f"Received data: {location}")

            lat = location.get('latitude')
            lon = location.get('longitude')

            if lat is not None and lon is not None:
                x, y = wgs84_to_web_mercator(lon, lat)
                new_data = dict(lat=[y], lon=[x])
                source.stream(new_data)
                session.push()  # Push the updated data to the client

        except json.JSONDecodeError:
            continue

    except ConnectionResetError:
        print("Client disconnected.")
        break

client_socket.close()
server_socket.close()
