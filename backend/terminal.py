import os
import pty
import select
import subprocess
import threading

from PySide6.QtCore import QObject, Signal, Slot


class TerminalBackend(QObject):
    output = Signal(str)
    started = Signal()
    stopped = Signal()
    error = Signal(str)

    def __init__(self):
        super().__init__()

        self.pid = None
        self.fd = None
        self.running = False

    @Slot()
    def start(self):
        if self.running:
            return

        try:
            pid, fd = pty.fork()

            if pid == 0:
                shell = os.environ.get("SHELL", "/bin/bash")

                os.environ["TERM"] = "xterm-256color"
                os.environ["COLORTERM"] = "true"

                os.execlp(
                    shell,
                    shell,
                    "-l"
                )

            self.pid = pid
            self.fd = fd
            self.running = True

            self.started.emit()

            thread = threading.Thread(
                target=self._reader,
                daemon=True
            )

            thread.start()

        except Exception as exc:
            self.error.emit(str(exc))

    def _reader(self):
        while self.running and self.fd is not None:

            try:
                ready, _, _ = select.select(
                    [self.fd],
                    [],
                    [],
                    0.1
                )

                if self.fd not in ready:
                    continue

                data = os.read(
                    self.fd,
                    8192
                )

                if not data:
                    break

                text = data.decode(
                    "utf-8",
                    errors="replace"
                )

                self.output.emit(text)

            except OSError:
                break

            except Exception as exc:
                self.error.emit(str(exc))
                break

        self.running = False
        self.stopped.emit()

    @Slot(str)
    def write(self, text):
        if not self.running or self.fd is None:
            return

        try:
            os.write(
                self.fd,
                text.encode("utf-8")
            )

        except Exception as exc:
            self.error.emit(str(exc))

    @Slot()
    def interrupt(self):
        self.write("\x03")

    @Slot()
    def clear(self):
        self.write("\x0c")

    @Slot()
    def stop(self):
        if not self.running:
            return

        self.running = False

        try:
            os.close(self.fd)
        except Exception:
            pass

        self.fd = None
        self.pid = None
