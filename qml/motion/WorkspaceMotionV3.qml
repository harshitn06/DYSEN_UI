import QtQuick
import QtQuick.Window

Window {
    id: root

    width: 1100
    height: 650
    visible: true
    color: "#05080c"
    title: "DYSEN Workspace Motion V3"

    property int activeWorkspace: 1
    property int previousWorkspace: 1

    MotionController {
        id: motion
    }

    Rectangle {
        id: viewport

        anchors.centerIn: parent
        width: 900
        height: 500
        radius: 22

        color: "#0a1016"
        border.width: 1
        border.color: "#24434d"

        clip: true

        Item {
            id: scene

            width: viewport.width
            height: viewport.height

            property real targetX:
                -(activeWorkspace - 1) * width

            x: targetX

            Behavior on x {
                NumberAnimation {
                    duration: motion.calculatedDuration
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: 3

                Item {
                    width: scene.width
                    height: scene.height
                    x: index * scene.width

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 32
                        radius: 18

                        color: "#0d161e"
                        border.width: 1
                        border.color: "#294651"

                        Text {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 24

                            text: "WORKSPACE  " +
                                  String(index + 1).padStart(2, "0")

                            color: Window.window ? Window.window.dysenAccent : "#719ba5"
                            font.pixelSize: 13
                            font.letterSpacing: 3
                        }

                        Rectangle {
                            id: terminalWindow

                            width: 330
                            height: 220
                            anchors.centerIn: parent

                            radius: 16
                            color: "#111f28"
                            border.width: 1
                            border.color: Window.window ? Window.window.dysenAccent : "#3d7c89"

                            scale: index + 1 === activeWorkspace
                                   ? 1.0 : 0.94

                            opacity: index + 1 === activeWorkspace
                                     ? 1.0 : 0.55

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Math.min(
                                        motion.calculatedDuration + 40,
                                        460
                                    )
                                    easing.type: Easing.OutBack
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Math.max(
                                        140,
                                        motion.calculatedDuration - 60
                                    )
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Text {
                                anchors.centerIn: parent

                                text: "DYSEN TERMINAL"
                                color: Window.window ? Window.window.dysenAccent : "#bfeaf0"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 18

            spacing: 10

            Repeater {
                model: 3

                Rectangle {
                    width: index + 1 === activeWorkspace ? 28 : 8
                    height: 8
                    radius: 4

                    opacity: index + 1 === activeWorkspace ? 1.0 : 0.35

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 18

        spacing: 8

        Repeater {
            model: 3

            Rectangle {
                width: 90
                height: 34
                radius: 9

                color: index + 1 === activeWorkspace
                       ? "#18323b"
                       : "#0d151c"

                border.width: 1
                border.color: "#294651"

                Text {
                    anchors.centerIn: parent

                    text: "WS " + (index + 1)
                    color: Window.window ? Window.window.dysenAccent : "#a9dce4"
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var target = index + 1

                        if (target === activeWorkspace)
                            return

                        previousWorkspace = activeWorkspace

                        var distance =
                            Math.abs(target - activeWorkspace)

                        var direction =
                            target > activeWorkspace ? 1 : -1

                        motion.begin(
                            distance,
                            direction * distance
                        )

                        activeWorkspace = target

                        motion.finish()
                    }
                }
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 18

        text: "MOTION V3  •  " +
              motion.calculatedDuration + " ms"

        color: Window.window ? Window.window.dysenAccent : "#41616a"
        font.pixelSize: 11
    }
}
