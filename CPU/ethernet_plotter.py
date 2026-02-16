import socket
import numpy as np
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtWidgets

# Setup Socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", 5005))
sock.setblocking(False)

# Setup Window
app = QtWidgets.QApplication([])
win = pg.GraphicsLayoutWidget(show=True, title="PYNQ Real-time Stream")
plot = win.addPlot(title="3-Phase Sine Stream")
curves = [plot.plot(pen='r'), plot.plot(pen='g'), plot.plot(pen='b')]
data_buffer = np.zeros((100, 3))

def update():
    global data_buffer
    try:
        while True: # Read all pending packets
            raw_data, addr = sock.recvfrom(12) # 3 * int32 (4 bytes)
            new_vals = np.frombuffer(raw_data, dtype=np.int32)
            data_buffer = np.roll(data_buffer, -1, axis=0)
            data_buffer[-1, :] = new_vals
            # Inside the update() function on your PC:
            print(f"Received data from {addr}!") # Add this line

    except BlockingIOError:
        pass
    
    for i in range(3):
        curves[i].setData(data_buffer[:, i])

timer = QtCore.QTimer()
timer.timeout.connect(update)
timer.start(20) # 50Hz refresh rate

if __name__ == '__main__':
    QtWidgets.QApplication.instance().exec()
