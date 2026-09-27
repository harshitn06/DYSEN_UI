import QtQuick
import QtMultimedia

Item {
    id: root

    anchors.fill: parent
    z: 1000000
    visible: false

    property bool active: false

    property string username:
        typeof dysenUserName !== "undefined"
        ? dysenUserName
        : "USER"

    property string hostname:
        typeof dysenHostName !== "undefined"
        ? dysenHostName
        : "DYSEN"

    property string welcomeTitle: "WELCOME"

    property string developerMessage:
        "DYSEN is a custom desktop experience built around interaction and control. "
        + "Every HUD panel can be dragged and repositioned, letting you shape the "
        + "workspace around the way you use it. Explore system telemetry, processes, "
        + "terminal access, Earth data, network and disk activity, keyboard controls, "
        + "and the modular HUD interface."

    property string nexusMessage:
        "NEXUS is currently under development. "
        + "The next layer of the DYSEN experience is coming soon."

    property int typingInterval: 22
    property int typedIndex: 0

    property int panelW:
        Math.min(920, Math.max(720, root.width - 80))

    property int panelH:
        Math.min(540, Math.max(460, root.height - 80))

    signal started()

    // ------------------------------------------------------------
    // AUDIO
    // ------------------------------------------------------------

    SoundEffect {
        id: openFx
        source: "../assets/sounds/panel_open.wav"
        volume: 1.0
    }

    SoundEffect {
        id: typeFx
        source: "../assets/sounds/key.wav"
        volume: 1.0
    }

    SoundEffect {
        id: clickFx
        source: "../assets/sounds/enter.wav"
        volume: 1.0
    }

    // ------------------------------------------------------------
    // TYPING
    // ------------------------------------------------------------

    Timer {
        id: typingTimer

        interval: root.typingInterval
        repeat: true

        onTriggered: {
            if (root.typedIndex >= root.welcomeTitle.length) {
                stop()
                return
            }

            root.typedIndex++

            typedWelcome.text =
                root.welcomeTitle.substring(0, root.typedIndex)

            if (root.typedIndex % 2 === 0 && !typeFx.playing)
                typeFx.play()
        }
    }

    // ------------------------------------------------------------
    // MODAL BACKDROP
    // This deliberately consumes pointer input so that the
    // DYSEN panels underneath cannot be dragged while this
    // welcome screen is active.
    // ------------------------------------------------------------

    Rectangle {
        id: backdrop

        anchors.fill: parent
        color: "black"
        opacity: 0
    }

    MouseArea {
        id: modalBlocker

        anchors.fill: parent

        z: 1

        enabled: root.visible

        acceptedButtons: Qt.AllButtons

        hoverEnabled: false

        onPressed: mouse.accepted = true
        onReleased: mouse.accepted = true
        onClicked: mouse.accepted = true
    }

    // ------------------------------------------------------------
    // PANEL
    // ------------------------------------------------------------

    Rectangle {
        id: panel

        width: root.panelW
        height: root.panelH

        anchors.centerIn: parent

        z: 10

        radius: 6

        color: Qt.rgba(0.006, 0.012, 0.018, 0.985)

        border.width: 1
        border.color: Qt.rgba(0.20, 0.86, 1.0, 0.72)

        opacity: 0
        scale: 0.90

        clip: true

        // Inner frame
        Rectangle {
            anchors.fill: parent
            anchors.margins: 7

            color: "transparent"

            border.width: 1
            border.color: Qt.rgba(0.15, 0.70, 0.88, 0.13)
        }

        // Top construction line
        Rectangle {
            id: topTrace

            x: 0
            y: 0

            width: 0
            height: 2

            color: Qt.rgba(0.24, 0.94, 1.0, 0.98)
        }

        // Bottom construction line
        Rectangle {
            id: bottomTrace

            x: 0
            y: height - 2

            width: 0
            height: 2

            color: Qt.rgba(0.13, 0.76, 1.0, 0.64)
        }

        // Corner geometry
        Rectangle {
            x: 15
            y: 15
            width: 28
            height: 1
            color: Qt.rgba(0.30, 0.92, 1.0, 0.86)
        }

        Rectangle {
            x: 15
            y: 15
            width: 1
            height: 28
            color: Qt.rgba(0.30, 0.92, 1.0, 0.86)
        }

        Rectangle {
            x: width - 43
            y: 15
            width: 28
            height: 1
            color: Qt.rgba(0.30, 0.92, 1.0, 0.86)
        }

        Rectangle {
            x: width - 16
            y: 15
            width: 1
            height: 28
            color: Qt.rgba(0.30, 0.92, 1.0, 0.86)
        }

        // Scan divider
        Rectangle {
            id: scanLine

            x: 28
            y: 86

            width: parent.width - 56
            height: 1

            color: Qt.rgba(0.18, 0.76, 1.0, 0.18)

            opacity: 0
        }

        // --------------------------------------------------------
        // CONTENT
        // --------------------------------------------------------

        Item {
            id: content

            anchors.fill: parent
            anchors.margins: 34

            opacity: 0
        }

        // Header
        Row {
            anchors.left: content.left
            anchors.top: content.top

            spacing: 14

            Text {
                text: "DYSEN // INITIALIZATION COMPLETE"

                color: Qt.rgba(0.28, 0.88, 1.0, 0.88)

                font.family: "Monospace"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.7
            }

            Text {
                text: "[ READY ]"

                color: Qt.rgba(0.45, 1.0, 0.70, 0.88)

                font.family: "Monospace"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.3
            }
        }

        // Main title
        Text {
            id: typedWelcome

            anchors.left: content.left
            anchors.top: content.top
            anchors.topMargin: 35

            text: ""

            color: "white"

            font.family: "Monospace"
            font.pixelSize: 34
            font.bold: true
            font.letterSpacing: 5
        }

        // Identity
        Row {
            anchors.left: content.left
            anchors.top: content.top
            anchors.topMargin: 79

            spacing: 22

            Text {
                text: "USER // " + root.username.toUpperCase()

                color: Qt.rgba(0.68, 0.84, 0.90, 0.88)

                font.family: "Monospace"
                font.pixelSize: 10
                font.letterSpacing: 1.1
            }

            Text {
                text: "HOST // " + root.hostname.toUpperCase()

                color: Qt.rgba(0.46, 0.66, 0.72, 0.82)

                font.family: "Monospace"
                font.pixelSize: 10
                font.letterSpacing: 1.1
            }
        }

        // Main divider
        Rectangle {
            anchors.left: content.left
            anchors.right: content.right
            anchors.top: content.top
            anchors.topMargin: 112

            height: 1

            color: Qt.rgba(0.18, 0.76, 1.0, 0.22)
        }

        // --------------------------------------------------------
        // LEFT: MESSAGE
        // --------------------------------------------------------

        Item {
            id: messageColumn

            anchors.left: content.left
            anchors.top: content.top
            anchors.topMargin: 132

            width: content.width * 0.54
            height: 220

            Text {
                text: "MESSAGE FROM THE DEVELOPER"

                color: Qt.rgba(0.27, 0.89, 1.0, 0.90)

                font.family: "Monospace"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 28

                text: root.developerMessage

                color: Qt.rgba(0.80, 0.89, 0.93, 0.91)

                font.family: "Monospace"
                font.pixelSize: 11

                wrapMode: Text.WordWrap
                lineHeight: 1.55
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: 1

                color: Qt.rgba(0.15, 0.65, 0.82, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15

                text: "PANELS ARE DRAGGABLE // BUILD YOUR OWN WORKSPACE"

                color: Qt.rgba(0.36, 0.72, 0.80, 0.80)

                font.family: "Monospace"
                font.pixelSize: 9
                font.letterSpacing: 0.8
            }
        }

        // --------------------------------------------------------
        // RIGHT: FEATURES
        // --------------------------------------------------------

        Item {
            id: featureColumn

            anchors.right: content.right
            anchors.top: content.top
            anchors.topMargin: 132

            width: content.width * 0.38
            height: 220

            Text {
                text: "DYSEN FUNCTIONS"

                color: Qt.rgba(0.27, 0.89, 1.0, 0.90)

                font.family: "Monospace"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            Column {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 28

                spacing: 8

                Repeater {
                    model: [
                        "LIVE SYSTEM METRICS",
                        "PROCESS MONITORING",
                        "TERMINAL INTERFACE",
                        "EARTH / GLOBE DATA",
                        "NETWORK + DISK STATUS",
                        "VIRTUAL KEYBOARD",
                        "MODULAR HUD PANELS",
                        "CUSTOM INTERACTION FX"
                    ]

                    delegate: Text {
                        text: "▸  " + modelData

                        color: Qt.rgba(0.68, 0.82, 0.87, 0.86)

                        font.family: "Monospace"
                        font.pixelSize: 9
                        font.letterSpacing: 0.7
                    }
                }
            }
        }

        // Vertical divider
        Rectangle {
            anchors.left: content.left
            anchors.leftMargin: content.width * 0.57
            anchors.top: content.top
            anchors.topMargin: 132

            width: 1
            height: 220

            color: Qt.rgba(0.18, 0.72, 0.88, 0.17)
        }

        // --------------------------------------------------------
        // NEXUS STRIP
        // --------------------------------------------------------

        Rectangle {
            anchors.left: content.left
            anchors.right: content.right
            anchors.top: content.top
            anchors.topMargin: 370

            height: 58

            color: Qt.rgba(0.018, 0.055, 0.070, 0.78)

            border.width: 1
            border.color: Qt.rgba(0.16, 0.68, 0.82, 0.22)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 10

                text: "NEXUS // DEVELOPMENT STATUS"

                color: Qt.rgba(0.27, 0.88, 1.0, 0.88)

                font.family: "Monospace"
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 1.2
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 9

                text: root.nexusMessage

                color: Qt.rgba(0.56, 0.70, 0.75, 0.84)

                font.family: "Monospace"
                font.pixelSize: 9
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: "COMING SOON"

                color: Qt.rgba(0.45, 1.0, 0.68, 0.78)

                font.family: "Monospace"
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 1.1
            }
        }

        // --------------------------------------------------------
        // FOOTER / DEVELOPER CREDIT / CONTACT / START
        // --------------------------------------------------------

        Text {
            anchors.left: content.left
            anchors.bottom: content.bottom
            anchors.bottomMargin: 7

            text: "DEVELOPED BY // HARSHIT"

            color: Qt.rgba(0.72, 0.84, 0.88, 0.88)

            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.0
        }

        Text {
            anchors.left: content.left
            anchors.bottom: content.bottom
            anchors.bottomMargin: 7
            anchors.leftMargin: 180

            text: "INSTAGRAM // @tech.mate0"

            color: Qt.rgba(0.30, 0.86, 1.0, 0.90)

            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 0.9
        }

        Text {
            anchors.right: startButton.left
            anchors.rightMargin: 20
            anchors.verticalCenter: startButton.verticalCenter

            text: "THANK YOU FOR EXPLORING DYSEN."

            color: Qt.rgba(0.48, 0.66, 0.72, 0.78)

            font.family: "Monospace"
            font.pixelSize: 9
            font.letterSpacing: 0.7
        }

        Item {
            id: startButton

            anchors.right: content.right
            anchors.bottom: content.bottom

            width: 188
            height: 42

            opacity: 0
            scale: 0.92

            z: 20

            Rectangle {
                anchors.fill: parent

                radius: 4

                color: startMouse.containsMouse
                    ? Qt.rgba(0.16, 0.72, 0.92, 0.20)
                    : Qt.rgba(0.04, 0.16, 0.21, 0.78)

                border.width: 1

                border.color: startMouse.containsMouse
                    ? Qt.rgba(0.35, 0.95, 1.0, 0.96)
                    : Qt.rgba(0.18, 0.72, 1.0, 0.60)
            }

            Text {
                anchors.centerIn: parent

                text: "START DYSEN"

                color: "white"

                font.family: "Monospace"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 9
                anchors.top: parent.top
                anchors.topMargin: 5

                text: "01"

                color: Qt.rgba(0.30, 0.90, 1.0, 0.60)

                font.family: "Monospace"
                font.pixelSize: 7
            }

            MouseArea {
                id: startMouse

                anchors.fill: parent

                hoverEnabled: true

                onClicked: root.accept()
            }
        }
    }

    // ------------------------------------------------------------
    // SHOW
    // ------------------------------------------------------------

    SequentialAnimation {
        id: showAnimation

        ScriptAction {
            script: {
                root.visible = true
                root.active = false

                root.typedIndex = 0
                typedWelcome.text = ""

                backdrop.opacity = 0

                panel.opacity = 0
                panel.scale = 0.90

                content.opacity = 0
                scanLine.opacity = 0

                topTrace.width = 0
                bottomTrace.width = 0

                startButton.opacity = 0
                startButton.scale = 0.92

                openFx.play()
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: backdrop
                property: "opacity"
                from: 0
                to: 0.62
                duration: 280
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: panel
                property: "opacity"
                from: 0
                to: 1
                duration: 260
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: panel
                property: "scale"
                from: 0.90
                to: 1
                duration: 420
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: topTrace
                property: "width"
                from: 0
                to: root.panelW
                duration: 350
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: bottomTrace
                property: "width"
                from: 0
                to: root.panelW
                duration: 430
                easing.type: Easing.OutCubic
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: content
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: scanLine
                property: "opacity"
                from: 0
                to: 1
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: typingTimer.start()
        }

        PauseAnimation {
            duration: root.welcomeTitle.length * root.typingInterval + 160
        }

        ParallelAnimation {
            NumberAnimation {
                target: startButton
                property: "opacity"
                from: 0
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: startButton
                property: "scale"
                from: 0.92
                to: 1
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: root.active = true
        }
    }

    // ------------------------------------------------------------
    // HIDE
    // ------------------------------------------------------------

    ParallelAnimation {
        id: hideAnimation

        ScriptAction {
            script: {
                root.active = false
                typingTimer.stop()
                clickFx.play()
            }
        }

        NumberAnimation {
            target: startButton
            property: "opacity"
            from: 1
            to: 0
            duration: 130
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: content
            property: "opacity"
            from: 1
            to: 0
            duration: 220
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panel
            property: "scale"
            from: 1
            to: 0.97
            duration: 300
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panel
            property: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: backdrop
            property: "opacity"
            from: 0.62
            to: 0
            duration: 320
            easing.type: Easing.InCubic
        }

        onFinished: {
            root.visible = false
            root.started()
        }
    }

    onVisibleChanged: {
        if (!visible)
            typingTimer.stop()
    }

    function show() {
        showAnimation.restart()
    }

    function accept() {
        if (!root.active)
            return

        hideAnimation.restart()
    }
}
