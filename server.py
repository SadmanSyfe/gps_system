import socket
import json


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
            print(f"Received data: {location}")
        except json.JSONDecodeError:
            continue

    except ConnectionResetError:
        print("Client disconnected.")
        break

client_socket.close()
server_socket.close()