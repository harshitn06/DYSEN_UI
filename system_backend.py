import platform
import socket
import time

import psutil

from PySide6.QtCore import QObject, Signal, Slot, QTimer


class SystemBackend(QObject):

    # CPU, RAM, SWAP
    systemMetricsChanged = Signal(float, float, float)

    # Network
    networkChanged = Signal(float, float, float, float)
    # rx_bytes_sec, tx_bytes_sec, rx_mbps, tx_mbps

    # Disk
    diskChanged = Signal(float, float)
    # read_bytes_sec, write_bytes_sec

    # Process list + total system process count
    processesChanged = Signal("QVariantList", int)

    # Static/runtime system information
    systemInfoChanged = Signal(
        str, str, str, str, int
    )
    # hostname, kernel, ip, interface, cpu_cores

    # Temperature
    temperatureChanged = Signal(float, str, bool)
    # temperature, label, available

    def __init__(self):
        super().__init__()

        self._last_net = None
        self._last_net_time = None

        self._last_disk = None
        self._last_disk_time = None

        self._system_timer = QTimer(self)
        self._system_timer.setInterval(1000)
        self._system_timer.timeout.connect(self.update_system)
        self._system_timer.start()

        self._network_timer = QTimer(self)
        self._network_timer.setInterval(500)
        self._network_timer.timeout.connect(self.update_network)
        self._network_timer.start()

        self._disk_timer = QTimer(self)
        self._disk_timer.setInterval(500)
        self._disk_timer.timeout.connect(self.update_disk)
        self._disk_timer.start()

        self._process_timer = QTimer(self)
        self._process_timer.setInterval(1000)
        self._process_timer.timeout.connect(self.update_processes)
        self._process_timer.start()

        self._info_timer = QTimer(self)
        self._info_timer.setInterval(5000)
        self._info_timer.timeout.connect(self.update_system_info)
        self._info_timer.start()

        # Initialise psutil CPU sampler.
        psutil.cpu_percent(interval=None)

        self.update_system_info()
        self.update_system()
        self.update_network()
        self.update_disk()
        self.update_processes()

    # =========================================================
    # SYSTEM
    # =========================================================

    @Slot()
    def update_system(self):
        try:
            cpu = float(psutil.cpu_percent(interval=None))
            ram = float(psutil.virtual_memory().percent)
            swap = float(psutil.swap_memory().percent)

            self.systemMetricsChanged.emit(
                cpu,
                ram,
                swap
            )

            self.update_temperature()

        except Exception as exc:
            print("DYSEN SYSTEM:", exc)

    # =========================================================
    # NETWORK
    # =========================================================

    @Slot()
    def update_network(self):
        try:
            counters = psutil.net_io_counters()
            now = time.monotonic()

            if self._last_net is None:
                self._last_net = counters
                self._last_net_time = now

                self.networkChanged.emit(
                    0.0,
                    0.0,
                    0.0,
                    0.0
                )
                return

            elapsed = max(
                now - self._last_net_time,
                0.001
            )

            rx = max(
                counters.bytes_recv -
                self._last_net.bytes_recv,
                0
            ) / elapsed

            tx = max(
                counters.bytes_sent -
                self._last_net.bytes_sent,
                0
            ) / elapsed

            rx_mbps = rx * 8 / 1_000_000
            tx_mbps = tx * 8 / 1_000_000

            self._last_net = counters
            self._last_net_time = now

            self.networkChanged.emit(
                float(rx),
                float(tx),
                float(rx_mbps),
                float(tx_mbps)
            )

        except Exception as exc:
            print("DYSEN NETWORK:", exc)

    # =========================================================
    # DISK I/O
    # =========================================================

    @Slot()
    def update_disk(self):
        try:
            counters = psutil.disk_io_counters()
            now = time.monotonic()

            if counters is None:
                return

            if self._last_disk is None:
                self._last_disk = counters
                self._last_disk_time = now

                self.diskChanged.emit(
                    0.0,
                    0.0
                )
                return

            elapsed = max(
                now - self._last_disk_time,
                0.001
            )

            read_speed = max(
                counters.read_bytes -
                self._last_disk.read_bytes,
                0
            ) / elapsed

            write_speed = max(
                counters.write_bytes -
                self._last_disk.write_bytes,
                0
            ) / elapsed

            self._last_disk = counters
            self._last_disk_time = now

            self.diskChanged.emit(
                float(read_speed),
                float(write_speed)
            )

        except Exception as exc:
            print("DYSEN DISK:", exc)

    # =========================================================
    # PROCESSES
    # =========================================================

    @Slot()
    def update_processes(self):
        try:
            rows = []

            total = 0

            for proc in psutil.process_iter(
                [
                    "name",
                    "cpu_percent",
                    "memory_info",
                    "status"
                ],
                ad_value=None
            ):
                try:
                    total += 1

                    info = proc.info

                    name = (
                        info.get("name")
                        or "unknown"
                    )

                    cpu = float(
                        info.get("cpu_percent")
                        or 0.0
                    )

                    memory = info.get(
                        "memory_info"
                    )

                    rss = (
                        memory.rss
                        if memory is not None
                        else 0
                    )

                    if rss >= 1024 ** 3:
                        mem = f"{rss / (1024 ** 3):.1f}G"
                    else:
                        mem = f"{rss / (1024 ** 2):.0f}M"

                    rows.append([
                        str(proc.pid),
                        name,
                        f"{cpu:.1f}%",
                        mem
                    ])

                except (
                    psutil.NoSuchProcess,
                    psutil.AccessDenied,
                    psutil.ZombieProcess
                ):
                    continue

            rows.sort(
                key=lambda row: float(
                    row[2].rstrip("%")
                ),
                reverse=True
            )

            # Keep HUD compact.
            rows = rows[:8]

            self.processesChanged.emit(
                rows,
                total
            )

        except Exception as exc:
            print("DYSEN PROCESSES:", exc)

    # =========================================================
    # SYSTEM INFO
    # =========================================================

    @Slot()
    def update_system_info(self):
        try:
            hostname = socket.gethostname()
            kernel = platform.release()
            cores = int(
                psutil.cpu_count(
                    logical=True
                ) or 0
            )

            interface = "N/A"
            ip = "N/A"

            for name, stats in psutil.net_if_stats().items():
                if not stats.isup:
                    continue

                if name == "lo":
                    continue

                interface = name

                addresses = psutil.net_if_addrs().get(
                    name,
                    []
                )

                for addr in addresses:
                    if addr.family == socket.AF_INET:
                        ip = addr.address
                        break

                break

            self.systemInfoChanged.emit(
                hostname,
                kernel,
                ip,
                interface,
                cores
            )

        except Exception as exc:
            print("DYSEN INFO:", exc)

    # =========================================================
    # TEMPERATURE
    # =========================================================

    @Slot()
    def update_temperature(self):
        try:
            temps = psutil.sensors_temperatures()

            if not temps:
                self.temperatureChanged.emit(
                    0.0,
                    "N/A",
                    False
                )
                return

            for group, sensors in temps.items():
                for sensor in sensors:
                    if sensor.current is not None:
                        label = (
                            sensor.label
                            or group
                            or "TEMP"
                        )

                        self.temperatureChanged.emit(
                            float(sensor.current),
                            label,
                            True
                        )
                        return

            self.temperatureChanged.emit(
                0.0,
                "N/A",
                False
            )

        except Exception:
            self.temperatureChanged.emit(
                0.0,
                "N/A",
                False
            )

    # =========================================================
    # UPTIME
    # =========================================================

    @Slot(result=float)
    def uptime(self):
        try:
            return float(
                time.time() - psutil.boot_time()
            )
        except Exception:
            return 0.0

    def close(self):
        self._system_timer.stop()
        self._network_timer.stop()
        self._disk_timer.stop()
        self._process_timer.stop()
        self._info_timer.stop()
