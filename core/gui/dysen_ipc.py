from __future__ import annotations

import json
import os
import socket
from typing import Any


class DysenIpcError(RuntimeError):
    pass


class DysenIPC:
    def __init__(self, socket_path: str | None = None) -> None:
        runtime_dir = os.environ.get("XDG_RUNTIME_DIR")

        if not runtime_dir:
            raise DysenIpcError(
                "XDG_RUNTIME_DIR is not set"
            )

        self.socket_path = (
            socket_path
            or os.path.join(
                runtime_dir,
                "dysen.sock",
            )
        )

    def request(
        self,
        command: dict[str, Any],
    ) -> dict[str, Any]:

        payload = (
            json.dumps(command, separators=(",", ":"))
            + "\n"
        )

        try:
            with socket.socket(
                socket.AF_UNIX,
                socket.SOCK_STREAM,
            ) as sock:

                sock.settimeout(2.0)

                sock.connect(self.socket_path)

                sock.sendall(
                    payload.encode("utf-8")
                )

                response = sock.recv(
                    64 * 1024
                )

        except OSError as exc:
            raise DysenIpcError(
                f"Unable to connect to DYSEN IPC: {exc}"
            ) from exc

        if not response:
            raise DysenIpcError(
                "DYSEN IPC returned an empty response"
            )

        try:
            result = json.loads(
                response.decode("utf-8")
            )
        except json.JSONDecodeError as exc:
            raise DysenIpcError(
                f"Invalid JSON from DYSEN IPC: {response!r}"
            ) from exc

        if not isinstance(result, dict):
            raise DysenIpcError(
                "DYSEN IPC response is not an object"
            )

        return result

    def ping(self) -> dict[str, Any]:
        return self.request({
            "cmd": "ping",
        })

    def get_state(self) -> dict[str, Any]:
        return self.request({
            "cmd": "get_state",
        })

    def get_windows(self) -> dict[str, Any]:
        return self.request({
            "cmd": "get_windows",
        })
