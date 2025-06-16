import socket
import json
from bokeh.client import push_session
from bokeh.document import Document

from bokeh.application import Application
from bokeh.application.handlers import FunctionHandler
from vis import update_location


server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


server_address = ('0.0.0.0', 8080)
server_socket.bind(server_address)

server_socket.listen(5)
print(f"Listening for connections")
client_socket, client_address = server_socket.accept()
while True:
    try:
        data = client_socket.recv(1024)
        if not data:
            break
        message = data.decode()
        try:
            location = json.loads(message)
            lat = location['latitude']
            lon = location['longitude']
            update_location(lat,lon)
            print(f"Received data: {location}")
        except json.JSONDecodeError:
            continue

    except ConnectionResetError:
        print("Client disconnected.")
        break

client_socket.close()
server_socket.close()