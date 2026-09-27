import QtQuick
import QtQuick.Window
import QtMultimedia

Window {

    id: root

    visible: true
    visibility: Window.FullScreen

    width: 1366
    height: 768

    color: "#000000"

    title: "DYSEN"

    // =========================================================
    // DYSEN USER PREFERENCES / CENTRAL THEME ENGINE
    // =========================================================

    function storedSetting(key, fallback) {
        var value = dysenSettingsBridge.get(key)
        if (value === undefined || value === null || value === "")
            return fallback
        return value
    }

    property color dysenAccent:
        String(root.storedSetting("accentColor", "#00F6FF"))

    function themeNameForAccent(value) {
        var v = String(value).toUpperCase()
        if (v === "#F5F7FA") return "WHITE"
        if (v === "#A78BFA") return "VIOLET"
        if (v === "#35F0A0") return "GREEN"
        if (v === "#FFB84A") return "AMBER"
        if (v === "#FF6EA8") return "PINK"
        if (v === "#FF4D6D") return "RED"
        if (v === "#4DA3FF") return "BLUE"
        return "CYAN"
    }

    function dysenThemeSpecFor(name) {
        var n = String(name).toUpperCase()
        switch (n) {
        case "WHITE":
            return {
                primary: "#F5F7FA",
                secondary: "#AEB7C2",
                dim: "#4B535D",
                glow: "#FFFFFF",
                bright: "#FFFFFF",
                panelFill: "#000000",
                headerFill: "#0A0A0B",
                muted: "#707982",
                grid: "#2E3338",
                motif: "PRECISION // GLASS",
                label: "PRECISION CORE",
                radius: 5,
                borderWidth: 1,
                glowOpacity: 0.02,
                topAccentLength: 105,
                bottomAccentLength: 58
            }
        case "VIOLET":
            return {
                primary: "#A78BFA",
                secondary: "#D9C9FF",
                dim: "#5E4A91",
                glow: "#C2AFFF",
                bright: "#E2D9FF",
                panelFill: "#000000",
                headerFill: "#09060F",
                muted: "#766B87",
                grid: "#33274E",
                motif: "AURORA // NEBULA",
                label: "AURORA SYSTEM",
                radius: 9,
                borderWidth: 1,
                glowOpacity: 0.075,
                topAccentLength: 155,
                bottomAccentLength: 82
            }
        case "GREEN":
            return {
                primary: "#35F0A0",
                secondary: "#A8FFD8",
                dim: "#176B4B",
                glow: "#56FFB3",
                bright: "#B9FFE0",
                panelFill: "#000000",
                headerFill: "#04100B",
                muted: "#668C7A",
                grid: "#173F30",
                motif: "TERMINAL // BIO-TECH",
                label: "BIO-TECH CORE",
                radius: 4,
                borderWidth: 1,
                glowOpacity: 0.05,
                topAccentLength: 130,
                bottomAccentLength: 72
            }
        case "AMBER":
            return {
                primary: "#FFB84A",
                secondary: "#FFE1A6",
                dim: "#8B5B1D",
                glow: "#FFC76A",
                bright: "#FFE8B8",
                panelFill: "#000000",
                headerFill: "#100B04",
                muted: "#8E7960",
                grid: "#4B3315",
                motif: "COCKPIT // INDUSTRIAL",
                label: "COCKPIT SYSTEM",
                radius: 3,
                borderWidth: 1.4,
                glowOpacity: 0.07,
                topAccentLength: 150,
                bottomAccentLength: 82
            }
        case "PINK":
            return {
                primary: "#FF6EA8",
                secondary: "#FFC3DA",
                dim: "#8D3E5D",
                glow: "#FF8FBC",
                bright: "#FFD5E4",
                panelFill: "#000000",
                headerFill: "#10050A",
                muted: "#916E7D",
                grid: "#4A2033",
                motif: "FLORAL // TECH",
                label: "FLORAL-TECH",
                radius: 11,
                borderWidth: 1,
                glowOpacity: 0.09,
                topAccentLength: 175,
                bottomAccentLength: 92
            }
        case "RED":
            return {
                primary: "#FF4D6D",
                secondary: "#FFABB9",
                dim: "#8D2739",
                glow: "#FF617E",
                bright: "#FFC0CA",
                panelFill: "#000000",
                headerFill: "#100306",
                muted: "#91646C",
                grid: "#4A1823",
                motif: "WARNING // HIGH ALERT",
                label: "HIGH ALERT",
                radius: 2,
                borderWidth: 1.5,
                glowOpacity: 0.11,
                topAccentLength: 155,
                bottomAccentLength: 78
            }
        case "BLUE":
            return {
                primary: "#4DA3FF",
                secondary: "#A9D4FF",
                dim: "#285A91",
                glow: "#6DB6FF",
                bright: "#C5E4FF",
                panelFill: "#000000",
                headerFill: "#040A12",
                muted: "#67829E",
                grid: "#1E3E5E",
                motif: "ICE // DEEP TECH",
                label: "ICE / DEEP TECH",
                radius: 6,
                borderWidth: 1,
                glowOpacity: 0.055,
                topAccentLength: 125,
                bottomAccentLength: 74
            }
        default:
            return {
                primary: "#00F6FF",
                secondary: "#7CF2FF",
                dim: "#007483",
                glow: "#27FFFF",
                bright: "#7CFFFF",
                panelFill: "#000000",
                headerFill: "#020A0C",
                muted: "#5D7880",
                grid: "#21434B",
                motif: "CYBER // SCAN",
                label: "CYBER INTERFACE",
                radius: 3,
                borderWidth: 1,
                glowOpacity: 0.035,
                topAccentLength: 130,
                bottomAccentLength: 70
            }
        }
    }

    property string dysenThemeName:
        root.themeNameForAccent(root.dysenAccent)

    function themeBgmSourceFor(themeName) {
        return Qt.resolvedUrl(
            "../assets/sounds/dysen_bgm_" +
            String(themeName).toLowerCase() +
            ".wav"
        )
    }

    property url dysenThemeBgmSource:
        root.themeBgmSourceFor(root.dysenThemeName)

    property string dysenThemeLabel:
        root.dysenThemeSpec.label

    property var dysenThemeSpec:
        root.dysenThemeSpecFor(root.dysenThemeName)

    property color dysenAccentSecondary: root.dysenThemeSpec.secondary
    property color dysenAccentDim: root.dysenThemeSpec.dim
    property color dysenAccentGlow: root.dysenThemeSpec.glow
    property color dysenAccentBright: root.dysenThemeSpec.bright
    property color dysenPanelFill: root.dysenThemeSpec.panelFill
    property color dysenHeaderFill: root.dysenThemeSpec.headerFill
    property color dysenMuted: root.dysenThemeSpec.muted
    property color dysenGrid: root.dysenThemeSpec.grid
    property string dysenThemeMotif: root.dysenThemeSpec.motif

    // Keep DYSEN panels visually dark while the workspace background
    // remains pure black.
    property real dysenPanelOpacity: 0.96

    property real dysenBgmVolume:
        Math.max(
            0.0,
            Math.min(
                1.0,
                Number(root.storedSetting("bgmVolume", 0.80))
            )
        )

    property bool dysenBgmEnabled:
        (root.storedSetting("bgmEnabled", true) === true)
        || String(root.storedSetting("bgmEnabled", true)).toLowerCase() === "true"

    property bool dysenSessionStarted: false

    // =========================================================
    // DYSEN SESSION BGM
    // =========================================================

    AudioOutput {
        id: dysenBgmOutput

        volume:
            root.dysenBgmEnabled
            ? root.dysenBgmVolume
            : 0.0
    }

    MediaPlayer {
        id: dysenBgm

        audioOutput: dysenBgmOutput

        source: root.dysenThemeBgmSource

        loops: MediaPlayer.Infinite

        autoPlay: false

        onErrorOccurred: function(error, errorString) {
            console.log(
                "DYSEN BGM ERROR:",
                error,
                errorString
            )
        }

        onPlaybackStateChanged: {
            console.log(
                "DYSEN BGM STATE:",
                playbackState
            )
        }
    }

    function startDysenBgm() {
        if (!root.dysenBgmEnabled) {
            console.log("DYSEN BGM: disabled")
            return
        }

        dysenBgmOutput.volume =
            Math.max(
                0.0,
                Math.min(
                    1.0,
                    root.dysenBgmVolume
                )
            )

        if (
            dysenBgm.playbackState !==
            MediaPlayer.PlayingState
        ) {
            console.log(
                "DYSEN BGM: starting",
                dysenBgm.source,
                "volume=",
                dysenBgmOutput.volume
            )

            dysenBgm.play()
        }
    }

    function stopDysenBgm() {
        if (
            dysenBgm.playbackState !==
            MediaPlayer.StoppedState
        ) {
            dysenBgm.stop()
        }
    }

    function syncDysenBgm() {
        if (
            root.dysenSessionStarted &&
            root.dysenBgmEnabled
        ) {
            startDysenBgm()
        } else {
            stopDysenBgm()
        }
    }

    function restartThemeBgm() {

        stopDysenBgm()

        if (
            !root.dysenSessionStarted ||
            !root.dysenBgmEnabled
        )
            return

        Qt.callLater(function() {
            root.startDysenBgm()
        })
    }
    // =========================================================
    // GLOBAL HUD PANEL LAYER
    // Panels move here when interacted with so z-order works
    // across the complete DYSEN workspace.
    // =========================================================

    Item {
        id: panelLayer

        anchors.fill: parent

        z: 100

        property int zCounter: 1000
    }

    property real t: 0

    Timer {

        interval: 16
        running: true
        repeat: true

        onTriggered: root.t += .016
    }

    // =========================================================
    // BACKGROUND
    // =========================================================

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Canvas {

        anchors.fill: parent

        opacity: .055

        onPaint: {

            var ctx = getContext("2d")
            ctx.reset()

            ctx.strokeStyle = Qt.rgba(root.dysenGrid.r, root.dysenGrid.g, root.dysenGrid.b, 0.26)
            ctx.lineWidth = .35

            var grid = 48

            for (var x = 0; x < width; x += grid) {

                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }

            for (var y = 0; y < height; y += grid) {

                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }

        Component.onCompleted: requestPaint()
    }

    // =========================================================
    // TOP
    // =========================================================

    TopBar {

        id: topBar

        objectName: "topBar"

        x: 18
        y: 12

        width: root.width - 36
        height: 48
    }

    // =========================================================
    // MAIN GRID
    // =========================================================

    Item {

        id: workspace

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top

        anchors.leftMargin: 18
        anchors.rightMargin: 18

        anchors.topMargin: 8
        anchors.bottomMargin: 8

        // -----------------------------------------------------
        // LEFT COLUMN
        // -----------------------------------------------------

        Item {

            id: leftColumn

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: Math.max(
                260,
                parent.width * .235
            )

            HudPanel {

                panelHost: panelLayer
                id: globePanel

                objectName: "globePanel"

                x: 0
                y: 0

                width: parent.width

                // Independent workspace geometry.
                // Does not depend on any other panel.
                height: (parent.height - 32) * .39

                title: "EARTH / SATELLITE VIEW"
                subtitle: "LIVE"

                Globe {
                    anchors.fill: parent

                    explorerHost:
                        panelLayer
                }
            }

            HudPanel {

                panelHost: panelLayer
                id: metricsPanel

                objectName: "metricsPanel"

                x: 0
                y: (parent.height - 32) * .39 + 8

                width: parent.width
                height: (parent.height - 32) * .17

                title: "SYSTEM METRICS"
                subtitle: "LIVE // 1S"

                property real cpuValue: 0
                property real ramValue: 0
                property real swapValue: 0
                property real netValue: 0

                property real rxMbps: 0
                property real txMbps: 0

                Connections {

                    target: systemBackend

                    function onSystemMetricsChanged(
                        cpu,
                        ram,
                        swap
                    ) {

                        metricsPanel.cpuValue = cpu
                        metricsPanel.ramValue = ram
                        metricsPanel.swapValue = swap
                    }

                    function onNetworkChanged(
                        rxBytesSec,
                        txBytesSec,
                        rxMbit,
                        txMbit
                    ) {

                        metricsPanel.rxMbps = rxMbit
                        metricsPanel.txMbps = txMbit

                        // Normalize total traffic for the
                        // compact NET progress indicator.
                        metricsPanel.netValue =
                            Math.min(
                                (rxMbit + txMbit),
                                100
                            )
                    }
                }

                Grid {

                    anchors.fill: parent

                    columns: 2

                    rowSpacing: 12
                    columnSpacing: 12

                    Metric {

                        width: parent.width * .47

                        label: "CPU"

                        value:
                            metricsPanel.cpuValue.toFixed(1) +
                            "%"

                        progress:
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    metricsPanel.cpuValue / 100
                                )
                            )
                    }

                    Metric {

                        width: parent.width * .47

                        label: "RAM"

                        value:
                            metricsPanel.ramValue.toFixed(1) +
                            "%"

                        progress:
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    metricsPanel.ramValue / 100
                                )
                            )
                    }

                    Metric {

                        width: parent.width * .47

                        label: "SWAP"

                        value:
                            metricsPanel.swapValue.toFixed(1) +
                            "%"

                        progress:
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    metricsPanel.swapValue / 100
                                )
                            )
                    }

                    Metric {

                        width: parent.width * .47

                        label: "NET"

                        value:
                            "↓ " +
                            (
                                metricsPanel.rxMbps < 1
                                ? (
                                    metricsPanel.rxMbps *
                                    1000
                                ).toFixed(1) +
                                " Kbps"
                                :
                                metricsPanel.rxMbps.toFixed(2) +
                                " Mbps"
                            )

                        progress:
                            metricsPanel.netValue / 100
                    }
                }
            }

            HudPanel {

                panelHost: panelLayer
                id: processesPanel

                objectName: "processesPanel"

                x: 0

                // Independent position.
                y: (parent.height - 32) * .56 + 16

                width: parent.width
                height: (parent.height - 32) * .20

                title: "PROCESS MONITOR"
                subtitle: processMonitor.processCount + " PROCESSES"

                ProcessMonitor {
                    id: processMonitor

                    anchors.fill: parent

                    property int processCount: 0

                    Connections {
                        target: terminalBackend

                        function onProcessesChanged(rows, count) {
                            processMonitor.processCount = count
                        }
                    }
                }
            }

            // =================================================
            // NETWORK ACTIVITY
            // =================================================

            HudPanel {

                panelHost: panelLayer
                id: networkPanel

                objectName: "networkPanel"

                x: 0

                y: (parent.height - 32) * .76 + 24

                width: parent.width

                height: (parent.height - 32) * .10

                title: "NETWORK ACTIVITY"
                subtitle: "LIVE"

                NetworkGraph {
                    anchors.fill: parent
                }
            }

            // =================================================
            // DISK I/O
            // =================================================

            HudPanel {

                panelHost: panelLayer
                id: diskPanel

                objectName: "diskPanel"

                x: 0

                y: (parent.height - 32) * .86 + 32

                width: parent.width

                height: (parent.height - 32) * .10

                title: "DISK I/O"
                subtitle: "LIVE"

                FrequencyAnalyzer {
                    anchors.fill: parent
                }
            }
        }

        // -----------------------------------------------------
        // CENTER COLUMN
        // -----------------------------------------------------

        Item {

            id: centerColumn

            anchors.left:
                leftColumn.right

            anchors.right:
                nexusColumn.left

            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin: 8
            anchors.rightMargin: 8

            HudPanel {

                panelHost: panelLayer
                id: terminalPanel

                objectName: "terminalPanel"

                // Keep the terminal's own key receiver focused
                // while the panel enters/exits maximize mode.
                focusOnMaximize: false

                x: 0
                y: 0

                width: parent.width

                // Independent fullscreen geometry.
                height: parent.height * .50

                title: "TERMINAL / PRIMARY"
                subtitle: "PTY READY"

                Terminal {
                    id: terminalView
                    anchors.fill: parent
                }
            }

            HudPanel {

                panelHost: panelLayer
                id: signalPanel

                objectName: "signalPanel"

                x: 0

                // Independent from terminalPanel.
                y: parent.height * .50 + 8

                width:
                    (parent.width - 8) * .49

                height: parent.height * .18

                title: "SIGNAL WAVEFORM"
                subtitle: "SYNC"

                Waveform {
                    anchors.fill: parent
                }
            }

            HudPanel {

                panelHost: panelLayer
                id: frequencyPanel

                objectName: "frequencyPanel"

                x:
                    parent.width -
                    ((parent.width - 8) * .51)

                y: parent.height * .50 + 8

                width:
                    (parent.width - 8) * .51

                height: parent.height * .18

                title: "FREQUENCY ANALYZER"
                subtitle: "LIVE"

                FrequencyAnalyzer {
                    anchors.fill: parent
                }
            }

            HudPanel {

                panelHost: panelLayer
                id: keyboardPanel

                objectName: "keyboardPanel"

                // Virtual keyboard is a normal panel only.
                // It cannot be maximized/fullscreen.
                allowMaximize: false

                x: 0

                // Completely independent from waveform/analyzer.
                y: parent.height * .68 + 8

                width: parent.width

                height:
                    parent.height * .32 - 8

                title: "VIRTUAL KEYBOARD"
                subtitle: "INPUT"

                VirtualKeyboard {
                    id: virtualKeyboard
                    anchors.fill: parent
                }

                Connections {

                    target: terminalView

                    function onPhysicalKeyDown(key) {
                        virtualKeyboard.receivePhysicalKeyDown(key)
                    }

                    function onPhysicalKeyUp(key) {
                        virtualKeyboard.receivePhysicalKeyUp(key)
                    }
                }

                // =================================================
                // APPLICATION-LEVEL FUNCTION KEY BRIDGE
                // =================================================


            }
        }

        // -----------------------------------------------------
        // RIGHT NEXUS COLUMN
        // -----------------------------------------------------

        Item {

            id: nexusColumn

            anchors.right: parent.right

            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: Math.max(
                300,
                parent.width * .245
            )

            HudPanel {

                panelHost: panelLayer
                id: nexusPanel

                objectName: "nexusPanel"

                x: 0
                y: 0

                width: parent.width
                height: parent.height

                title: "NEXUS AI"
                subtitle: "COMING SOON"

                NexusPanel {
                    anchors.fill: parent
                }
            }
        }
    }

    // =========================================================
    // BOTTOM
    // =========================================================

    BottomBar {

        id: bottomBar

        objectName: "bottomBar"

        x: 18

        y: root.height - 45

        width: root.width - 36

        height: 32
    }

    // =========================================================
    // CORNER SCAN EFFECT
    // =========================================================

    Rectangle {

        width: 120
        height: 1

        x: root.width * .5 - 60
        y: 68

        color: root.dysenAccent

        opacity:
            .15 +
            Math.abs(
                Math.sin(root.t * 1.5)
            ) * .15
    }


    // =========================================================
    // DYSEN BOOT EXPERIENCE
    // =========================================================
    StartupReveal {

        id: dysenStartupReveal

        objectName: "dysenStartupReveal"

        topBarItem:
            topBar

        globePanelItem:
            globePanel

        metricsPanelItem:
            metricsPanel

        processesPanelItem:
            processesPanel

        terminalPanelItem:
            terminalPanel

        signalPanelItem:
            signalPanel

        frequencyPanelItem:
            frequencyPanel

        networkPanelItem:
            networkPanel

        diskPanelItem:
            diskPanel

        nexusPanelItem:
            nexusPanel

        keyboardPanelItem:
            keyboardPanel

        bottomBarItem:
            bottomBar
    }


    Connections {

        target: dysenBootSplash


        function onBootFinished() {
            dysenStartupReveal.start()
        }
    }


