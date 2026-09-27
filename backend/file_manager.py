from __future__ import annotations

import os
import stat
import subprocess
from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal, Slot


class FileManagerBackend(QObject):
    itemsChanged = Signal()
    currentPathChanged = Signal()
    statusChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._current_path = "/"
        self._items = []
        self._status = "READY"

        self._load_directory("/")

    # ------------------------------------------------------------
    # QML properties
    # ------------------------------------------------------------

    @Property(str, notify=currentPathChanged)
    def currentPath(self) -> str:
        return self._current_path

    @Property("QVariantList", notify=itemsChanged)
    def items(self):
        return self._items

    @Property(str, notify=statusChanged)
    def status(self) -> str:
        return self._status

    # ------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------

    def _set_status(self, message: str):
        if message != self._status:
            self._status = message
            self.statusChanged.emit()

    @staticmethod
    def _normalize(path: str) -> str:
        if not path:
            return "/"

        try:
            return os.path.abspath(os.path.expanduser(path))
        except Exception:
            return "/"

    @staticmethod
    def _format_size(size: int) -> str:
        units = ("B", "KB", "MB", "GB", "TB")

        value = float(max(0, size))

        for unit in units:
            if value < 1024 or unit == units[-1]:
                if unit == "B":
                    return f"{int(value)} B"

                return f"{value:.1f} {unit}"

            value /= 1024

        return "0 B"

    @staticmethod
    def _mode_string(path: str) -> str:
        try:
            return stat.filemode(os.lstat(path).st_mode)
        except OSError:
            return "??????????"

    def _build_item(self, entry: os.DirEntry) -> dict:
        path = entry.path

        try:
            is_dir = entry.is_dir(follow_symlinks=False)
        except OSError:
            is_dir = False

        try:
            is_link = entry.is_symlink()
        except OSError:
            is_link = False

        try:
            if is_dir:
                size = 0
            else:
                size = entry.stat(follow_symlinks=False).st_size
        except OSError:
            size = 0

        return {
            "name": entry.name,
            "path": path,
            "isDir": is_dir,
            "isLink": is_link,
            "hidden": entry.name.startswith("."),
            "size": self._format_size(size),
            "mode": self._mode_string(path),
            "readable": os.access(path, os.R_OK),
            "writable": os.access(path, os.W_OK),
        }

    # ------------------------------------------------------------
    # Directory loading
    # ------------------------------------------------------------

    def _load_directory(self, path: str):
        path = self._normalize(path)

        if not os.path.isdir(path):
            self._set_status("NOT A DIRECTORY")
            return

        try:
            entries = []

            with os.scandir(path) as iterator:
                for entry in iterator:
                    try:
                        entries.append(self._build_item(entry))
                    except OSError:
                        continue

            entries.sort(
                key=lambda item: (
                    not item["isDir"],
                    item["name"].lower(),
                )
            )

            self._items = entries

            if path != self._current_path:
                self._current_path = path
                self.currentPathChanged.emit()

            self._set_status(
                f"{len(entries)} ITEMS  •  "
                f"{'ROOT FILESYSTEM' if path == '/' else 'READY'}"
            )

            self.itemsChanged.emit()

        except PermissionError:
            self._items = []

            if path != self._current_path:
                self._current_path = path
                self.currentPathChanged.emit()

            self._set_status("PERMISSION DENIED")
            self.itemsChanged.emit()

        except OSError as exc:
            self._items = []

            if path != self._current_path:
                self._current_path = path
                self.currentPathChanged.emit()

            self._set_status(f"FILESYSTEM ERROR: {exc}")
            self.itemsChanged.emit()

    # ------------------------------------------------------------
    # QML actions
    # ------------------------------------------------------------

    @Slot(str)
    def navigate(self, path: str):
        self._load_directory(path)

    @Slot()
    def goRoot(self):
        self._load_directory("/")

    @Slot()
    def goUp(self):
        current = Path(self._current_path)

        if str(current) == "/":
            return

        parent = str(current.parent)

        if not parent:
            parent = "/"

        self._load_directory(parent)

    @Slot()
    def goHome(self):
        self._load_directory(str(Path.home()))

    @Slot()
    def refresh(self):
        self._load_directory(self._current_path)

    @Slot(str)
    def openPath(self, path: str):
        path = self._normalize(path)

        if os.path.isdir(path):
            self._load_directory(path)
            return

        if not os.path.exists(path):
            self._set_status("ITEM NO LONGER EXISTS")
            return

        try:
            subprocess.Popen(
                ["xdg-open", path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )

            self._set_status("OPENED")

        except FileNotFoundError:
            self._set_status("xdg-open NOT AVAILABLE")

        except OSError as exc:
            self._set_status(f"OPEN FAILED: {exc}")

    @Slot(str)
    def revealPath(self, path: str):
        path = self._normalize(path)

        if os.path.isdir(path):
            self._load_directory(path)
            return

        parent = os.path.dirname(path) or "/"
        self._load_directory(parent)

    @Slot(str)
    def deleteUserAccessible(self, path: str):
        """
        Deliberately limited to paths writable by the current user.
        No hidden sudo escalation happens here.
        """
        path = self._normalize(path)

        if not os.path.exists(path):
            self._set_status("ITEM DOES NOT EXIST")
            return

        if not os.access(path, os.W_OK):
            self._set_status("PERMISSION DENIED — ADMIN ACTION REQUIRED")
            return

        self._set_status(
            "DELETE NOT ENABLED YET — SAFE MODE"
        )
