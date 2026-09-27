import QtQuick
import QtQuick.Window

Item {
    id: topBar

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1
        color: (Window.window ? Window.window.dysenAccentDim : "#00333B")
    }

    // =====================================================
    // LEFT BRAND
    // =====================================================

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        spacing: 9

        Text {
            text: "DYSEN OS"

            color: "#FFFFFF"

            font.family: "monospace"
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 2
        }

        Text {
            text: "v2.0.0"

            color: Window.window ? Window.window.dysenAccent : "#00F6FF"

            font.family: "monospace"
            font.pixelSize: 8
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: 13

            color: Window.window ? Window.window.dysenAccentDim : "#006572"

            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Window.window ? Window.window.dysenThemeLabel : "CYBER INTERFACE"

            color: Window.window ? Window.window.dysenMuted : "#2C6973"

            font.family: "monospace"
            font.pixelSize: 7
            font.letterSpacing: 1.5

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // =====================================================
    // CENTER DYSEN WORDMARK
    // =====================================================

    Column {
        anchors.centerIn: parent

        spacing: 2

        Text {
            width: 180

            text: "D Y S E N"

            horizontalAlignment: Text.AlignHCenter

            color: "#FFFFFF"

            font.family: "monospace"
            font.pixelSize: 21
            font.bold: true
            font.letterSpacing: 5
        }

        Rectangle {
            width: 86
            height: 1

            anchors.horizontalCenter: parent.horizontalCenter

            color: Window.window ? Window.window.dysenAccent : "#00F6FF"

            opacity: 0.7
        }
    }

    // =====================================================
    // RIGHT SYSTEM
    // =====================================================

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: 14

        Text {
            text: "KALI LINUX"

            color: Window.window ? Window.window.dysenAccentSecondary : "#3A7F88"

            font.family: "monospace"
            font.pixelSize: 7
            font.bold: true
        }

        Text {
            text: "UPTIME 02:47:31"

            color: Window.window ? Window.window.dysenMuted : "#2C6973"

            font.family: "monospace"
            font.pixelSize: 7
        }

        Text {
            text: "USER HARSHIT"

            color: Window.window ? Window.window.dysenMuted : "#2C6973"

            font.family: "monospace"
            font.pixelSize: 7
        }

        Rectangle {
            width: 6
            height: 6

            radius: 3

            color: Window.window ? Window.window.dysenAccent : "#00F6FF"

            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on opacity {
                loops: Animation.Infinite

                NumberAnimation {
                    from: 0.3
                    to: 1
                    duration: 700
                }

                NumberAnimation {
                    from: 1
                    to: 0.3
                    duration: 700
                }
            }
        }

        Text {
            text: Qt.formatTime(
                new Date(),
                "HH:mm:ss"
            )

            color: Window.window ? Window.window.dysenAccent : "#00F6FF"

            font.family: "monospace"
            font.pixelSize: 10
            font.bold: true
        }
    }
}
