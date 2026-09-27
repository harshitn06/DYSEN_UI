import QtQuick
import QtQuick.Window
import QtMultimedia

Item {
    id: root

    objectName: "startupReveal"

    property color themeAccent:
        Window.window
        ? Window.window.dysenAccent
        : "#00F6FF"

    property color themeSecondary:
        Window.window
        ? Window.window.dysenAccentSecondary
        : "#7CF2FF"

    anchors.fill: parent
    z: 999998

    visible: false

    signal startupFinished()

    property Item topBarItem: null
    property Item globePanelItem: null
    property Item metricsPanelItem: null
    property Item processesPanelItem: null
    property Item terminalPanelItem: null
    property Item signalPanelItem: null
    property Item frequencyPanelItem: null
    property Item networkPanelItem: null
    property Item diskPanelItem: null
    property Item nexusPanelItem: null
    property Item keyboardPanelItem: null
    property Item bottomBarItem: null

    property bool running: false
    property int panelIndex: -1
    property Item currentPanel: null

    property real targetX: 0
    property real targetY: 0
    property real targetWidth: 0
    property real targetHeight: 0

    // --------------------------------------------------------
    // PANEL ORDER
    // --------------------------------------------------------

    function panelList() {
        return [
            topBarItem,
            globePanelItem,
            metricsPanelItem,
            processesPanelItem,
            networkPanelItem,
            diskPanelItem,
            terminalPanelItem,
            signalPanelItem,
            frequencyPanelItem,
            keyboardPanelItem,
            nexusPanelItem,
            bottomBarItem
        ]
    }

    function cleanPanelList() {
        return [
            topBarItem,
            globePanelItem,
            metricsPanelItem,
            processesPanelItem,
            networkPanelItem,
            diskPanelItem,
            terminalPanelItem,
            signalPanelItem,
            frequencyPanelItem,
            keyboardPanelItem,
            nexusPanelItem,
            bottomBarItem
        ]
    }

    // --------------------------------------------------------
    // RESET
    // --------------------------------------------------------

    function prepare() {
        var panels = cleanPanelList()

        for (var i = 0; i < panels.length; ++i) {
            var p = panels[i]

            if (!p)
                continue

            p.visible = false
            p.opacity = 0
            p.scale = 0.985
        }

        revealFrame.visible = false
        revealLine.visible = false
        revealFrame.opacity = 0
        revealLine.opacity = 0
    }

    // --------------------------------------------------------
    // START
    // --------------------------------------------------------

    function start() {
        if (running)
            return

        prepare()

        panelIndex = -1
        running = true
        visible = true

        startTimer.restart()
    }

    // --------------------------------------------------------
    // NEXT
    // --------------------------------------------------------

    function beginNext() {
        var panels = cleanPanelList()

        panelIndex++

        if (panelIndex >= panels.length) {
            finishTimer.restart()
            return
        }

        var p = panels[panelIndex]

        if (!p) {
            nextTimer.restart()
            return
        }

        currentPanel = p

        var point = p.mapToItem(
            root,
            0,
            0
        )

        targetX = point.x
        targetY = point.y

        targetWidth = Math.max(
            10,
            p.width
        )

        targetHeight = Math.max(
            10,
            p.height
        )

        revealFrame.x =
            targetX - 3

        revealFrame.y =
            targetY - 3

        revealFrame.width =
            targetWidth + 6

        revealFrame.height =
            targetHeight + 6

        revealFrame.opacity = 0

        revealLine.x =
            targetX - 34

        revealLine.y =
            targetY + 1

        revealLine.width = 0
        revealLine.opacity = 0

        p.visible = true
        p.opacity = 0
        p.scale = 0.985

        revealAnimation.restart()
    }

    // --------------------------------------------------------
    // FINISH
    // --------------------------------------------------------

    function finish() {
        var panels = cleanPanelList()

        for (var i = 0; i < panels.length; ++i) {
            var p = panels[i]

            if (!p)
                continue

            p.visible = true
            p.opacity = 1
            p.scale = 1
        }

        revealFrame.visible = false
        revealLine.visible = false

        running = false
        visible = false

        startupFinished()
    }

    // --------------------------------------------------------
    // START DELAY
    // --------------------------------------------------------

    // ========================================================
    // PANEL AUDIO
    // ========================================================

    SoundEffect {
        id: panelSound

        source:
            Qt.resolvedUrl(
                "../assets/sounds/panel_focus.wav"
            )

        volume: 1.0
    }

    function playPanelCue() {
        if (!panelSound.playing)
            panelSound.play()
    }

    Timer {
        id: startTimer

        interval: 120
        repeat: false

        onTriggered: {
            beginNext()
        }
    }

    // --------------------------------------------------------
    // NEXT PANEL DELAY
    // --------------------------------------------------------

    Timer {
        id: nextTimer

        interval: 105
        repeat: false

        onTriggered: {
            beginNext()
        }
    }

    // --------------------------------------------------------
    // FINAL HANDOFF
    // --------------------------------------------------------

    Timer {
        id: finishTimer

        interval: 250
        repeat: false

        onTriggered: {
            finish()
        }
    }

    // --------------------------------------------------------
    // REVEAL FRAME
    // --------------------------------------------------------

    Rectangle {
        id: revealFrame

        visible: false

        color: "transparent"

        border.width: 1
        border.color: root.themeSecondary

        opacity: 0
    }

    // --------------------------------------------------------
    // TRACE LINE
    // --------------------------------------------------------

    Rectangle {
        id: revealLine

        visible: false

        height: 1

        color: root.themeAccent

        opacity: 0
    }

    // --------------------------------------------------------
    // SAFE SINGLE-PANEL ANIMATION
    // --------------------------------------------------------

    SequentialAnimation {
        id: revealAnimation

        ScriptAction {
            script: {
                revealFrame.visible = true
                revealLine.visible = true

                revealFrame.opacity = 0
                revealLine.opacity = 0

                playPanelCue()

            }
        }

        // FRAME APPEARS
        NumberAnimation {
            target: revealFrame

            property: "opacity"

            from: 0
            to: 0.82

            duration: 90
        }

        // TRACE
        ParallelAnimation {

            NumberAnimation {
                target: revealLine

                property: "width"

                from: 0
                to:
                    targetWidth * 0.75

                duration: 145

                easing.type:
                    Easing.OutCubic
            }

            NumberAnimation {
                target: revealLine

                property: "opacity"

                from: 0
                to: 0.80

                duration: 65
            }
        }

        // PANEL
        ParallelAnimation {

            NumberAnimation {
                target: currentPanel

                property: "opacity"

                from: 0
                to: 1

                duration: 250

                easing.type:
                    Easing.OutCubic
            }

            NumberAnimation {
                target: currentPanel

                property: "scale"

                from: 0.985
                to: 1

                duration: 230

                easing.type:
                    Easing.OutCubic
            }
        }

        // FRAME DISAPPEARS
        ParallelAnimation {

            NumberAnimation {
                target: revealFrame

                property: "opacity"

                from: 0.82
                to: 0

                duration: 210

                easing.type:
                    Easing.OutCubic
            }

            NumberAnimation {
                target: revealLine

                property: "opacity"

                from: 0.80
                to: 0

                duration: 130

                easing.type:
                    Easing.OutCubic
            }
        }

        PauseAnimation {
            duration: 70
        }

        ScriptAction {
            script: {
                revealFrame.visible = false
                revealLine.visible = false

                nextTimer.restart()
            }
        }
    }

    Component.onCompleted: {
        running = false
        visible = false
    }
}
