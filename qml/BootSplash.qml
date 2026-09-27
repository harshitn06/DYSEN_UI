import QtQuick
import QtQuick.Window
import QtMultimedia

Item {
    id: root

    objectName: "bootSplash"

    property color themeAccent:
        Window.window
        ? Window.window.dysenAccent
        : "#00F6FF"

    property color themeAccentBright:
        Window.window
        ? Window.window.dysenAccentBright
        : Qt.lighter("#00F6FF", 1.15)

    property color themeAccentDim:
        Window.window
        ? Window.window.dysenAccentDim
        : Qt.darker("#00F6FF", 1.80)


    property url themeLogoSource:
        Window.window
        ? Qt.resolvedUrl(
            "../assets/themes/dysen_mark_" +
            String(Window.window.dysenThemeName).toLowerCase() +
            ".svg"
        )
        : Qt.resolvedUrl("../assets/dysen_mark.svg")
    anchors.fill: parent
    z: 9999

    visible: true
    opacity: 1.0

    signal bootFinished()
    signal completed()

    property real progress: 0
    property int stageIndex: 0

    property bool finishing: false
    property bool bootSignalSent: false

    property real logoBuild: 0
    property real logoOpacity: 0
    property real logoScale: 0.82
    property real logoEnergy: 0

    property real wordmarkReveal: 0
    property real readyReveal: 0

    property var stages: [
        "POWER / CORE INITIALIZATION",
        "IDENTITY / GEOMETRY ACQUISITION",
        "VISUAL / ENGINE SYNCHRONIZATION",
        "CHANNEL / SYSTEM CALIBRATION",
        "DESKTOP / GRAPH ACTIVATION",
        "LINK / LOCAL SESSION READY",
        "INTERFACE / HANDOFF"
    ]

    property string stageText:
        stages[
            Math.min(
                stageIndex,
                stages.length - 1
            )
        ]

    function safePlay(sound) {
        if (!sound)
            return

        if (!sound.playing)
            sound.play()
    }

    function stopLoadingAudio() {
        powerFx.stop()
        scanFx.stop()
        readyFx.stop()
        expandFx.stop()
    }

    function finish() {
        if (finishing)
            return

        finishing = true
        stopLoadingAudio()
        finishAnimation.restart()
    }

    function emitBootFinishedOnce() {
        if (bootSignalSent)
            return

        bootSignalSent = true
        root.bootFinished()
        handoffDelay.restart()
    }

    onProgressChanged: {
        stageIndex =
            Math.min(
                stages.length - 1,
                Math.floor(progress / 15)
            )
    }

    // ========================================================
    // BACKGROUND
    // ========================================================

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.26
    }

    // Lightweight static technical grid.
    Item {
        anchors.fill: parent
        opacity: 0.10

        Repeater {
            model: Math.ceil(root.width / 96)

            Rectangle {
                x: index * 96
                width: 1
                height: root.height
                color: root.themeAccentDim
            }
        }

        Repeater {
            model: Math.ceil(root.height / 96)

            Rectangle {
                y: index * 96
                width: root.width
                height: 1
                color: root.themeAccentDim
            }
        }
    }

    // ========================================================
    // CORNER SYSTEM
    // ========================================================

    Rectangle {
        x: 30
        y: 30
        width: 130
        height: 1
        color: root.themeAccent
        opacity: 0.48
    }

    Rectangle {
        x: 30
        y: 30
        width: 1
        height: 74
        color: root.themeAccent
        opacity: 0.48
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 30
        anchors.topMargin: 30
        width: 130
        height: 1
        color: root.themeAccent
        opacity: 0.48
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 30
        anchors.topMargin: 30
        width: 1
        height: 74
        color: root.themeAccent
        opacity: 0.48
    }

    Text {
        x: 32
        y: 16

        text: "DYSEN // STARTUP ENGINE"

        color: root.themeAccent

        font.family: "Monospace"
        font.pixelSize: 9
        font.bold: true
        font.letterSpacing: 2.2
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 32
        y: 16

        text: "INITIALIZATION 01"

        color: root.themeAccent

        font.family: "Monospace"
        font.pixelSize: 9
        font.bold: true
        font.letterSpacing: 1.5
    }

    // ========================================================
    // MASTER SCAN
    // ========================================================

    Rectangle {
        id: scanLine

        x: parent.width * 0.14
        width: parent.width * 0.72

        y: -10
        height: 1

        color: root.themeAccent
        opacity: 0.18

        SequentialAnimation on y {
            running: !root.finishing
            loops: Animation.Infinite

            NumberAnimation {
                from: -10
                to: root.height + 10
                duration: 4200
                easing.type: Easing.Linear
            }

            PauseAnimation {
                duration: 300
            }
        }
    }

    // ========================================================
    // LOGO
    // ========================================================

    Item {
        id: logoSystem

        width: 330
        height: 330

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -54

        opacity: root.logoOpacity
        scale: root.logoScale

        // Ghost geometry remains static.
        Image {
            anchors.centerIn: parent

            width: 250
            height: 250

            source:
                root.themeLogoSource

            sourceSize.width: 512
            sourceSize.height: 512

            fillMode: Image.PreserveAspectFit
            smooth: true
            cache: true
opacity: 0.045
        }

        // Actual logo is revealed through a cheap clip window.
        Item {
            id: logoClip

            width: 250 * root.logoBuild
            height: 250

            anchors.left:
                parent.left

            anchors.leftMargin: 40
            anchors.verticalCenter:
                parent.verticalCenter

            clip: true

            Image {
                width: 250
                height: 250

                anchors.left: parent.left
                anchors.verticalCenter:
                    parent.verticalCenter

                source: root.themeLogoSource

                sourceSize.width: 512
                sourceSize.height: 512

                fillMode: Image.PreserveAspectFit
                smooth: true
                cache: true

                opacity:
                    0.42 +
                    root.logoEnergy * 0.58
            }
        }

        // Thin construction axis.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter

            y: 32

            width: 1
            height: 266

            color: root.themeAccent

            opacity:
                0.08 +
                root.logoBuild * 0.14
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter

            x: 20
            width: 290
            height: 1

            color: root.themeAccent

            opacity:
                0.06 +
                root.logoBuild * 0.12
        }

        // Energy sweep. GPU-cheap.
        Rectangle {
            id: logoSweep

            x:
                40 +
                (
                    250 * root.logoEnergy
                )

            y: 38

            width: 3
            height: 254

            color: root.themeAccent

            opacity:
                root.logoEnergy > 0
                ? 0.80
                : 0
        }

        // Four technical anchors.
        Rectangle {
            x: 31
            y: 54
            width: 11
            height: 1
            color: root.themeAccent
            opacity: root.logoBuild
        }

        Rectangle {
            x: 31
            y: 54
            width: 1
            height: 11
            color: root.themeAccent
            opacity: root.logoBuild
        }

        Rectangle {
            x: 288
            y: 54
            width: 11
            height: 1
            color: root.themeAccent
            opacity: root.logoBuild
        }

        Rectangle {
            x: 298
            y: 54
            width: 1
            height: 11
            color: root.themeAccent
            opacity: root.logoBuild
        }
    }

    // ========================================================
    // WORDMARK
    // ========================================================

    Column {
        anchors.horizontalCenter: parent.horizontalCenter

        y: parent.height * 0.64

        spacing: 10

        opacity: root.wordmarkReveal

        scale:
            0.90 +
            root.wordmarkReveal * 0.10

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "D Y S E N"

            color: root.themeAccent

            font.family: "Monospace"
            font.pixelSize: 36
            font.bold: true
            font.letterSpacing: 8
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text:
                "SYSTEMS / INTELLIGENCE / CONTROL"

            color: root.themeAccent

            font.family: "Monospace"
            font.pixelSize: 8
            font.bold: true
            font.letterSpacing: 3.0
        }
    }

    // ========================================================
    // STATUS
    // ========================================================

    Column {
        anchors.horizontalCenter: parent.horizontalCenter

        y: parent.height * 0.78

        width: parent.width * 0.54

        spacing: 9

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: root.stageText

            color: root.themeAccent

            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.8
        }

        Rectangle {
            width: parent.width
            height: 2

            color: Qt.rgba(root.themeAccent.r, root.themeAccent.g, root.themeAccent.b, 0.10)

            Rectangle {
                width:
                    parent.width *
                    Math.max(
                        0,
                        Math.min(
                            1,
                            root.progress / 100
                        )
                    )

                height: parent.height

                color: root.themeAccent

                Behavior on width {
                    NumberAnimation {
                        duration: 90
                        easing.type:
                            Easing.OutCubic
                    }
                }
            }
        }

        Row {
            anchors.horizontalCenter:
                parent.horizontalCenter

            spacing: 16

            Text {
                text: "CORE"
                color: root.themeAccent
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
            }

            Text {
                text:
                    Math.round(
                        root.progress
                    ).toString()

                color: root.themeAccent
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
            }

            Text {
                text: "%"
                color: root.themeAccent
                font.family: "Monospace"
                font.pixelSize: 8
            }

            Text {
                text: "LOCAL"
                color: root.themeAccent
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        y: parent.height * 0.89

        text: "[ SYSTEM READY ]"

        color: root.themeAccent

        opacity: root.readyReveal

        scale:
            0.84 +
            root.readyReveal * 0.16

        font.family: "Monospace"
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 3
    }

    // ========================================================
    // AUDIO
    // Only four deliberate cues.
    // ========================================================

    // ========================================================
    // LOGO AUDIO CUES
    // ========================================================

    SoundEffect {
        id: logoBuildFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_module.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: logoSweepFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_scan.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: logoLockFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_ready.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: powerFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_power.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: scanFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_scan.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: readyFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/boot_ready.wav"
            )

        volume: 1.0
    }

    SoundEffect {
        id: expandFx

        source:
            Qt.resolvedUrl(
                "../assets/sounds/expand.wav"
            )

        volume: 1.0
    }

    // ========================================================
    // BOOT SEQUENCE
    // ========================================================

    SequentialAnimation {
        id: bootSequence

        running: true

        ScriptAction {
            script: {
                root.progress = 0
                root.logoBuild = 0
                root.logoOpacity = 0
                root.logoScale = 0.82
                root.logoEnergy = 0
                root.wordmarkReveal = 0
                root.readyReveal = 0
                safePlay(powerFx)
            }
        }

        PauseAnimation {
            duration: 180
        }

        ScriptAction {
            script: safePlay(logoBuildFx)
        }

        ParallelAnimation {

            NumberAnimation {
                target: root
                property: "logoOpacity"

                from: 0
                to: 1

                duration: 220
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: root
                property: "logoScale"

                from: 0.82
                to: 1.0

                duration: 920
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: root
                property: "logoBuild"

                from: 0
                to: 1

                duration: 840
                easing.type: Easing.InOutCubic
            }

            NumberAnimation {
                target: root
                property: "progress"

                from: 0
                to: 36

                duration: 1080
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: safePlay(scanFx)
        }

        ScriptAction {
            script: safePlay(logoSweepFx)
        }

        ParallelAnimation {

            NumberAnimation {
                target: root
                property: "logoEnergy"

                from: 0
                to: 1

                duration: 420
                easing.type: Easing.InOutCubic
            }

            NumberAnimation {
                target: root
                property: "progress"

                from: 36
                to: 58

                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        NumberAnimation {
            target: root
            property: "logoEnergy"

            from: 1
            to: 0

            duration: 340

            easing.type: Easing.OutCubic
        }

        ScriptAction {
            script: safePlay(logoLockFx)
        }

        ParallelAnimation {

            NumberAnimation {
                target: root
                property: "wordmarkReveal"

                from: 0
                to: 1

                duration: 680

                easing.type:
                    Easing.OutCubic
            }

            NumberAnimation {
                target: root
                property: "progress"

                from: 58
                to: 82

                duration: 760

                easing.type:
                    Easing.OutCubic
            }
        }

        ParallelAnimation {

            NumberAnimation {
                target: root
                property: "readyReveal"

                from: 0
                to: 1

                duration: 360

                easing.type:
                    Easing.OutCubic
            }

            NumberAnimation {
                target: root
                property: "progress"

                from: 82
                to: 97

                duration: 420

                easing.type:
                    Easing.OutCubic
            }
        }

        ScriptAction {
            script: {
                safePlay(readyFx)
                safePlay(expandFx)
            }
        }

        NumberAnimation {
            target: root
            property: "progress"

            from: 97
            to: 100

            duration: 300

            easing.type:
                Easing.OutCubic
        }

        PauseAnimation {
            duration: 260
        }

        ScriptAction {
            script:
                emitBootFinishedOnce()
        }
    }

    // ========================================================
    // HANDOFF
    // ========================================================

    Timer {
        id: handoffDelay

        interval: 180
        repeat: false

        onTriggered: {
            root.finish()
        }
    }

    ParallelAnimation {
        id: finishAnimation

        NumberAnimation {
            target: root

            property: "opacity"

            from: 1
            to: 0

            duration: 520

            easing.type:
                Easing.InOutCubic
        }

        NumberAnimation {
            target: logoSystem

            property: "scale"

            from: 1
            to: 1.045

            duration: 520

            easing.type:
                Easing.InCubic
        }
    }

    Connections {
        target: finishAnimation

        function onStopped() {
            stopLoadingAudio()

            root.visible = false
            root.opacity = 1.0

            root.completed()
        }
    }

    Component.onCompleted: {
        root.visible = true
        root.opacity = 1.0
    }
}
