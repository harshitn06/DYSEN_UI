import QtQuick
import QtQuick.Window

Column {
    id: metric

    property string label: ""
    property string value: ""
    property real progress: 0.58

    width: parent ? parent.width : 220
    spacing: 7

    Row {
        width: parent.width
        height: 16

        Text {
            id: labelText

            width: parent.width * 0.45

            text: metric.label

            color: Window.window ? Window.window.dysenAccent : "#3A7F88"

            font.family: "monospace"
            font.pixelSize: 9
            font.letterSpacing: 0.8
        }

        Text {
            width: parent.width * 0.55

            text: metric.value

            horizontalAlignment: Text.AlignRight

            color: "#F5FEFF"

            font.family: "monospace"
            font.pixelSize: 10
            font.bold: true
        }
    }

    Rectangle {
        width: parent.width
        height: 4

        radius: 2

        color: (Window.window ? Window.window.dysenAccentDim : "#00333B")

        Rectangle {
            width: parent.width * metric.progress
            height: parent.height

            radius: 2

            color: Window.window ? Window.window.dysenAccent : "#00E6F5"

            opacity: 0.75

            Behavior on width {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
