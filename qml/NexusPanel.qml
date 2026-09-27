import QtQuick
import QtQuick.Window
import QtQuick.Controls

Item {

    property string status: "COMING SOON"

    property color themeAccent:
        Window.window ? Window.window.dysenAccent : "#00F6FF"

    property color themeSecondary:
        Window.window ? Window.window.dysenAccentSecondary : "#7CF2FF"

    property color themeDim:
        Window.window ? Window.window.dysenAccentDim : "#007483"

    property color themeMuted:
        Window.window ? Window.window.dysenMuted : "#5D7880"

    property color themeHeader:
        Window.window ? Window.window.dysenHeaderFill : "#020A0C"

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Column {

        anchors.fill: parent
        anchors.margins: 12

        spacing: 12

        Item {
            width: parent.width
            height: 65

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                text: "◉"

                color: themeAccent

                font.pixelSize: 27

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        from: .45
                        to: 1
                        duration: 1000
                    }

                    NumberAnimation {
                        from: 1
                        to: .45
                        duration: 1000
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                text: "NEXUS AI"

                color: themeSecondary

                font.family: "monospace"
                font.pixelSize: 17
                font.bold: true
                font.letterSpacing: 2
            }
        }

        Text {
            width: parent.width

            text: "NEURAL UTILITY eXECUTION\n& UNIFIED SYSTEM"

            horizontalAlignment: Text.AlignHCenter

            color: themeMuted

            font.family: "monospace"
            font.pixelSize: 7
            lineHeight: 1.3
        }

        Rectangle {
            width: parent.width
            height: 1
            color: themeDim
        }

        Rectangle {

            width: parent.width
            height: 58

            color: themeHeader

            border.width: 1
            border.color: themeDim

            Text {
                anchors.fill: parent
                anchors.margins: 10

                text: "NEXUS CORE\n\nSTATUS     OFFLINE\nINTERFACE  RESERVED"

                color: themeMuted

                font.family: "monospace"
                font.pixelSize: 8
            }
        }

        Text {

            text: "SYSTEM ASSISTANT"

            color: themeSecondary

            font.family: "monospace"
            font.pixelSize: 7
            font.letterSpacing: 1
        }

        Rectangle {

            width: parent.width
            height: 90

            color: themeHeader

            border.width: 1
            border.color: themeDim

            radius: 3

            Text {

                anchors.fill: parent
                anchors.margins: 10

                text: "NEXUS connection pending...\n\nThe neural interface will\nbe activated in a future\nDYSEN release."

                color: themeMuted

                font.family: "monospace"
                font.pixelSize: 8
                lineHeight: 1.35
            }
        }

        Item {
            width: 1
            height: 1
        }

        Rectangle {

            width: parent.width
            height: 34

            color: themeHeader

            border.width: 1
            border.color: themeAccent

            Text {

                anchors.centerIn: parent

                text: "◉  NEXUS // COMING SOON"

                color: themeSecondary

                font.family: "monospace"
                font.pixelSize: 8
                font.letterSpacing: 1
            }
        }
    }
}
