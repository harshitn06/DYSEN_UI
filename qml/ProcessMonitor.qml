import QtQuick
import QtQuick.Window

Column {
    id: monitor

    spacing: 4

    property var processes: []
    property int processCount: 0

    Connections {
        target: systemBackend

        function onProcessesChanged(rows, count) {
            monitor.processes = rows
            monitor.processCount = count
        }
    }

    Row {
        width: parent.width
        height: 18

        Text {
            width: parent.width * .18
            text: "PID"
            color: Window.window ? Window.window.dysenAccent : "#00E6F5"
            font.family: "monospace"
            font.pixelSize: 7
        }

        Text {
            width: parent.width * .38
            text: "PROCESS"
            color: Window.window ? Window.window.dysenAccent : "#00E6F5"
            font.family: "monospace"
            font.pixelSize: 7
        }

        Text {
            width: parent.width * .20
            text: "CPU"
            color: Window.window ? Window.window.dysenAccent : "#00E6F5"
            font.family: "monospace"
            font.pixelSize: 7
        }

        Text {
            width: parent.width * .24
            text: "MEM"
            color: Window.window ? Window.window.dysenAccent : "#00E6F5"
            font.family: "monospace"
            font.pixelSize: 7
        }
    }

    Repeater {
        model: monitor.processes

        delegate: Row {
            width: parent.width
            height: 19

            Text {
                width: parent.width * .18
                text: modelData[0]
                color: Window.window ? Window.window.dysenAccent : "#5C8E97"
                font.family: "monospace"
                font.pixelSize: 8
            }

            Text {
                width: parent.width * .38
                text: modelData[1]
                color: "#E8FDFF"
                font.family: "monospace"
                font.pixelSize: 8
                elide: Text.ElideRight
            }

            Text {
                width: parent.width * .20
                text: modelData[2]
                color: Window.window ? Window.window.dysenAccent : "#00F6FF"
                font.family: "monospace"
                font.pixelSize: 8
            }

            Text {
                width: parent.width * .24
                text: modelData[3]
                color: Window.window ? Window.window.dysenAccent : "#5C8E97"
                font.family: "monospace"
                font.pixelSize: 8
            }
        }
    }
}
