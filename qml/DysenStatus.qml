import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    width: 320
    height: 150

    radius: 14
    color: "#0b1014"
    border.width: 1
    border.color: "#193038"

    property color accent: "#00d8c8"

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 9

        Text {
            text: "DYSEN CORE"
            color: root.accent
            font.pixelSize: 12
            font.bold: true
            letterSpacing: 2
        }

        Text {
            text: dysenGuiBridge.connected
                  ? "● COMPOSITOR CONNECTED"
                  : "● COMPOSITOR OFFLINE"

            color: dysenGuiBridge.connected
                   ? "#7dffea"
                   : "#ff6470"

            font.pixelSize: 13
        }

        Text {
            text: "WINDOWS     " + dysenGuiBridge.windowCount
            color: "#c8d7da"
            font.pixelSize: 12
        }

        Text {
            text: "WORKSPACE   " + dysenGuiBridge.workspace
            color: "#c8d7da"
            font.pixelSize: 12
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            dysenGuiBridge.refresh()
        }
    }
}
