import QtQuick
import QtQuick.Window

Rectangle {
    id: key

    property string text: ""
    property string keyValue: text

    // Physical keyboard state.
    property bool active: false

    // Owner used for direct physical-key synchronization.
    property var keyboardOwner: null

    // Physical and virtual presses share one visual state.
    property bool pressedVisual:
        active || mouseArea.pressed

    property real keyWidth: 40
    property real keyHeight: 30

    signal keyPressed(string value)

    Component.onCompleted: {
        if (keyboardOwner) {
            keyboardOwner.registerPhysicalKey(
                keyValue,
                key
            )
        }
    }

    Component.onDestruction: {
        if (keyboardOwner) {
            keyboardOwner.unregisterPhysicalKey(
                keyValue,
                key
            )
        }
    }

    width: key.keyWidth
    height: key.keyHeight

    radius: 3

    // =========================================================
    // VISUAL STATE
    //
    // Physical synchronization intentionally has NO animated
    // color/opacity transition. The state changes immediately
    // on the same event that arrives from the keyboard bridge.
    // =========================================================

    color:
        key.pressedVisual
        ? "#003F48"
        : mouseArea.containsMouse
          ? "#001D23"
          : "#020607"

    border.width:
        key.pressedVisual
        ? 2
        : 1

    border.color:
        key.pressedVisual
        ? "#00F6FF"
        : mouseArea.containsMouse
          ? "#00B8CA"
          : "#00515C"

    scale:
        key.pressedVisual
        ? 0.975
        : 1.0

    // =========================================================
    // ACTIVE GLOW
    // =========================================================

    Rectangle {
        anchors.fill: parent
        anchors.margins: -2

        color: "transparent"

        border.width: 1
        border.color: Window.window ? Window.window.dysenAccent : "#00F6FF"

        radius: 4

        opacity:
            key.pressedVisual
            ? 0.72
            : 0
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1

        color: Window.window ? Window.window.dysenAccent : "#00F6FF"

        opacity:
            key.pressedVisual
            ? 0.055
            : 0

        radius: 3
    }

    // =========================================================
    // LABEL
    // =========================================================

    Text {
        anchors.centerIn: parent

        text: key.text

        color:
            key.pressedVisual
            ? "#FFFFFF"
            : mouseArea.containsMouse
              ? "#73F3FF"
              : "#8CC9D1"

        font.family: "monospace"

        font.pixelSize:
            key.text.length > 7
            ? 6
            : key.text.length > 5
              ? 7
              : key.text.length > 3
                ? 8
                : 9

        font.bold:
            key.active ||
            mouseArea.pressed
    }

    // =========================================================
    // DYSEN DETAIL
    // =========================================================

    Rectangle {
        width: 3
        height: 1

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 3
        anchors.bottomMargin: 3

        color: Window.window ? Window.window.dysenAccent : "#00F6FF"

        opacity:
            key.active
            ? 1
            : 0.18
    }

    // =========================================================
    // VIRTUAL KEY INPUT
    // =========================================================

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onPressed: {

            if (
                typeof uiEffects !== "undefined"
            ) {
                uiEffects.play(
                    key.keyValue === "SPACE"
                    ? "space"
                    : (
                        key.keyValue === "ENTER"
                        ? "enter"
                        : (
                            key.keyValue === "BACKSPACE"
                            ? "backspace"
                            : (
                                key.keyValue === "ESC"
                                ? "special"
                                : "key"
                            )
                        )
                    )
                )
            }
        }

        onReleased: {
        }

        onCanceled: {
        }

        onClicked: {
            key.keyPressed(
                key.keyValue
            )
        }
    }
}
