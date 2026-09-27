import os
import pty
import select
import threading
import time

import psutil

from PySide6.QtCore import QObject, Signal, Slot, QTimer

from terminal_parser import TerminalScreen


class TerminalBackend(QObject):

    outputReceived = Signal(str)

    # Parsed terminal screen for the future renderer.
    screenChanged = Signal(str, int, int)
    cursorChanged = Signal(int, int, bool)
    exited = Signal(int)

    # Live system telemetry
    systemMetricsChanged = Signal(float, float, float, float)
    processesChanged = Signal("QVariantList", int)

    def __init__(self):
        super().__init__()

        self.pid = -1
        self.fd = -1
        self.running = False

        # VT terminal screen state.
        self.terminalCols = 120
        self.terminalRows = 32

        self.screen = TerminalScreen(
            cols=self.terminalCols,
            rows=self.terminalRows,
            scrollback=50000
        )

        self.start_shell()

        # System telemetry timer.
        # 250 ms = 4 updates/sec; enough for a HUD without
        # hammering the CPU or QML renderer.
        self.metricsTimer = QTimer(self)
        self.metricsTimer.setInterval(250)
        self.metricsTimer.timeout.connect(self.update_metrics)
        self.metricsTimer.start()

        # Process monitor updates independently from system metrics.
        # 500 ms keeps the process list live without unnecessary QML work.
        self.processTimer = QTimer(self)
        self.processTimer.setInterval(500)
        self.processTimer.timeout.connect(self.update_processes)
        self.processTimer.start()

        # Prime CPU measurement.
        psutil.cpu_percent(interval=None)

    def start_shell(self):

        pid, fd = pty.fork()

        if pid == 0:

            # DYSEN uses a clean bash session instead of inheriting
            # the developer's zsh theme/configuration.
            shell = "/bin/bash"

            os.environ["TERM"] = "xterm-256color"
            os.environ["COLORTERM"] = "true"
            os.environ["TERM_PROGRAM"] = "DYSEN"

            # Public-facing DYSEN shell identity.
            os.environ["PS1"] = "DYSEN > "
            os.environ["PROMPT_COMMAND"] = ""

            os.execv(
                shell,
                [
                    shell,
                    "--noprofile",
                    "--norc",
                    "-i"
                ]
            )

        self.pid = pid
        self.fd = fd
        self.running = True

        thread = threading.Thread(
            target=self.read_loop,
            daemon=True
        )

        thread.start()

    @Slot(result=str)
    def get_screen_text(self):
        return "\n".join(
            self.screen.rows_as_text()
        )

    def visible_screen_text(self):
        return "\n".join(
            "".join(cell.char for cell in row)
            for row in self.screen.grid
        )

    def screen_snapshot(self):

        import json

        rows = []

        for row in self.screen.grid:

            cells = []

            for cell in row:

                cells.append([
                    cell.char,
                    cell.fg,
                    cell.bg,
                    bool(cell.bold),
                    bool(cell.dim),
                    bool(cell.underline)
                ])

            rows.append(cells)

        return json.dumps(
            rows,
            ensure_ascii=False,
            separators=(",", ":")
        )

    def read_loop(self):


        while self.running:

            try:

                ready, _, _ = select.select(
                    [self.fd],
                    [],
                    [],
                    0.05
                )

                if not ready:
                    continue

                data = os.read(
                    self.fd,
                    16384
                )

                if not data:
                    break

                text = data.decode(
                    "utf-8",
                    errors="replace"
                )

                # Keep existing raw output for the current
                # terminal while the renderer is migrated.
                self.outputReceived.emit(text)

                # Parse exactly the same PTY stream.
                self.screen.feed(text)

                # Expose parsed screen state.
                self.screenChanged.emit(
                    self.screen_snapshot(),
                    self.screen.cols,
                    self.screen.rows
                )

                self.cursorChanged.emit(
                    self.screen.cursor_x,
                    self.screen.cursor_y,
                    self.screen.cursor_visible
                )

            except OSError:
                break

            except Exception:
                break

        self.running = False

    # =========================================================
    # LIVE SYSTEM METRICS
    # =========================================================

    @Slot()
    def update_metrics(self):

        try:
            cpu = psutil.cpu_percent(interval=None)

            memory = psutil.virtual_memory()
            ram = memory.percent

            swap = psutil.swap_memory()
            swap_percent = swap.percent

            # Network activity.
            # Calculate total current throughput from the
            # interface counters.
            net = psutil.net_io_counters()

            now = time.monotonic()

            if not hasattr(self, "_last_net"):
                self._last_net = net
                self._last_net_time = now
                net_value = 0.0

            else:
                elapsed = max(
                    now - self._last_net_time,
                    0.001
                )

                sent_delta = (
                    net.bytes_sent -
                    self._last_net.bytes_sent
                )

                recv_delta = (
                    net.bytes_recv -
                    self._last_net.bytes_recv
                )

                total_bytes = (
                    max(sent_delta, 0) +
                    max(recv_delta, 0)
                )

                # Convert bytes/sec into Mbps.
                net_mbps = (
                    total_bytes * 8
                    / elapsed
                    / 1_000_000
                )

                # HUD-friendly normalized value.
                # 100 Mbps is treated as 100%.
                net_value = min(
                    net_mbps,
                    100.0
                )

                self._last_net = net
                self._last_net_time = now

            self.systemMetricsChanged.emit(
                float(cpu),
                float(ram),
                float(swap_percent),
                float(net_value)
            )

        except Exception as e:
            print(
                "DYSEN METRICS:",
                e
            )

    # =========================================================
    # LIVE PROCESS MONITOR
    # =========================================================

    @Slot()
    def update_processes(self):

        try:
            processes = []

            for proc in psutil.process_iter(
                ["name", "cpu_percent", "memory_info", "status"],
                ad_value=None
            ):
                try:
                    info = proc.info

                    name = info.get("name") or "unknown"
                    cpu = float(info.get("cpu_percent") or 0.0)

                    memory_info = info.get("memory_info")
                    rss = (
                        memory_info.rss
                        if memory_info is not None
                        else 0
                    )

                    # Keep memory display compact.
                    if rss >= 1024 * 1024 * 1024:
                        mem = f"{rss / (1024 ** 3):.1f}G"
                    else:
                        mem = f"{rss / (1024 ** 2):.0f}M"

                    status = info.get("status") or "unknown"

                    processes.append({
                        "name": name,
                        "cpu": cpu,
                        "mem": mem,
                        "status": status,
                        "pid": proc.pid
                    })

                except (
                    psutil.NoSuchProcess,
                    psutil.AccessDenied,
                    psutil.ZombieProcess
                ):
                    continue

            # Highest CPU consumers first.
            processes.sort(
                key=lambda x: x["cpu"],
                reverse=True
            )

            # Top 8 keeps the HUD readable.
            processes = processes[:8]

            rows = []

            for proc in processes:
                rows.append([
                    proc["name"],
                    f'{proc["cpu"]:.1f}%',
                    proc["mem"]
                ])

            self.processesChanged.emit(
                rows,
                len(rows)
            )

        except Exception as e:
            print("DYSEN PROCESS MONITOR:", e)

    @Slot(str)
    def write(self, text):

        if not self.running:
            return

        if not text:
            return

        try:

            os.write(
                self.fd,
                text.encode("utf-8")
            )

        except OSError:
            self.running = False

    @Slot()
    def interrupt(self):
        self.write("\x03")

    @Slot()
    def clear(self):
        self.write("\x0c")

    @Slot()
    def close(self):

        self.metricsTimer.stop()
        self.processTimer.stop()

        if not self.running:
            return

        self.running = False

        try:
            os.close(self.fd)
        except OSError:
            pass
