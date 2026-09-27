import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    visible: true
    width: 980
    height: 640

    minimumWidth: 820
    minimumHeight: 560

    title: "DYSEN Control Center"

    color: "#05080a"

    property color bg: "#05080a"
    property color panel: "#0a1115"
    property color panel2: "#0d171c"
    property color line: "#163039"
    property color accent: "#00e6d0"
    property color text: "#d8e7e8"
    property color muted: "#688286"

    Rectangle {
        anchors.fill: parent
        color: root.bg
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: root.line
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58

            ColumnLayout {
                spacing: 2

                Text {
                    text: "DYSEN"
                    color: root.text
                    font.pixelSize: 24
                    font.bold: true
                    font.letterSpacing: 7
                }

                Text {
                    text: "CONTROL CENTER"
                    color: root.accent
                    font.pixelSize: 10
                    font.letterSpacing: 3
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 150
                height: 34
                radius: 8

                color: dysen.connected
                    ? "#071b19"
                    : "#190b0e"

                border.width: 1
                border.color: dysen.connected
                    ? root.accent
                    : "#6b2933"

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4

                        anchors.verticalCenter: parent.verticalCenter

                        color: dysen.connected
                            ? root.accent
                            : "#ff5168"
                    }

                    Text {
                        text: dysen.connected
                            ? "COMPOSITOR ONLINE"
                            : "COMPOSITOR OFFLINE"

                        color: dysen.connected
                            ? root.accent
                            : "#ff7180"

                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.line
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            ColumnLayout {
                Layout.preferredWidth: 210
                Layout.fillHeight: true
                spacing: 8

                Repeater {
                    model: [
                        "Overview",
                        "Layout",
                        "Workspaces",
                        "Appearance",
                        "Keybinds",
                        "Rules"
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 45
                        radius: 8

                        color: index === 0
                            ? root.panel2
                            : "transparent"

                        border.width: index === 0 ? 1 : 0
                        border.color: root.line

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData
                            color: index === 0
                                ? root.accent
                                : root.muted

                            font.pixelSize: 12
                            font.bold: index === 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: "DYSEN WM v0.1"
                    color: root.muted
                    font.pixelSize: 9
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Text {
                    text: "OVERVIEW"
                    color: root.text
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: 12
                    columnSpacing: 12

                    Repeater {
                        model: [
                            ["WINDOWS", dysen.windowCount],
                            ["WORKSPACE", dysen.workspace],
                            ["IPC", dysen.connected ? "READY" : "OFFLINE"]
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 92

                            radius: 10
                            color: root.panel

                            border.width: 1
                            border.color: root.line

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 7

                                Text {
                                    text: modelData[0]
                                    color: root.muted
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 2
                                }

                                Text {
                                    text: modelData[1]
                                    color: root.accent
                                    font.pixelSize: 22
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: 10
                    color: root.panel

                    border.width: 1
                    border.color: root.line

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 18

                        Text {
                            text: "LIVE COMPOSITOR"
                            color: root.accent
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "This interface is a Wayland client of DYSEN. " +
                                "The compositor remains responsible for windows, " +
                                "focus, layout and rendering."

                            color: root.text
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: root.line
                        }

                        Text {
                            text:
                                "NEXT CONTROLS"

                            color: root.muted
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Text {
                            text:
                                "Master Ratio\n" +
                                "Inner / Outer Gaps\n" +
                                "Workspace Assignment\n" +
                                "Window Rules\n" +
                                "Animation Profile"

                            color: root.text
                            font.pixelSize: 13
                            lineHeight: 1.35
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Button {
                            text: "REFRESH COMPOSITOR STATE"

                            Layout.preferredWidth: 230
                            Layout.preferredHeight: 42

                            onClicked: dysen.refresh()
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: dysen.refresh()
    }
}
