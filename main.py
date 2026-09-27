import os
import getpass
import socket
import sys

os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Property, Slot, QUrl, QSettings

from terminal_backend import TerminalBackend
from ui_effects import UIEffects
from system_backend import SystemBackend
from core.gui.dysen_ipc import DysenIPC, DysenIpcError



class DysenGuiBridge(QObject):

    stateChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._ipc = DysenIPC()

        self._connected = False
        self._windows = 0
        self._workspace = 1
        self._window_list = []

        self.refresh()

    @Slot(result=bool)
    def refresh(self):
        try:
            state = self._ipc.get_state()
            windows = self._ipc.get_windows()

            self._connected = bool(
                state.get("ok")
            )

            self._windows = int(
                state.get("windows", 0)
            )

            self._workspace = int(
                state.get("workspace", 1)
            )

            self._window_list = windows.get(
                "windows",
                [],
            )

        except DysenIpcError:
            self._connected = False
            self._windows = 0
            self._window_list = []

        self.stateChanged.emit()

        return self._connected

    @Slot(result=bool)
    def ping(self):
        try:
            response = self._ipc.ping()
            return response.get("ok", False)
        except DysenIpcError:
            return False

    def _get_connected(self):
        return self._connected

    def _get_windows(self):
        return self._windows

    def _get_workspace(self):
        return self._workspace

    def _get_window_list(self):
        return self._window_list

    connected = Property(
        bool,
        _get_connected,
        notify=stateChanged,
    )

    windowCount = Property(
        int,
        _get_windows,
        notify=stateChanged,
    )

    workspace = Property(
        int,
        _get_workspace,
        notify=stateChanged,
    )

    windows = Property(
        "QVariantList",
        _get_window_list,
        notify=stateChanged,
    )


class ClipboardBridge(QObject):

    @Slot(result=str)
    def getText(self):
        return QGuiApplication.clipboard().text()

    @Slot(str)
    def setText(self, text):
        QGuiApplication.clipboard().setText(text)

    @Slot()
    def clear(self):
        QGuiApplication.clipboard().clear()


class DysenSettingsBridge(QObject):

    def __init__(self, parent=None):
        super().__init__(parent)

        self.settings = QSettings(
            "DYSEN",
            "DYSEN"
        )

    @Slot(str, result="QVariant")
    def get(self, key):
        return self.settings.value(key)

    @Slot(str, "QVariant")
    def set(self, key, value):
        self.settings.setValue(key, value)
        self.settings.sync()


app = QGuiApplication(sys.argv)

try:
    import pwd

    _dysen_pw = pwd.getpwuid(os.getuid())
    _dysen_raw_user = _dysen_pw.pw_name
except Exception:
    _dysen_raw_user = getpass.getuser() or os.environ.get("USER") or "USER"

_dysen_raw_user = _dysen_raw_user.strip() or "USER"

dysenUserName = (
    _dysen_raw_user[:1].upper() + _dysen_raw_user[1:]
)

dysenHostName = socket.gethostname() or "DYSEN"


from backend.file_manager import FileManagerBackend

terminalBackend = TerminalBackend()

fileManagerBackend = FileManagerBackend()
uiEffects = UIEffects()
clipboardBridge = ClipboardBridge()
dysenSettingsBridge = DysenSettingsBridge()
systemBackend = SystemBackend()
dysenGuiBridge = DysenGuiBridge()

engine = QQmlApplicationEngine()

engine.rootContext().setContextProperty(
    "terminalBackend",
    terminalBackend
)

engine.rootContext().setContextProperty(
    "uiEffects",
    uiEffects
)

engine.rootContext().setContextProperty(
    "clipboardBridge",
    clipboardBridge
)

engine.rootContext().setContextProperty(
    "dysenSettingsBridge",
    dysenSettingsBridge
)

engine.rootContext().setContextProperty(
    "systemBackend",
    systemBackend
)

engine.rootContext().setContextProperty(
    "dysenUserName",
    dysenUserName
)

engine.rootContext().setContextProperty(
    "dysenHostName",
    dysenHostName
)

engine.rootContext().setContextProperty(
    "dysenGuiBridge",
    dysenGuiBridge
)

engine.rootContext().setContextProperty(
    "fileManagerBackend",
    fileManagerBackend
)

engine.load(
    QUrl.fromLocalFile(
        "qml/Main.qml"
    )
)

if not engine.rootObjects():
    systemBackend.close()
    terminalBackend.close()
    sys.exit(1)

exit_code = app.exec()

systemBackend.close()
terminalBackend.close()

sys.exit(exit_code)