BootSplash {
        id: dysenBootSplash
        objectName: "dysenBootSplash"
        anchors.fill: parent
    }

// =========================================================
    // FIRST-RUN SESSION WELCOME
    // =========================================================

    Connections {
        target: dysenStartupReveal

        function onStartupFinished() {
            dysenBootSplash.stopLoadingAudio()
            dysenWelcomePanel.show()
        }
    }

    // =========================================================
    // =========================================================
    // SETTINGS CONTROL BRIDGE
    // =========================================================

    Connections {
        target: dysenSettings

        function onAccentChanged(value) {
            root.dysenAccent = value

            dysenSettingsBridge.set(
                "accentColor",
                value
            )

            root.restartThemeBgm()
        }

        function onBgmVolumeChanged(value) {
            root.dysenBgmVolume = Math.max(
                0.0,
                Math.min(
                    1.0,
                    Number(value)
                )
            )

            dysenSettingsBridge.set(
                "bgmVolume",
                root.dysenBgmVolume
            )

            root.syncDysenBgm()
        }

        function onBgmEnabledChanged(value) {
            root.dysenBgmEnabled = Boolean(value)

            dysenSettingsBridge.set(
                "bgmEnabled",
                root.dysenBgmEnabled
            )

            root.syncDysenBgm()
        }
    }

    Connections {
        target: dysenWelcomePanel

        function onStarted() {
            root.dysenSessionStarted = true

            console.log(
                "DYSEN SESSION STARTED"
            )

            root.startDysenBgm()
        }
    }

    // =========================================================
    // SETTINGS LAUNCHER
    // =========================================================

    Item {
        id: dysenSettingsLauncher

        width: 58
        height: 24

        // Root-level floating control: independent of NEXUS/HUD geometry.
        // Kept in the top HUD band instead of the NEXUS panel.
        x: root.width - width - 26
        y: root.height - 41

        z: 5000000

        Rectangle {
            anchors.fill: parent

            radius: 4

            color: Qt.rgba(
                root.dysenAccent.r,
                root.dysenAccent.g,
                root.dysenAccent.b,
                0.07
            )

            border.width: 1
            border.color: root.dysenAccent

            Rectangle {
                x: 1
                y: 1
                width: parent.width - 2
                height: 1

                color: root.dysenAccentSecondary
                opacity: 0.78
            }
        }

        Text {
            anchors.centerIn: parent

            text: "CFG"

            color: root.dysenAccent

            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.5
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                dysenSettings.openWith(
                    root.dysenAccent,
                    root.dysenBgmVolume,
                    root.dysenBgmEnabled
                )
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+,"

        onActivated: {
            dysenSettings.openWith(
                root.dysenAccent,
                root.dysenBgmVolume,
                root.dysenBgmEnabled
            )
        }
    }

    DysenSettings {
        id: dysenSettings
        anchors.fill: parent
    }

    Connections {
        target: bottomBar

        function onFileManagerRequested() {
            dysenFileManager.openAt("/")
        }
    }

    FileManager {
        id: dysenFileManager

        objectName: "dysenFileManager"
    }

    WelcomePanel {
        id: dysenWelcomePanel

        objectName: "dysenWelcomePanel"
        anchors.fill: parent
    }
}
