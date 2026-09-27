import QtQuick
import QtQuick.Window

Window {
    id: root

    width: 900
    height: 520
    visible: true
    title: "DYSEN Motion Engine"
    color: "#070a0f"

    DysenMotion {
        id: motion
    }

    Rectangle {
        id: workspace

        anchors.centerIn: parent
        width: 620
        height: 300
        radius: 18

        color: "#0d141c"
        border.width: 1
        border.color: "#294651"

        clip: true

        Rectangle {
            id: panel

            width: 220
            height: 150
            radius: 16

            x: 35
            y: 75

            color: "#14242d"
            border.width: 1
            border.color: Window.window ? Window.window.dysenAccent : "#3d7c89"

            scale: 1.0
            opacity: 1.0

            Text {
                anchors.centerIn: parent

                text: "DYSEN"
                color: Window.window ? Window.window.dysenAccent : "#bfeaf0"
                font.pixelSize: 28
                font.bold: true
            }

            Behavior on x {
                NumberAnimation {
                    duration: motion.duration("workspace")
                    easing.type: motion.easing("smooth")
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: motion.duration("workspace")
                    easing.type: motion.easing("smooth")
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: motion.duration("normal")
                    easing.type: motion.easing("spring")
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: motion.duration("fast")
                    easing.type: motion.easing("smooth")
                }
            }
        }

        Text {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20

            text: "WORKSPACE  01"
            color: Window.window ? Window.window.dysenAccent : "#6d9da7"
            font.pixelSize: 13
            font.letterSpacing: 2
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (panel.x < 200) {
                panel.x = 365
                panel.y = 35
                panel.scale = 1.08
                panel.opacity = 0.92
            } else {
                panel.x = 35
                panel.y = 75
                panel.scale = 1.0
                panel.opacity = 1.0
            }
        }
    }
}
