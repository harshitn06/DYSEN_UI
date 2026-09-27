import QtQuick
import QtQuick.Window

Item {
    id: bottomBar

    signal fileManagerRequested()

    Rectangle {
        anchors.fill: parent

        color: "#000000"

        border.width: 1
        border.color: Window.window ? Window.window.dysenAccentDim : "#004652"
    }

    Row {
        anchors.fill: parent

        anchors.leftMargin: 10
        anchors.rightMargin: 10

        spacing: 0

        // =================================================
        // CONNECTION
        // =================================================

        Text {
            width: 155

            text: "▣  CONNECTION  SECURE"

            color: Window.window ? Window.window.dysenAccent : "#00F6FF"

            font.family: "monospace"
            font.pixelSize: 7
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: parent.height - 10

            color: Window.window ? Window.window.dysenAccentDim : "#004652"

            anchors.verticalCenter: parent.verticalCenter
        }

        // =================================================
        // LOCATION
        // =================================================

        Text {
            width: 165

            leftPadding: 14

            text: "⌖  LOCATION   KALI LINUX"

            color: Window.window ? Window.window.dysenMuted : "#76A7AF"

            font.family: "monospace"
            font.pixelSize: 7

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: parent.height - 10

            color: Window.window ? Window.window.dysenAccentDim : "#004652"

            anchors.verticalCenter: parent.verticalCenter
        }

        // =================================================
        // SESSION
        // =================================================

        Text {
            width: 175

            leftPadding: 14

            text: "SESSION ID   DYSEN-01"

            color: Window.window ? Window.window.dysenMuted : "#76A7AF"

            font.family: "monospace"
            font.pixelSize: 7

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: parent.height - 10

            color: Window.window ? Window.window.dysenAccentDim : "#004652"

            anchors.verticalCenter: parent.verticalCenter
        }

        // =================================================
        // IP
        // =================================================

        Text {
            width: 185

            leftPadding: 14

            text: "IP ADDRESS   192.168.1.105"

            color: Window.window ? Window.window.dysenMuted : "#76A7AF"

            font.family: "monospace"
            font.pixelSize: 7

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: parent.height - 10

            color: Window.window ? Window.window.dysenAccentDim : "#004652"

            anchors.verticalCenter: parent.verticalCenter
        }

        // =================================================
        // DATA STREAM
        // =================================================

        Text {
            width: 92

            leftPadding: 14

            text: "DATA STREAM"

            color: Window.window ? Window.window.dysenMuted : "#2C6973"

            font.family: "monospace"
            font.pixelSize: 7

            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            width: 145

            spacing: 4

            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: 18

                Rectangle {
                    width: 4
                    height: 8

                    color: Window.window ? Window.window.dysenAccent : "#00F6FF"

                    opacity:
                        0.15 +
                        Math.abs(
                            Math.sin(
                                index * 0.65 +
                                bottomTimer.t
                            )
                        ) * 0.70
                }
            }
        }

        Item {
            width: 1
            height: 1
        }

        // =================================================
        // RIGHT CONTROLS
        // =================================================

        Row {
            spacing: 7

            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 52
                height: 21

                color: Qt.rgba(
                    Window.window ? Window.window.dysenAccent.r : 0,
                    Window.window ? Window.window.dysenAccent.g : 0.96,
                    Window.window ? Window.window.dysenAccent.b : 1,
                    0.06
                )

                border.width: 1
                border.color:
                    Window.window
                    ? Window.window.dysenAccent
                    : "#00F6FF"

                radius: 2

                Text {
                    anchors.centerIn: parent

                    text: "FILES"

                    color:
                        Window.window
                        ? Window.window.dysenAccent
                        : "#00F6FF"

                    font.family: "Monospace"
                    font.pixelSize: 7
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        bottomBar.fileManagerRequested()
                    }
                }
            }

            Repeater {
                model: ["◉", "⌁", "⚙"]

                Rectangle {
                    width: 30
                    height: 21

                    color: "#000000"

                    border.width: 1
                    border.color: Window.window ? Window.window.dysenAccent : "#006572"

                    radius: 2

                    Text {
                        anchors.centerIn: parent

                        text: modelData

                        color:
                            index === 2
                            ? (Window.window ? Window.window.dysenAccentSecondary : "#7CF2FF")
                            : (Window.window ? Window.window.dysenMuted : "#2C6973")

                        font.family: "monospace"
                        font.pixelSize: 9
                    }
                }
            }
        }
    }

    Timer {
        id: bottomTimer

        property real t: 0

        interval: 55
        running: true
        repeat: true

        onTriggered: {
            t += 0.12
        }
    }
}
