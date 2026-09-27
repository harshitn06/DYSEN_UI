import QtQuick
import QtQuick.Window

Rectangle {
    id: root

    anchors.fill: parent
    color: "#070b10"

    property int activeWorkspace: 1
    property int workspaceCount: 10
    property var managedWindows: []

    signal workspaceRequested(int workspace)
    signal windowFocusRequested(string windowId)
    signal windowMinimizeRequested(string windowId)
    signal windowMaximizeRequested(string windowId)
    signal windowCloseRequested(string windowId)

    function setWindows(windows) {
        managedWindows = windows || []
    }

    Rectangle {
        id: topBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 48
        color: "#0c1219"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: "DYSEN"
            color: Window.window ? Window.window.dysenAccent : "#bfeaf0"
            font.family: "monospace"
            font.pixelSize: 17
            font.bold: true
        }

        Row {
            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: root.workspaceCount

                Rectangle {
                    width: 27
                    height: 25
                    radius: 6

                    color: index + 1 === root.activeWorkspace
                           ? "#16333b"
                           : "#101820"

                    border.width: 1

                    border.color:
                        index + 1 === root.activeWorkspace
                        ? "#53d8e8"
                        : "#26343d"

                    Text {
                        anchors.centerIn: parent
                        text: index + 1

                        color:
                            index + 1 === root.activeWorkspace
                            ? "#7ce8f4"
                            : "#78909a"

                        font.family: "monospace"
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.activeWorkspace = index + 1
                            root.workspaceRequested(index + 1)
                        }
                    }
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: "WS " + root.activeWorkspace

            color: Window.window ? Window.window.dysenAccent : "#67e8a5"
            font.family: "monospace"
            font.pixelSize: 10
        }
    }

    Rectangle {
        id: desktopArea

        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.left: parent.left
        anchors.right: parent.right

        color: "#05080c"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18

            text: "WINDOW OVERVIEW"

            color: "#334850"
            font.family: "monospace"
            font.pixelSize: 11
        }

        GridView {
            id: windowGrid

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.margins: 55

            cellWidth: 250
            cellHeight: 150

            model: root.managedWindows

            delegate: Rectangle {
                width: 230
                height: 130

                radius: 10

                color: modelData.focused
                       ? "#10242b"
                       : "#0c1219"

                border.width: 1

                border.color:
                    modelData.focused
                    ? "#53d8e8"
                    : "#26343d"

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 7

                    Text {
                        text: modelData.title || "Untitled"

                        color: Window.window ? Window.window.dysenAccent : "#bfeaf0"
                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true

                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: modelData.appId || "application"

                        color: Window.window ? Window.window.dysenAccent : "#61747d"
                        font.family: "monospace"
                        font.pixelSize: 9

                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text:
                            "WS " + modelData.workspace
                            + (modelData.focused ? "  •  FOCUSED" : "")

                        color:
                            modelData.focused
                            ? "#67e8a5"
                            : "#536a73"

                        font.family: "monospace"
                        font.pixelSize: 9
                    }

                    Row {
                        spacing: 5

                        Rectangle {
                            width: 52
                            height: 22
                            radius: 5
                            color: "#121c24"

                            Text {
                                anchors.centerIn: parent
                                text: "FOCUS"
                                color: Window.window ? Window.window.dysenAccent : "#8bd9e3"
                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked:
                                    root.windowFocusRequested(modelData.id)
                            }
                        }

                        Rectangle {
                            width: 45
                            height: 22
                            radius: 5
                            color: "#121c24"

                            Text {
                                anchors.centerIn: parent
                                text: "MIN"
                                color: Window.window ? Window.window.dysenAccent : "#8bd9e3"
                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked:
                                    root.windowMinimizeRequested(modelData.id)
                            }
                        }

                        Rectangle {
                            width: 45
                            height: 22
                            radius: 5
                            color: "#121c24"

                            Text {
                                anchors.centerIn: parent
                                text: "MAX"
                                color: Window.window ? Window.window.dysenAccent : "#8bd9e3"
                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked:
                                    root.windowMaximizeRequested(modelData.id)
                            }
                        }

                        Rectangle {
                            width: 45
                            height: 22
                            radius: 5
                            color: "#241419"

                            Text {
                                anchors.centerIn: parent
                                text: "CLOSE"
                                color: "#e8a3ad"
                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked:
                                    root.windowCloseRequested(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomBar

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 30
        color: "#0c1219"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter

            text: root.managedWindows.length + " managed windows"

            color: Window.window ? Window.window.dysenAccent : "#61747d"
            font.family: "monospace"
            font.pixelSize: 9
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter

            text: "DYSEN WM"

            color: Window.window ? Window.window.dysenAccent : "#536a73"
            font.family: "monospace"
            font.pixelSize: 9
        }
    }
}
