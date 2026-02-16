import socket, struct, numpy as np
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtWidgets

class LivePlotter(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PYNQ 3-Phase Digital Stream")
        self.setStyleSheet("background-color: white; color: black;")
        self.layout = QtWidgets.QHBoxLayout(self)
        
        # --- 1. Sidebar for Controls ---
        self.sidebar = QtWidgets.QVBoxLayout()
        
        # Stop/Pause Button
        self.is_paused = False
        self.btn_pause = QtWidgets.QPushButton("STOP / FREEZE")
        self.btn_pause.setStyleSheet("font-weight: bold; padding: 10px; background-color: #f0f0f0;")
        self.btn_pause.clicked.connect(self.toggle_pause)
        self.sidebar.addWidget(self.btn_pause)
        
        self.sidebar.addSpacing(20)
        
        # Time Window Slider (X-Axis Scaling)
        self.sidebar.addWidget(QtWidgets.QLabel("Time Window (Seconds):"))
        self.slider_window = QtWidgets.QSlider(QtCore.Qt.Horizontal)
        self.slider_window.setMinimum(1)
        self.slider_window.setMaximum(20)
        self.slider_window.setValue(5)
        self.sidebar.addWidget(self.slider_window)
        
        self.sidebar.addSpacing(20)

        # Checkboxes for Signal selection
        self.checks = []
        colors = ['red', 'green', 'blue']
        for i, color in enumerate(colors):
            c = QtWidgets.QCheckBox(f"Signal {i+1} ({color})")
            c.setChecked(True)
            self.checks.append(c)
            self.sidebar.addWidget(c)
        
        self.sidebar.addStretch()
        self.layout.addLayout(self.sidebar)

        # --- 2. Plot Area ---
        pg.setConfigOption('background', 'w')
        pg.setConfigOption('foreground', 'k')
        pg.setConfigOption('antialias', True)
        
        self.win = pg.GraphicsLayoutWidget()
        self.plot = self.win.addPlot(title="3-Phase Digital Step Plot")
        self.plot.setLabel('bottom', 'Time', 's')
        self.plot.showGrid(x=True, y=True, alpha=0.3)
        
        # Set Y-Axis to Auto-Range (Fixed logic)
        self.plot.enableAutoRange('y', True)
        
        # Create curves with Step Mode
        # Note: stepMode="center" requires len(X) == len(Y) + 1
        self.curves = [
            self.plot.plot(pen=pg.mkPen(color='r', width=2), stepMode="center"),
            self.plot.plot(pen=pg.mkPen(color='g', width=2), stepMode="center"),
            self.plot.plot(pen=pg.mkPen(color='b', width=2), stepMode="center")
        ]
        self.layout.addWidget(self.win)

        # --- 3. Data Buffers ---
        # Large buffer to hold enough data for the max slider range
        self.max_history = 2000 
        self.time_buffer = np.zeros(self.max_history)
        self.data_buffer = np.zeros((self.max_history, 3))

        # --- 4. Networking ---
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("0.0.0.0", 5005))
        self.sock.setblocking(False)

        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.update)
        self.timer.start(10) # 100Hz refresh rate

    def toggle_pause(self):
        self.is_paused = not self.is_paused
        self.btn_pause.setText("RESUME" if self.is_paused else "STOP / FREEZE")
        self.btn_pause.setStyleSheet(f"font-weight: bold; padding: 10px; background-color: {'#ffcccc' if self.is_paused else '#f0f0f0'};")

    def update(self):
        try:
            while True: 
                raw, _ = self.sock.recvfrom(20)
                if not self.is_paused:
                    # Unpack: 1 double (8) + 3 int32 (12)
                    t, s1, s2, s3 = struct.unpack('diii', raw)
                    self.time_buffer = np.roll(self.time_buffer, -1)
                    self.data_buffer = np.roll(self.data_buffer, -1, axis=0)
                    self.time_buffer[-1] = t
                    self.data_buffer[-1, :] = [s1, s2, s3]
        except (BlockingIOError, struct.error):
            pass
        
        if not self.is_paused:
            # Calculate X-axis range based on slider
            window_size = self.slider_window.value()
            current_time = self.time_buffer[-1]
            self.plot.setXRange(current_time - window_size, current_time, padding=0)

            # Prepare Step Data: X must be len(Y) + 1
            # We use the existing time buffer and add one extra projected point
            dt = 0.01 # assume 100Hz if buffer is empty
            if self.time_buffer[-1] != 0:
                dt = self.time_buffer[-1] - self.time_buffer[-2]
            
            x_stepped = np.append(self.time_buffer, self.time_buffer[-1] + dt)

            for i, curve in enumerate(self.curves):
                if self.checks[i].isChecked():
                    y = self.data_buffer[:, i]
                    curve.setData(x_stepped, y)
                    curve.show()
                else:
                    curve.hide()

if __name__ == "__main__":
    app = QtWidgets.QApplication([])
    demo = LivePlotter()
    demo.showMaximized()
    app.exec()
