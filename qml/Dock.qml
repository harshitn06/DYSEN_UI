import QtQuick
import QtQuick.Window

Item {
    id: dock

    property var modules: [
        ["TERM", terminalPanel],
        ["SYS", telemetryPanel],
        ["SIG", signalPanel],
        ["KEY", keyboardPanel],
        ["STAT", statusPanel]
    ]

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        width: Math.min(
            parent.width - 60,
            620
        )

        height: 58

        radius: 10

        color: "#071318"

        border.width: 1
        border.color: "#28464e"

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2

            color: "transparent"

            border.width: 1
            border.color: Window.window ? Window.window.dysenAccent : "#00E6F5"

            opacity: .08

            radius: 12
        }

        Row {
            anchors.centerIn: parent

            spacing: 8

            Repeater {
                model: dock.modules

                delegate: Rectangle {

                    width: 92
                    height: 38

                    radius: 5

                    color:
                        mouse.containsMouse
                        ? "#102b32"
                        : "#091a20"

                    border.width: 1

                    border.color:
                        mouse.containsMouse
                        ? "#70dce9"
                        : "#007483"

                    Text {
                        anchors.centerIn: parent

                        text: modelData[0]

                        color:
                            mouse.containsMouse
                            ? "#c9f8fc"
                            : "#75969e"

                        font.family: "monospace"
                        font.pixelSize: 8
                        font.bold: true
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent

                        hoverEnabled: true

                        onClicked: {

                            modelData[1].visible = true

                            modelData[1].z = 100000

                        }
                    }
                }
            }
        }
    }
}
