import os
import sys

from PySide6.QtCore import QObject, Property, Signal, Slot, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from core.gui.dysen_ipc import DysenIPC, DysenIpcError


class ControlBridge(QObject):
    stateChanged = Signal()

    def __init__(self):
        super().__init__()

        self._ipc = DysenIPC()

        self._connected = False
        self._windows = 0
        self._workspace = 1

        self.refresh()

    @Slot()
    def refresh(self):
        try:
            state = self._ipc.get_state()

            self._connected = bool(state.get("ok"))
            self._windows = int(state.get("windows", 0))
            self._workspace = int(state.get("workspace", 1))

        except DysenIpcError:
            self._connected = False
            self._windows = 0

        self.stateChanged.emit()

    @Slot(result=bool)
    def ping(self):
        try:
            result = self._ipc.ping()
            return bool(result.get("ok"))
        except DysenIpcError:
            return False

    def _connected_get(self):
        return self._connected

    def _windows_get(self):
        return self._windows

    def _workspace_get(self):
        return self._workspace

    connected = Property(
        bool,
        _connected_get,
        notify=stateChanged,
    )

    windowCount = Property(
        int,
        _windows_get,
        notify=stateChanged,
    )

    workspace = Property(
        int,
        _workspace_get,
        notify=stateChanged,
    )


app = QGuiApplication(sys.argv)

engine = QQmlApplicationEngine()

bridge = ControlBridge()

engine.rootContext().setContextProperty(
    "dysen",
    bridge,
)

qml_file = os.path.join(
    os.path.dirname(__file__),
    "qml",
    "ControlCenter.qml",
)

engine.load(
    QUrl.fromLocalFile(
        os.path.abspath(qml_file)
    )
)

if not engine.rootObjects():
    sys.exit(1)

sys.exit(app.exec())
