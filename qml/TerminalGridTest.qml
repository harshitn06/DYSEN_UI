import QtQuick
import QtQuick.Window

Window {
    id: win

    width: 1100
    height: 620

    visible: true

    color: "#000000"

    title: "DYSEN VT RENDERER TEST"

    property string snapshot: ""
    property int columns: 120
    property int rows: 32

    property int cursorX: 0
    property int cursorY: 0
    property bool cursorVisible: true

    TerminalGrid {
        id: grid

        anchors.left: parent.left
        anchors.top: parent.top

        snapshot: win.snapshot

        columns: win.columns
        rows: win.rows

        cursorX: win.cursorX
        cursorY: win.cursorY

        cursorVisible: win.cursorVisible
    }

    Connections {
        target: terminalBackend

        function onScreenChanged(
            snapshot,
            columns,
            rows
        ) {
            win.snapshot = snapshot
            win.columns = columns
            win.rows = rows
        }

        function onCursorChanged(
            x,
            y,
            visible
        ) {
            win.cursorX = x
            win.cursorY = y
            win.cursorVisible = visible
        }
    }
}
