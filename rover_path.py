from bokeh.plotting import figure, curdoc
from bokeh.models import ColumnDataSource
from bokeh.layouts import column
from bokeh.server.server import Server
import threading
import socket
import json

source = ColumnDataSource(data=dict(x=[], y=[]))

p = figure(title="Rover Path", width=800, height=600)
p.line(x='x', y='y', source=source, line_width=2)
p.circle(x='x', y='y', source=source, size=5, color='red')

curdoc().add_root(column(p))


def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('0.0.0.0', 8080))
    server_socket.listen(1)
    print("Waiting for connection...")

    client_socket, addr = server_socket.accept()
    print("Client connected:", addr)

    while True:
        data = client_socket.recv(1024)
        if not data:
            break
        try:
            message = data.decode()
            location = json.loads(message)
            lat = location['latitude']
            lon = location['longitude']

            # Update the ColumnDataSource from thread-safe callback
            curdoc().add_next_tick_callback(
                lambda: source.stream({'x': [lon], 'y': [lat]}))

        except Exception as e:
            print("Error:", e)

    client_socket.close()
    server_socket.close()


# Start the socket server in a background thread
threading.Thread(target=start_server, daemon=True).start()
