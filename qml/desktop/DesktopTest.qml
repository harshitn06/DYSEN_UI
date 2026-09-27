import QtQuick
import QtQuick.Window

Window {
    visible: true
    width: 1200
    height: 700
    title: "DYSEN Window Manager"
    color: "#070b10"

    DesktopShell {
        id: shell
        anchors.fill: parent

        onWorkspaceRequested: function(workspace) {
            wmBridge.switchWorkspace(workspace)
        }

        onWindowFocusRequested: function(windowId) {
            wmBridge.focusWindow(windowId)
            wmBridge.refresh()
            shell.setWindows(wmBridge.windows)
        }

        onWindowMinimizeRequested: function(windowId) {
            wmBridge.minimizeWindow(windowId)
            wmBridge.refresh()
            shell.setWindows(wmBridge.windows)
        }

        onWindowMaximizeRequested: function(windowId) {
            wmBridge.maximizeWindow(windowId)
            wmBridge.refresh()
            shell.setWindows(wmBridge.windows)
        }

        onWindowCloseRequested: function(windowId) {
            wmBridge.closeWindow(windowId)
            wmBridge.refresh()
            shell.setWindows(wmBridge.windows)
        }

        Component.onCompleted: {
            shell.setWindows(wmBridge.windows)
        }
    }
}
