import QtQuick
import QtQuick.Window

Rectangle {
    id: panel

    property string title: "MODULE"
    property string subtitle: "ONLINE"

    default property alias content: contentArea.data

    property bool moving: false
    property bool resizing: false

    property color themeAccent:
        Window.window
        ? Window.window.dysenAccent
        : "#00F6FF"

    property color themeAccentBright:
        Window.window
        ? Window.window.dysenAccentBright
        : Qt.lighter("#00F6FF", 1.15)

    property color themeAccentSecondary:
        Window.window
        ? Window.window.dysenAccentSecondary
        : "#7CF2FF"

    property color themeAccentDim:
        Window.window
        ? Window.window.dysenAccentDim
        : "#007483"

    property color themePanelFill:
        Window.window
        ? Window.window.dysenPanelFill
        : "#000000"

    property color themeHeaderFill:
        Window.window
        ? Window.window.dysenHeaderFill
        : "#020A0C"

    property color themeMuted:
        Window.window
        ? Window.window.dysenMuted
        : "#5D7880"

    property string themeMotif:
        Window.window
        ? Window.window.dysenThemeMotif
        : "CYBER // SCAN"


    // =========================================================
    // DYSEN_THEME_SHELL_V11
    // Shell styling only — content geometry intentionally unchanged.
    // =========================================================

    property real themeRadius:
        Window.window
        ? Window.window.dysenThemeSpec.radius
        : 3

    property real themeBorderWidth:
        Window.window
        ? Window.window.dysenThemeSpec.borderWidth
        : 1

    property real themeGlowOpacity:
        Window.window
        ? Window.window.dysenThemeSpec.glowOpacity
        : 0.035

    property real themeTopAccentLength:
        Window.window
        ? Window.window.dysenThemeSpec.topAccentLength
        : 130

    property real themeBottomAccentLength:
        Window.window
        ? Window.window.dysenThemeSpec.bottomAccentLength
        : 70

    property real themePanelOpacity:
        Window.window
        ? Window.window.dysenPanelOpacity
        : 0.96

    // Global layer supplied by Main.qml.
    // This lets an interacted panel escape its original
    // column and participate in one global z-order.
    property Item panelHost: null

    property bool maximized: false
    property bool allowMaximize: true
    property bool focusOnMaximize: true

    property real restoreX: 0
    property real restoreY: 0
    property real restoreWidth: 0
    property real restoreHeight: 0

    property real geometryTargetX: 0
    property real geometryTargetY: 0
    property real geometryTargetWidth: 0
    property real geometryTargetHeight: 0
    property bool soundEnabled: true
    property real startupRevealProgress: 1.0

    signal closed()

    color: panel.themePanelFill

    border.width: moving || resizing ? 2 : panel.themeBorderWidth
    border.color: moving || resizing ? panel.themeAccent : panel.themeAccentDim
    radius: panel.themeRadius

    // =========================================================
    // Z-ORDER
    // =========================================================

    function bringToFront() {
        if (!panelHost)
            return

        var host = panelHost

        var scenePos = panel.mapToItem(
            host,
            0,
            0
        )

        var savedWidth = panel.width
        var savedHeight = panel.height

        if (panel.parent !== host) {

            // NEXUS and any future anchored panel must not
            // inherit the new parent's geometry.
            panel.anchors.fill = undefined

            panel.parent = host

            panel.x = scenePos.x
            panel.y = scenePos.y

            panel.width = savedWidth
            panel.height = savedHeight
        }

        host.zCounter += 1
        panel.z = host.zCounter
    }

    function toggleMaximize() {
        if (!panelHost || !panel.allowMaximize)
            return

        bringToFront()

        if (!panel.maximized) {

            restoreX = panel.x
            restoreY = panel.y
            restoreWidth = panel.width
            restoreHeight = panel.height

            geometryTargetX = 0
            geometryTargetY = 0
            geometryTargetWidth = panelHost.width
            geometryTargetHeight = panelHost.height

            maximized = true

            if (panel.focusOnMaximize)
                panel.forceActiveFocus()

        } else {

            geometryTargetX = Math.max(
                0,
                Math.min(
                    restoreX,
                    Math.max(
                        0,
                        panelHost.width - restoreWidth
                    )
                )
            )

            geometryTargetY = Math.max(
                0,
                Math.min(
                    restoreY,
                    Math.max(
                        0,
                        panelHost.height - restoreHeight
                    )
                )
            )

            geometryTargetWidth = Math.min(
                restoreWidth,
                panelHost.width
            )

            geometryTargetHeight = Math.min(
                restoreHeight,
                panelHost.height
            )

            maximized = false
        }

        geometryAnimation.restart()
    }

    ParallelAnimation {
        id: geometryAnimation

        NumberAnimation {
            target: panel
            property: "x"

            to: panel.geometryTargetX

            duration: 260

            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "y"

            to: panel.geometryTargetY

            duration: 260

            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "width"

            to: panel.geometryTargetWidth

            duration: 260

            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "height"

            to: panel.geometryTargetHeight

            duration: 260

            easing.type: Easing.OutCubic
        }
    }

    // =========================================================
    // MAXIMIZED INPUT SHIELD
    //
    // A visual item alone does not consume mouse events.
    // When maximized, this shield captures unused mouse area so
    // underlying DYSEN panels cannot receive clicks or drags.
    // =========================================================

    MouseArea {
        id: maximizedInputShield

        anchors.fill: parent

        z: 0

        enabled: panel.maximized

        acceptedButtons: Qt.AllButtons

        hoverEnabled: true

        onPressed: {
            mouse.accepted = true

            if (panel.focusOnMaximize)
                panel.forceActiveFocus()
        }

        onReleased: {
            mouse.accepted = true
        }

        onClicked: {
            mouse.accepted = true
        }

        onDoubleClicked: {
            mouse.accepted = true
        }
    }

    // =========================================================
    // OPEN
    // =========================================================

    opacity: 0
    scale: 0.96


    Component.onCompleted: {
        openAnimation.start()
    }

    ParallelAnimation {
        id: openAnimation

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
            from: 0.96
            to: 1
            duration: 380
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "y"
            from: panel.y - 12
            duration: 380
            easing.type: Easing.OutCubic
        }
    }

    // =========================================================
    // OUTER GLOW
    // =========================================================

    Rectangle {
        anchors.fill: parent
        anchors.margins: -3

        color: "transparent"

        border.width: 1
        border.color: panel.themeAccent

        opacity: panel.moving || panel.resizing ? 0.30 : panel.themeGlowOpacity

        radius: 5

        z: -1
    }

    // =========================================================
    // TOP ACCENT
    // =========================================================

    Rectangle {
        x: 0
        y: 0

        width: Math.min(
            panel.themeTopAccentLength,
            panel.width * 0.34
        )

        height: 2

        color: panel.themeAccent
    }

    // =========================================================
    // BOTTOM ACCENT
    // =========================================================

    Rectangle {
        x: panel.width -
          Math.min(panel.themeBottomAccentLength, panel.width * 0.22)

        y: panel.height - 2

        width: Math.min(
            panel.themeBottomAccentLength,
            panel.width * 0.22
        )

        height: 2

        color: panel.themeAccent
    }

    // =========================================================
    // HEADER
    // =========================================================

    Rectangle {
        id: header

        x: 0
        y: 0

        z: 10

        width: parent.width
        height: 40

        opacity:
            0.72 +
            (panel.startupRevealProgress * 0.28)

        color: panel.moving ? panel.themeHeaderFill : panel.themeHeaderFill

        Rectangle {
            anchors.bottom: parent.bottom

            width: parent.width
            height: 1

            color: panel.themeAccentDim
        }

        Text {
            x: 14

            anchors.verticalCenter: parent.verticalCenter

            text: panel.title

            color:
                panel.moving ? "#FFFFFF" : panel.themeAccentSecondary

            font.family: "monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.2
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14

            anchors.verticalCenter: parent.verticalCenter

            text: panel.subtitle

            color: panel.themeAccent

            font.family: "monospace"
            font.pixelSize: 8
            font.bold: true
        }

        // Header interaction area ONLY.
        // Content remains completely independent.

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton

            cursorShape:
                panel.moving
                ? Qt.ClosedHandCursor
                : Qt.OpenHandCursor

            property real pressX: 0
            property real pressY: 0

            onPressed: function(mouse) {

                panel.bringToFront()

                if (
                    panel.soundEnabled &&
                    typeof uiEffects !== "undefined" &&
                    uiEffects
                ) {
                    uiEffects.play("panel_focus")
                }

                if (panel.maximized) {
                    panel.moving = false
                    return
                }

                panel.moving = true

                pressX = mouse.x
                pressY = mouse.y
            }

            onPositionChanged: function(mouse) {

                if (
                    !pressed ||
                    !panel.panelHost ||
                    panel.maximized
                )
                    return

                var dx = mouse.x - pressX
                var dy = mouse.y - pressY

                var host = panel.panelHost

                var nextX = panel.x + dx
                var nextY = panel.y + dy

                // Keep the panel reachable inside the workspace.
                panel.x = Math.max(
                    0,
                    Math.min(
                        nextX,
                        Math.max(
                            0,
                            host.width - panel.width
                        )
                    )
                )

                panel.y = Math.max(
                    0,
                    Math.min(
                        nextY,
                        Math.max(
                            0,
                            host.height - panel.height
                        )
                    )
                )
            }

            onReleased: {
                panel.moving = false
            }

            onDoubleClicked: {
                if (panel.allowMaximize)
                    panel.toggleMaximize()
            }

            onCanceled: {
                panel.moving = false
            }
        }
    }

    // =========================================================
    // THEME MOTIF LAYER
    // =========================================================

    Item {
        id: motifLayer
        anchors.fill: parent
        z: 3
        opacity: 0.48
        visible: !panel.maximized

        // Pink: subtle petal-tech nodes.
        Repeater {
            model: 4
            visible: panel.themeMotif === "FLORAL // TECH"
            Rectangle {
                width: 7
                height: 7
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: panel.themeAccentSecondary
                x: index < 2 ? 12 : panel.width - 19
                y: index % 2 === 0 ? 55 : panel.height - 63
            }
        }

        // Violet: two restrained aurora rails.
        Rectangle {
            visible: panel.themeMotif === "AURORA // NEBULA"
            x: 18
            y: panel.height * 0.56
            width: Math.max(0, panel.width * 0.34)
            height: 1
            color: panel.themeAccentSecondary
        }

        Rectangle {
            visible: panel.themeMotif === "AURORA // NEBULA"
            x: panel.width * 0.60
            y: panel.height * 0.73
            width: Math.max(0, panel.width * 0.24)
            height: 1
            color: panel.themeAccent
        }

        // Amber / red: tactical corner ticks.
        Rectangle {
            visible: panel.themeMotif === "COCKPIT // INDUSTRIAL" || panel.themeMotif === "WARNING // HIGH ALERT"
            x: panel.width - 42
            y: 48
            width: 24
            height: 1
            color: panel.themeAccentSecondary
        }

        Rectangle {
            visible: panel.themeMotif === "COCKPIT // INDUSTRIAL" || panel.themeMotif === "WARNING // HIGH ALERT"
            x: panel.width - 18
            y: 48
            width: 1
            height: 18
            color: panel.themeAccent
        }

        // Blue / white: architectural precision rails.
        Rectangle {
            visible: panel.themeMotif === "ICE // DEEP TECH" || panel.themeMotif === "PRECISION // GLASS"
            x: 14
            y: panel.height - 18
            width: 34
            height: 1
            color: panel.themeAccentSecondary
        }

        Rectangle {
            visible: panel.themeMotif === "ICE // DEEP TECH" || panel.themeMotif === "PRECISION // GLASS"
            x: panel.width - 48
            y: panel.height - 18
            width: 34
            height: 1
            color: panel.themeAccentSecondary
        }
    }

    // =========================================================
    // CONTENT
    // =========================================================

    // =========================================================
    // CONTENT
    // =========================================================

    Item {
        id: contentArea

        z: 5

        x: 15
        y:
            46 +
            ((1.0 - panel.startupRevealProgress) * 8.0)

        opacity:
            panel.startupRevealProgress

        scale:
            0.985 +
            (panel.startupRevealProgress * 0.015)

        width: Math.max(
            1,
            panel.width - 30
        )

        height: Math.max(
            1,
            panel.height - 55
        )

        clip: true
    }

    // =========================================================
    // RESIZE HANDLE
    // =========================================================

    Rectangle {
        id: resizeHandle

        width: 22
        height: 22

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: "transparent"

        z: 100

        Rectangle {
            width: 11
            height: 1

            anchors.centerIn: parent

            rotation: -45

            color: panel.themeAccentDim
        }

        Rectangle {
            width: 7
            height: 1

            anchors.centerIn: parent

            anchors.horizontalCenterOffset: 3
            anchors.verticalCenterOffset: 3

            rotation: -45

            color: panel.themeMuted
        }

        MouseArea {
            id: resizeMouse

            anchors.fill: parent

            enabled: !panel.maximized

            acceptedButtons: Qt.LeftButton

            cursorShape: Qt.SizeFDiagCursor

            property real startX
            property real startY

            property real startWidth
            property real startHeight

            onPressed: function(mouse) {

                panel.bringToFront()

                if (
                    panel.soundEnabled &&
                    typeof uiEffects !== "undefined" &&
                    uiEffects
                ) {
                    uiEffects.play("panel_resize")
                }

                panel.resizing = true

                startX = mouse.x
                startY = mouse.y

                startWidth = panel.width
                startHeight = panel.height
            }

            onPositionChanged: function(mouse) {

                if (!pressed || !panel.panelHost)
                    return

                var dx = mouse.x - startX
                var dy = mouse.y - startY

                var host = panel.panelHost

                var minWidth = 220
                var minHeight = 130

                var maxWidth = Math.max(
                    minWidth,
                    host.width - panel.x
                )

                var maxHeight = Math.max(
                    minHeight,
                    host.height - panel.y
                )

                panel.width = Math.max(
                    minWidth,
                    Math.min(
                        maxWidth,
                        startWidth + dx
                    )
                )

                panel.height = Math.max(
                    minHeight,
                    Math.min(
                        maxHeight,
                        startHeight + dy
                    )
                )
            }

            onReleased: {
                panel.resizing = false
            }

            onCanceled: {
                panel.resizing = false
            }
        }
    }
}
