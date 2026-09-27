import QtQuick.Controls
import QtQuick
import QtQuick.Window

FocusScope {
    id: terminal

    property string buffer: ""

    property string screenText: ""
    property string latestSnapshot: ""
    property string historyText: ""
    property int screenColumns: 120
    property int screenLineCount: 32
    property int screenRows: 32
    property int cursorX: 0
    property int cursorY: 0
    property bool cursorVisible: false

    property bool autoScroll: true

    signal physicalKey(string key)
    signal physicalKeyDown(string key)
    signal physicalKeyUp(string key)

    focus: true

    Rectangle {
        anchors.fill: parent
        color: "#020607"
    }

    Flickable {
        id: scroll

        onMovementEnded: {
            terminal.updateAutoScroll()
        }


        anchors.fill: parent
        anchors.margins: 10

        clip: true

        contentWidth:
            Math.max(
                width,
                terminalText.width
            )

        contentHeight:
            Math.max(
                height,
                terminalText.height + 20
            )

        flickableDirection:
            Flickable.VerticalFlick

        boundsBehavior:
            Flickable.StopAtBounds

        interactive: true

        flickDeceleration: 1800
        maximumFlickVelocity: 1800

        // Keep a little breathing room below the last line.
        bottomMargin: 10

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded

            width: 5

            contentItem: Rectangle {
                implicitWidth: 5
                radius: 2.5

                color: Window.window ? Window.window.dysenAccent : "#00DDEB"

                opacity:
                    parent.active ||
                    parent.pressed
                    ? 0.9
                    : 0.28
            }

            background: Rectangle {
                implicitWidth: 5
                color: "#021014"
                opacity: 0.55
                radius: 2.5
            }
        }

        TerminalGrid {
            id: terminalGrid

            columns: terminal.screenColumns
            rows: terminal.screenRows

            snapshot: terminal.latestSnapshot

            cursorX: terminal.cursorX
            cursorY: terminal.cursorY
            cursorVisible: terminal.cursorVisible
        }

        TextEdit {
            id: terminalText

            width: scroll.width

            text: terminal.screenText

            height:
                Math.max(
                    1,
                    lineCount * font.pixelSize * 1.35
                )

            color: Window.window ? Window.window.dysenAccent : "#BFEAF0"

            font.family: "monospace"
            font.pixelSize: 11

            wrapMode: TextEdit.NoWrap

            selectByMouse: true
            persistentSelection: true

            readOnly: true

            activeFocusOnPress: false

            selectByKeyboard: true

            textFormat: TextEdit.PlainText

            selectionColor: (Window.window ? Window.window.dysenAccentDim : "#004F5A")
            selectedTextColor: "#FFFFFF"

            cursorVisible: false

            // Hidden visual layer:
            // TextEdit remains available for selection/copy,
            // while TerminalGrid is the visible renderer.
            opacity: 0

            // Keep the terminal as an output surface.
            // Actual command input continues through inputReceiver.
        }
    }

    /*
        IMPORTANT:

        This Item receives ALL physical keyboard events.
        There is NO TextEdit here.

        Therefore Qt cannot insert characters by itself.
        Every character goes exactly once to the PTY.
    */

    Item {
        id: inputReceiver

        anchors.fill: parent

        focus: true

        // Physical keyboard must stay attached to the terminal
        // even after PTY commands cause the terminal output to refresh.
        onActiveFocusChanged: {
            if (!activeFocus) {
                Qt.callLater(function() {
                    if (
                        terminal.visible &&
                        !inputReceiver.activeFocus
                    ) {
                        inputReceiver.forceActiveFocus()
                    }
                })
            }
        }

        Keys.onReleased: function(event) {

            var physical =
                terminal.normalizePhysicalKey(event)

            if (physical.length > 0) {
                terminal.physicalKeyUp(physical)
            }
        }

        Keys.onPressed: function(event) {

            event.accepted = true

            var physical =
                terminal.normalizePhysicalKey(event)

            if (physical.length > 0) {

                // Immediate visual feedback for every physical
                // key event. Auto-repeat is handled separately
                // by the terminal input path.
                terminal.physicalKeyDown(
                    physical
                )

                if (!event.isAutoRepeat) {
                    if (
                        typeof uiEffects !== "undefined"
                    ) {
                        uiEffects.play(
                            physical === "SPACE"
                            ? "space"
                            : (
                                physical === "ENTER"
                                ? "enter"
                                : (
                                    physical === "BACKSPACE"
                                    ? "backspace"
                                    : (
                                        physical === "ESC"
                                        ? "special"
                                        : "key"
                                    )
                                )
                            )
                        )
                    }
                }
            }

            var key = event.key
            var modifiers = event.modifiers

            // =============================================
            // CTRL+C
            // =============================================

            if (
                (modifiers & Qt.ControlModifier) &&
                key === Qt.Key_C
            ) {
                var selected = terminalText.selectedText

                if (
                    selected &&
                    selected.length > 0
                ) {
                    clipboardBridge.setText(selected)

                    Qt.callLater(function() {
                        inputReceiver.forceActiveFocus()
                    })

                    return
                }

                terminalBackend.write("\x03")
                terminal.physicalKey("C")
                return
            }

            // =============================================
            // CTRL+D
            // =============================================

            if (
                (modifiers & Qt.ControlModifier) &&
                key === Qt.Key_D
            ) {
                terminalBackend.write("\x04")
                terminal.physicalKey("D")
                return
            }

            // =============================================
            // CTRL+L
            // =============================================

            if (
                (modifiers & Qt.ControlModifier) &&
                key === Qt.Key_L
            ) {
                terminalBackend.write("\x0c")
                terminal.physicalKey("L")
                return
            }

            // =============================================
            // ENTER
            // =============================================

            if (
                key === Qt.Key_Return ||
                key === Qt.Key_Enter
            ) {
                terminalBackend.write("\r")
                terminal.physicalKey("ENTER")
                return
            }

            // =============================================
            // BACKSPACE
            // =============================================

            if (key === Qt.Key_Backspace) {
                terminalBackend.write("\x7f")
                terminal.physicalKey("BACK")
                return
            }

            // =============================================
            // TAB
            // =============================================

            if (key === Qt.Key_Tab) {
                terminalBackend.write("\t")
                terminal.physicalKey("TAB")
                return
            }

            // =============================================
            // ESC
            // =============================================

            if (key === Qt.Key_Escape) {
                terminalBackend.write("\x1b")
                terminal.physicalKey("ESC")
                return
            }

            // =============================================
            // ARROWS
            // =============================================

            if (key === Qt.Key_Up) {
                terminalBackend.write("\x1b[A")
                terminal.physicalKey("UP")
                return
            }

            if (key === Qt.Key_Down) {
                terminalBackend.write("\x1b[B")
                terminal.physicalKey("DOWN")
                return
            }

            if (key === Qt.Key_Left) {
                terminalBackend.write("\x1b[D")
                terminal.physicalKey("LEFT")
                return
            }

            if (key === Qt.Key_Right) {
                terminalBackend.write("\x1b[C")
                terminal.physicalKey("RIGHT")
                return
            }

            // =============================================
            // TERMINAL SCROLLBACK
            // =============================================

            if (
                key === Qt.Key_PageUp &&
                (modifiers & Qt.ShiftModifier)
            ) {
                terminal.scrollPageUp()
                return
            }

            if (
                key === Qt.Key_PageDown &&
                (modifiers & Qt.ShiftModifier)
            ) {
                terminal.scrollPageDown()
                return
            }

            // =============================================
            // NORMAL TEXT
            // =============================================

            if (
                event.text &&
                event.text.length > 0
            ) {
                terminalBackend.write(event.text)

                terminal.physicalKey(
                    event.text
                )

                return
            }

            event.accepted = false
        }
    }

    // =====================================================
    // PHYSICAL KEY NORMALIZER
    //
    // This is visual-only metadata.
    // It does NOT alter the PTY input stream.
    // =====================================================

    // =====================================================
    // CLIPBOARD SHORTCUTS
    // =====================================================

    Shortcut {
        sequence: "Ctrl+Shift+C"
        context: Qt.WindowShortcut

        onActivated: {
            var selected =
                terminalText.selectedText

            if (
                selected &&
                selected.length > 0
            ) {
                clipboardBridge.setText(
                    selected
                )

                Qt.callLater(function() {
                    inputReceiver.forceActiveFocus()
                })

                terminal.scrollToBottom()
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Shift+V"
        context: Qt.WindowShortcut

        onActivated: {
            var pasted =
                clipboardBridge.getText()

            if (
                pasted &&
                pasted.length > 0
            ) {
                terminalBackend.write(
                    pasted
                )
            }

            Qt.callLater(function() {
                inputReceiver.forceActiveFocus()
            })
        }
    }

    Shortcut {
        sequence: "Ctrl+V"
        context: Qt.WindowShortcut

        onActivated: {
            var pasted =
                clipboardBridge.getText()

            if (
                pasted &&
                pasted.length > 0
            ) {
                terminalBackend.write(
                    pasted
                )
            }

            inputReceiver.forceActiveFocus()
        }
    }

    // =====================================================
    // TERMINAL SCROLL STATE
    // =====================================================

    function terminalAtBottom() {
        return (
            scroll.contentHeight <= scroll.height ||
            scroll.contentY >=
            scroll.contentHeight -
            scroll.height -
            24
        )
    }

    function updateAutoScroll() {
        autoScroll = terminalAtBottom()
    }

    function scrollToBottom() {
        scroll.cancelFlick()

        scroll.contentY =
            Math.max(
                0,
                scroll.contentHeight -
                scroll.height
            )

        autoScroll = true
    }


    function scrollPageUp() {
        scroll.contentY =
            Math.max(
                0,
                scroll.contentY -
                scroll.height * 0.85
            )
    }

    function scrollPageDown() {
        scroll.contentY =
            Math.min(
                Math.max(
                    0,
                    scroll.contentHeight -
                    scroll.height
                ),
                scroll.contentY +
                scroll.height * 0.85
            )
    }

    function normalizePhysicalKey(event) {

        var key = event.key

        // Letters
        if (
            key >= Qt.Key_A &&
            key <= Qt.Key_Z
        ) {
            return String.fromCharCode(
                65 + (key - Qt.Key_A)
            )
        }

        // Number row
        if (
            key >= Qt.Key_0 &&
            key <= Qt.Key_9
        ) {
            return String.fromCharCode(
                48 + (key - Qt.Key_0)
            )
        }

        // Function keys
        if (key >= Qt.Key_F1 && key <= Qt.Key_F12) {
            return "F" + (key - Qt.Key_F1 + 1)
        }

        var map = {}

        map[Qt.Key_Escape] = "ESC"
        map[Qt.Key_Tab] = "TAB"
        map[Qt.Key_Backspace] = "BACKSPACE"
        map[Qt.Key_Return] = "ENTER"
        map[Qt.Key_Enter] = "ENTER"
        map[Qt.Key_Space] = "SPACE"

        map[Qt.Key_Shift] = "SHIFT"
        map[Qt.Key_Control] = "CTRL"
        map[Qt.Key_Alt] = "ALT"
        map[Qt.Key_Meta] = "WIN"
        map[Qt.Key_CapsLock] = "CAPS"

        map[Qt.Key_Left] = "LEFT"
        map[Qt.Key_Right] = "RIGHT"
        map[Qt.Key_Up] = "UP"
        map[Qt.Key_Down] = "DOWN"

        map[Qt.Key_Insert] = "INSERT"
        map[Qt.Key_Delete] = "DELETE"
        map[Qt.Key_Home] = "HOME"
        map[Qt.Key_End] = "END"
        map[Qt.Key_PageUp] = "PGUP"
        map[Qt.Key_PageDown] = "PGDN"

        map[Qt.Key_Print] = "PRINT"
        map[Qt.Key_ScrollLock] = "SCROLL"
        map[Qt.Key_Pause] = "PAUSE"
        map[Qt.Key_Menu] = "MENU"
        map[Qt.Key_NumLock] = "NUM"

        return map[key] !== undefined
            ? map[key]
            : ""
    }

    /*
        PTY OUTPUT
    */

    Connections {
        target: terminalBackend

        function onOutputReceived(data) {

            terminal.buffer += data

            if (
                terminal.buffer.length >
                250000
            ) {
                terminal.buffer =
                    terminal.buffer.slice(
                        -180000
                    )
            }
        }

        function onScreenChanged(snapshot, columns, rows) {

            terminal.screenColumns = columns
            terminal.screenRows = rows
            terminal.latestSnapshot = snapshot
            terminal.latestSnapshot = snapshot

            var wasAtBottom =
                terminal.terminalAtBottom()

            terminal.screenText =
                terminalBackend.get_screen_text()

            terminal.screenLineCount =
                terminal.screenText.split("\n").length

            if (wasAtBottom) {
                terminal.autoScroll = true

                Qt.callLater(
                    terminal.scrollToBottom
                )
            } else {
                terminal.autoScroll = false
            }
        }


        function onCursorChanged(x, y, visible) {
            terminal.cursorX = x
            terminal.cursorY = y
            terminal.cursorVisible = visible
        }
    }

    /*
        Always return keyboard focus to the receiver.
    */

    function restoreFocus() {
        inputReceiver.forceActiveFocus()
    }

    Component.onCompleted: {
        inputReceiver.forceActiveFocus()
    }
}
