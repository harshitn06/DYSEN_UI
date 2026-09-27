import QtQuick
import QtQuick.Controls
import QtQuick.Window

Item {
    id: root

    anchors.fill: parent
    z: 6000000

    visible: false

    signal closed()

    property color accent:
        Window.window
        ? Window.window.dysenAccent
        : "#00F6FF"

    property color secondary:
        Window.window
        ? Window.window.dysenAccentSecondary
        : "#7CF2FF"

    property color dim:
        Window.window
        ? Window.window.dysenAccentDim
        : "#007483"

    property color muted:
        Window.window
        ? Window.window.dysenMuted
        : "#5D7880"

    function openAt(path) {
        visible = true
        fileManagerBackend.navigate(path)
        openAnimation.restart()
    }

    function close() {
        closeAnimation.restart()
    }

    // ----------------------------------------------------------
    // BACKDROP
    // ----------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.78

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
        }
    }

    // ----------------------------------------------------------
    // MAIN WINDOW
    // ----------------------------------------------------------

    Rectangle {
        id: panel

        width: Math.min(1120, root.width - 80)
        height: Math.min(650, root.height - 100)

        anchors.centerIn: parent

        color: "#020507"

        border.width: 1
        border.color: root.accent

        radius:
            Window.window &&
            Window.window.dysenThemeName === "PINK"
            ? 10
            : 4

        opacity: 0
        scale: 0.97

        clip: true

        // ------------------------------------------------------
        // TOP ACCENT
        // ------------------------------------------------------

        Rectangle {
            x: 0
            y: 0

            width: parent.width * 0.34
            height: 2

            color: root.accent
        }

        Rectangle {
            x: 0
            y: 50

            width: parent.width
            height: 1

            color: root.dim
        }

        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Text {
            x: 24
            y: 15

            text: "DYSEN // FILE SYSTEM"

            color: root.accent

            font.family: "Monospace"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 1.8
        }

        Text {
            x: 24
            y: 34

            text: "ROOT VIEW  /  FILES + FOLDERS"

            color: root.muted

            font.family: "Monospace"
            font.pixelSize: 7
            font.letterSpacing: 1.0
        }

        Rectangle {
            id: closeButton

            anchors.right: parent.right
            anchors.top: parent.top

            anchors.rightMargin: 16
            anchors.topMargin: 13

            width: 58
            height: 25

            color: "#000000"

            border.width: 1
            border.color: root.accent

            Text {
                anchors.centerIn: parent

                text: "CLOSE"

                color: root.accent

                font.family: "Monospace"
                font.pixelSize: 7
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        // ------------------------------------------------------
        // PATH BAR
        // ------------------------------------------------------

        Rectangle {
            id: pathBar

            x: 18
            y: 66

            width: parent.width - 36
            height: 38

            color: "#000000"

            border.width: 1
            border.color: root.dim

            Text {
                x: 12
                anchors.verticalCenter: parent.verticalCenter

                text: fileManagerBackend.currentPath

                color: "#FFFFFF"

                elide: Text.ElideMiddle

                width: parent.width - 220

                font.family: "Monospace"
                font.pixelSize: 8
            }

            Rectangle {
                x: parent.width - 198
                y: 6

                width: 55
                height: 25

                color: "#000000"

                border.width: 1
                border.color: root.dim

                Text {
                    anchors.centerIn: parent
                    text: "ROOT"
                    color: root.accent
                    font.family: "Monospace"
                    font.pixelSize: 7
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileManagerBackend.goRoot()
                }
            }

            Rectangle {
                x: parent.width - 137
                y: 6

                width: 42
                height: 25

                color: "#000000"

                border.width: 1
                border.color: root.dim

                Text {
                    anchors.centerIn: parent
                    text: "↑"
                    color: root.secondary
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileManagerBackend.goUp()
                }
            }

            Rectangle {
                x: parent.width - 89
                y: 6

                width: 42
                height: 25

                color: "#000000"

                border.width: 1
                border.color: root.dim

                Text {
                    anchors.centerIn: parent
                    text: "⌂"
                    color: root.secondary
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileManagerBackend.goHome()
                }
            }

            Rectangle {
                x: parent.width - 41
                y: 6

                width: 29
                height: 25

                color: "#000000"

                border.width: 1
                border.color: root.dim

                Text {
                    anchors.centerIn: parent
                    text: "⟳"
                    color: root.secondary
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileManagerBackend.refresh()
                }
            }
        }

        // ------------------------------------------------------
        // STATUS
        // ------------------------------------------------------

        Text {
            x: 22
            y: 112

            text: fileManagerBackend.status

            color:
                fileManagerBackend.status === "PERMISSION DENIED"
                ? "#FF6B7A"
                : root.muted

            font.family: "Monospace"
            font.pixelSize: 7
        }

        // ------------------------------------------------------
        // FILE GRID
        // ------------------------------------------------------

        GridView {
            id: fileGrid

            x: 18
            y: 134

            width: parent.width - 36
            height: parent.height - 184

            clip: true

            cellWidth: 176
            cellHeight: 92

            model: fileManagerBackend.items

            delegate: Rectangle {

                width: 164
                height: 80

                color:
                    modelData.isDir
                    ? Qt.rgba(
                        root.accent.r,
                        root.accent.g,
                        root.accent.b,
                        0.035
                    )
                    : "#030708"

                border.width: 1
                border.color:
                    modelData.isDir
                    ? Qt.rgba(
                        root.accent.r,
                        root.accent.g,
                        root.accent.b,
                        0.30
                    )
                    : "#163039"

                radius: 3

                Column {
                    anchors.fill: parent
                    anchors.margins: 9

                    spacing: 5

                    Text {
                        text:
                            modelData.isDir
                            ? "▰"
                            : (modelData.isLink ? "↗" : "□")

                        color:
                            modelData.isDir
                            ? root.accent
                            : root.secondary

                        font.pixelSize: 18
                    }

                    Text {
                        width: parent.width

                        text: modelData.name

                        color: "#E6EEF0"

                        elide: Text.ElideMiddle

                        font.family: "Monospace"
                        font.pixelSize: 8
                        font.bold: modelData.isDir
                    }

                    Text {
                        width: parent.width

                        text:
                            modelData.isDir
                            ? "FOLDER"
                            : modelData.size

                        color: root.muted

                        font.family: "Monospace"
                        font.pixelSize: 6
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.LeftButton

                    onDoubleClicked: {
                        fileManagerBackend.openPath(
                            modelData.path
                        )
                    }

                    onClicked: {
                        fileInfo.text =
                            modelData.mode +
                            "   " +
                            (
                                modelData.isDir
                                ? "DIRECTORY"
                                : modelData.size
                            )
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        Text {
            id: fileInfo

            anchors.left: parent.left
            anchors.bottom: parent.bottom

            anchors.leftMargin: 20
            anchors.bottomMargin: 13

            text: "Select an item"

            color: root.muted

            font.family: "Monospace"
            font.pixelSize: 6
        }
    }

    // ----------------------------------------------------------
    // ANIMATIONS
    // ----------------------------------------------------------

    ParallelAnimation {
        id: openAnimation

        NumberAnimation {
            target: panel
            property: "opacity"

            from: 0
            to: 1

            duration: 180

            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "scale"

            from: 0.97
            to: 1

            duration: 220

            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation

        NumberAnimation {
            target: panel
            property: "opacity"

            from: 1
            to: 0

            duration: 140

            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panel
            property: "scale"

            from: 1
            to: 0.98

            duration: 140

            easing.type: Easing.InCubic
        }

        onFinished: {
            root.visible = false
            root.closed()
        }
    }
}
