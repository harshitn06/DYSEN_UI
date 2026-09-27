import sys

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from terminal_backend import TerminalBackend


app = QGuiApplication(sys.argv)

backend = TerminalBackend()

engine = QQmlApplicationEngine()

engine.rootContext().setContextProperty(
    "terminalBackend",
    backend
)

engine.load(
    QUrl.fromLocalFile(
        "qml/TerminalGridTest.qml"
    )
)

if not engine.rootObjects():
    backend.close()
    sys.exit(1)

exit_code = app.exec()

backend.close()

sys.exit(exit_code)
