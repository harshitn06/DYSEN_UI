import QtQuick

Item {
    id: keyboard

    property real gap: 3

    property bool shift: false
    property bool caps: false
    property bool ctrl: false
    property bool alt: false

    signal keyActivity(string key)

    // Physical keyboard event bus.
    signal physicalKeyDown(string key)
    signal physicalKeyUp(string key)

    // =========================================================
    // PHYSICAL KEY STATE
    //
    // Direct key registration.
    // No full physicalKeys object is rebuilt on every event.
    // =========================================================

    property var physicalKeyRegistry: ({})

    function registerPhysicalKey(keyName, keyObject) {

        if (
            !keyName ||
            !keyObject
        )
            return

        if (
            !physicalKeyRegistry[keyName]
        ) {
            physicalKeyRegistry[keyName] = []
        }

        var list =
            physicalKeyRegistry[keyName]

        if (
            list.indexOf(keyObject) === -1
        ) {
            list.push(keyObject)
        }
    }

    function unregisterPhysicalKey(
        keyName,
        keyObject
    ) {

        var list =
            physicalKeyRegistry[keyName]

        if (!list)
            return

        var index =
            list.indexOf(keyObject)

        if (index !== -1)
            list.splice(index, 1)

        if (list.length === 0)
            delete physicalKeyRegistry[keyName]
    }

    function setPhysicalKeyState(
        keyName,
        state
    ) {

        var list =
            physicalKeyRegistry[keyName]

        if (!list)
            return

        for (
            var i = 0;
            i < list.length;
            ++i
        ) {
            list[i].active = state
        }
    }

    function receivePhysicalKeyDown(keyName) {

        if (!keyName)
            return

        setPhysicalKeyState(
            keyName,
            true
        )
    }

    function receivePhysicalKeyUp(keyName) {

        if (!keyName)
            return

        setPhysicalKeyState(
            keyName,
            false
        )
    }

    function clearPhysicalKeys() {

        for (
            var keyName in physicalKeyRegistry
        ) {
            setPhysicalKeyState(
                keyName,
                false
            )
        }
    }

    // =========================================================
    // DIMENSIONS

    // =========================================================

    property real rowHeight:
        Math.max(
            18,
            Math.min(
                29,
                (height - gap * 6) / 6
            )
        )

    property real mainWidth: width * 0.655
    property real navWidth: width * 0.145
    property real numWidth: width * 0.185

    // =========================================================
    // SEND TO TERMINAL
    // =========================================================

    function send(value) {

        // -----------------------------
        // MODIFIERS
        // -----------------------------

        if (value === "SHIFT") {
            shift = !shift
            keyActivity("SHIFT")
            return
        }

        if (value === "CAPS") {
            caps = !caps
            keyActivity("CAPS")
            return
        }

        if (value === "CTRL") {
            ctrl = !ctrl
            keyActivity("CTRL")
            return
        }

        if (value === "ALT") {
            alt = !alt
            keyActivity("ALT")
            return
        }

        // -----------------------------
        // BASIC CONTROL
        // -----------------------------

        if (value === "ESC") {
            terminalBackend.write("\x1b")
            keyActivity("ESC")
            return
        }

        if (value === "TAB") {
            terminalBackend.write("\t")
            keyActivity("TAB")
            return
        }

        if (value === "ENTER") {
            terminalBackend.write("\r")
            keyActivity("ENTER")
            return
        }

        if (value === "BACKSPACE") {
            terminalBackend.write("\x7f")
            keyActivity("BACKSPACE")
            return
        }

        if (value === "SPACE") {
            terminalBackend.write(" ")
            keyActivity("SPACE")
            return
        }

        // -----------------------------
        // ARROWS
        // -----------------------------

        if (value === "UP") {
            terminalBackend.write("\x1b[A")
            keyActivity("UP")
            return
        }

        if (value === "DOWN") {
            terminalBackend.write("\x1b[B")
            keyActivity("DOWN")
            return
        }

        if (value === "LEFT") {
            terminalBackend.write("\x1b[D")
            keyActivity("LEFT")
            return
        }

        if (value === "RIGHT") {
            terminalBackend.write("\x1b[C")
            keyActivity("RIGHT")
            return
        }

        // -----------------------------
        // NAVIGATION
        // -----------------------------

        if (value === "INSERT") {
            terminalBackend.write("\x1b[2~")
            keyActivity("INSERT")
            return
        }

        if (value === "DELETE") {
            terminalBackend.write("\x1b[3~")
            keyActivity("DELETE")
            return
        }

        if (value === "HOME") {
            terminalBackend.write("\x1b[H")
            keyActivity("HOME")
            return
        }

        if (value === "END") {
            terminalBackend.write("\x1b[F")
            keyActivity("END")
            return
        }

        if (value === "PGUP") {
            terminalBackend.write("\x1b[5~")
            keyActivity("PGUP")
            return
        }

        if (value === "PGDN") {
            terminalBackend.write("\x1b[6~")
            keyActivity("PGDN")
            return
        }

        // -----------------------------
        // FUNCTION KEYS
        // -----------------------------

        var fn = {
            "F1":  "\x1bOP",
            "F2":  "\x1bOQ",
            "F3":  "\x1bOR",
            "F4":  "\x1bOS",
            "F5":  "\x1b[15~",
            "F6":  "\x1b[17~",
            "F7":  "\x1b[18~",
            "F8":  "\x1b[19~",
            "F9":  "\x1b[20~",
            "F10": "\x1b[21~",
            "F11": "\x1b[23~",
            "F12": "\x1b[24~"
        }

        if (fn[value] !== undefined) {
            terminalBackend.write(fn[value])
            keyActivity(value)
            return
        }

        // -----------------------------
        // NUMPAD
        // -----------------------------

        if (value === "NUMENTER") {
            terminalBackend.write("\r")
            keyActivity("NUMENTER")
            return
        }

        // -----------------------------
        // NORMAL TEXT
        // -----------------------------

        var output = value

        if (output.length === 1) {

            var upper = output.toUpperCase()
            var lower = output.toLowerCase()

            output =
                (caps !== shift)
                ? upper
                : lower

            if (ctrl) {

                var code =
                    upper.charCodeAt(0)

                if (code >= 64 && code <= 95) {

                    terminalBackend.write(
                        String.fromCharCode(
                            code - 64
                        )
                    )

                    keyActivity(value)

                    ctrl = false

                    return
                }
            }
        }

        terminalBackend.write(output)

        keyActivity(value)

        if (shift)
            shift = false

        if (alt)
            alt = false
    }

    // =========================================================
    // KEY COMPONENT
    // =========================================================

    component K: Key {

        keyHeight: keyboard.rowHeight

        // Register this actual Key object with the keyboard
        // so physical events update only the affected key(s).
        keyboardOwner: keyboard

        onKeyPressed:
            function(value) {
                keyboard.send(value)
            }
    }



    // =========================================================
    // FUNCTION ROW
    // =========================================================

    Row {
        id: functionRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: keyboard.rowHeight

        spacing: keyboard.gap

        K {
            keyWidth: keyboard.width * .048
            text: "ESC"
            keyValue: "ESC"
        }

        Item {
            width: keyboard.width * .018
            height: keyboard.rowHeight
        }

        Repeater {
            model: [
                "F1","F2","F3","F4",
                "F5","F6","F7","F8",
                "F9","F10","F11","F12"
            ]

            delegate: K {
                keyWidth: keyboard.width * .043
                text: modelData
                keyValue: modelData
            }
        }

        Item {
            width: keyboard.width * .010
            height: keyboard.rowHeight
        }

        K {
            keyWidth: keyboard.width * .047
            text: "PRTSC"
            keyValue: "PRINT"
        }

        K {
            keyWidth: keyboard.width * .047
            text: "SCRLK"
            keyValue: "SCROLL"
        }

        K {
            keyWidth: keyboard.width * .047
            text: "PAUSE"
            keyValue: "PAUSE"
        }
    }

    // =========================================================
    // MAIN 5 ROWS
    // =========================================================

    Column {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: functionRow.bottom

        anchors.topMargin: keyboard.gap

        spacing: keyboard.gap

        // =====================================================
        // NUMBER / NAV / NUMPAD
        // =====================================================

        Row {
            width: parent.width
            height: keyboard.rowHeight
            spacing: keyboard.gap

            // ---------------- MAIN ----------------

            Item {
                width: keyboard.mainWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .061; text: "`"; keyValue: "`" }

                    K { keyWidth: parent.width * .061; text: "1"; keyValue: "1" }
                    K { keyWidth: parent.width * .061; text: "2"; keyValue: "2" }
                    K { keyWidth: parent.width * .061; text: "3"; keyValue: "3" }
                    K { keyWidth: parent.width * .061; text: "4"; keyValue: "4" }
                    K { keyWidth: parent.width * .061; text: "5"; keyValue: "5" }
                    K { keyWidth: parent.width * .061; text: "6"; keyValue: "6" }
                    K { keyWidth: parent.width * .061; text: "7"; keyValue: "7" }
                    K { keyWidth: parent.width * .061; text: "8"; keyValue: "8" }
                    K { keyWidth: parent.width * .061; text: "9"; keyValue: "9" }
                    K { keyWidth: parent.width * .061; text: "0"; keyValue: "0" }
                    K { keyWidth: parent.width * .061; text: "-"; keyValue: "-" }
                    K { keyWidth: parent.width * .061; text: "="; keyValue: "=" }

                    K {
                        keyWidth: parent.width * .075
                        text: "BACKSPACE"
                        keyValue: "BACKSPACE"
                    }
                }
            }

            // ---------------- NAV ----------------

            Item {
                width: keyboard.navWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .31; text: "INS"; keyValue: "INSERT" }
                    K { keyWidth: parent.width * .31; text: "HOME"; keyValue: "HOME" }
                    K { keyWidth: parent.width * .31; text: "PGUP"; keyValue: "PGUP" }
                }
            }

            // ---------------- NUMPAD ----------------

            Item {
                width: keyboard.numWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .22; text: "NUM"; keyValue: "NUMLOCK" }
                    K { keyWidth: parent.width * .22; text: "/"; keyValue: "/" }
                    K { keyWidth: parent.width * .22; text: "*"; keyValue: "*" }
                    K { keyWidth: parent.width * .22; text: "-"; keyValue: "-" }
                }
            }
        }

        // =====================================================
        // TAB / NAV / NUMPAD 7-9
        // =====================================================

        Row {
            width: parent.width
            height: keyboard.rowHeight
            spacing: keyboard.gap

            Item {
                width: keyboard.mainWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .082
                        text: "TAB"
                        keyValue: "TAB"
                    }

                    K { keyWidth: parent.width * .060; text: "Q"; keyValue: "Q" }
                    K { keyWidth: parent.width * .060; text: "W"; keyValue: "W" }
                    K { keyWidth: parent.width * .060; text: "E"; keyValue: "E" }
                    K { keyWidth: parent.width * .060; text: "R"; keyValue: "R" }
                    K { keyWidth: parent.width * .060; text: "T"; keyValue: "T" }
                    K { keyWidth: parent.width * .060; text: "Y"; keyValue: "Y" }
                    K { keyWidth: parent.width * .060; text: "U"; keyValue: "U" }
                    K { keyWidth: parent.width * .060; text: "I"; keyValue: "I" }
                    K { keyWidth: parent.width * .060; text: "O"; keyValue: "O" }
                    K { keyWidth: parent.width * .060; text: "P"; keyValue: "P" }
                    K { keyWidth: parent.width * .060; text: "["; keyValue: "[" }
                    K { keyWidth: parent.width * .060; text: "]"; keyValue: "]" }

                    K {
                        keyWidth: parent.width * .092
                        text: "\\"
                        keyValue: "\\"
                    }
                }
            }

            Item {
                width: keyboard.navWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .31; text: "DEL"; keyValue: "DELETE" }
                    K { keyWidth: parent.width * .31; text: "END"; keyValue: "END" }
                    K { keyWidth: parent.width * .31; text: "PGDN"; keyValue: "PGDN" }
                }
            }

            Item {
                width: keyboard.numWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .22; text: "7"; keyValue: "7" }
                    K { keyWidth: parent.width * .22; text: "8"; keyValue: "8" }
                    K { keyWidth: parent.width * .22; text: "9"; keyValue: "9" }

                    K {
                        keyWidth: parent.width * .22
                        text: "+"
                        keyValue: "+"
                    }
                }
            }
        }

        // =====================================================
        // CAPS / NUMPAD 4-6
        // =====================================================

        Row {
            width: parent.width
            height: keyboard.rowHeight
            spacing: keyboard.gap

            Item {
                width: keyboard.mainWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .095
                        text: "CAPS"
                        keyValue: "CAPS"
                    }

                    K { keyWidth: parent.width * .060; text: "A"; keyValue: "A" }
                    K { keyWidth: parent.width * .060; text: "S"; keyValue: "S" }
                    K { keyWidth: parent.width * .060; text: "D"; keyValue: "D" }
                    K { keyWidth: parent.width * .060; text: "F"; keyValue: "F" }
                    K { keyWidth: parent.width * .060; text: "G"; keyValue: "G" }
                    K { keyWidth: parent.width * .060; text: "H"; keyValue: "H" }
                    K { keyWidth: parent.width * .060; text: "J"; keyValue: "J" }
                    K { keyWidth: parent.width * .060; text: "K"; keyValue: "K" }
                    K { keyWidth: parent.width * .060; text: "L"; keyValue: "L" }
                    K { keyWidth: parent.width * .060; text: ";"; keyValue: ";" }
                    K { keyWidth: parent.width * .060; text: "'"; keyValue: "'" }

                    K {
                        keyWidth: parent.width * .115
                        text: "ENTER"
                        keyValue: "ENTER"
                    }
                }
            }

            Item {
                width: keyboard.navWidth
                height: keyboard.rowHeight

                Item {
                    anchors.fill: parent
                }
            }

            Item {
                width: keyboard.numWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .22; text: "4"; keyValue: "4" }
                    K { keyWidth: parent.width * .22; text: "5"; keyValue: "5" }
                    K { keyWidth: parent.width * .22; text: "6"; keyValue: "6" }

                    K {
                        keyWidth: parent.width * .22
                        text: "+"
                        keyValue: "+"
                    }
                }
            }
        }

        // =====================================================
        // SHIFT / ARROW CLUSTER / NUMPAD 1-3
        // =====================================================

        Row {
            width: parent.width
            height: keyboard.rowHeight
            spacing: keyboard.gap

            Item {
                width: keyboard.mainWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .135
                        text: "SHIFT"
                        keyValue: "SHIFT"
                    }

                    K { keyWidth: parent.width * .060; text: "Z"; keyValue: "Z" }
                    K { keyWidth: parent.width * .060; text: "X"; keyValue: "X" }
                    K { keyWidth: parent.width * .060; text: "C"; keyValue: "C" }
                    K { keyWidth: parent.width * .060; text: "V"; keyValue: "V" }
                    K { keyWidth: parent.width * .060; text: "B"; keyValue: "B" }
                    K { keyWidth: parent.width * .060; text: "N"; keyValue: "N" }
                    K { keyWidth: parent.width * .060; text: "M"; keyValue: "M" }
                    K { keyWidth: parent.width * .060; text: ","; keyValue: "," }
                    K { keyWidth: parent.width * .060; text: "."; keyValue: "." }
                    K { keyWidth: parent.width * .060; text: "/"; keyValue: "/" }

                    K {
                        keyWidth: parent.width * .155
                        text: "SHIFT"
                        keyValue: "SHIFT"
                    }
                }
            }

            // 3-row arrow cluster is centered here.
            Item {
                width: keyboard.navWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    Item {
                        width: parent.width * .23
                        height: parent.height
                    }

                    K {
                        keyWidth: parent.width * .23
                        text: "↑"
                        keyValue: "UP"
                    }

                    Item {
                        width: parent.width * .23
                        height: parent.height
                    }
                }
            }

            Item {
                width: keyboard.numWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K { keyWidth: parent.width * .22; text: "1"; keyValue: "1" }
                    K { keyWidth: parent.width * .22; text: "2"; keyValue: "2" }
                    K { keyWidth: parent.width * .22; text: "3"; keyValue: "3" }

                    K {
                        keyWidth: parent.width * .22
                        text: "ENT"
                        keyValue: "NUMENTER"
                    }
                }
            }
        }

        // =====================================================
        // BOTTOM CONTROL ROW
        // =====================================================

        Row {
            width: parent.width
            height: keyboard.rowHeight
            spacing: keyboard.gap

            Item {
                width: keyboard.mainWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .085
                        text: "CTRL"
                        keyValue: "CTRL"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "WIN"
                        keyValue: "WIN"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "ALT"
                        keyValue: "ALT"
                    }

                    K {
                        keyWidth: parent.width * .405
                        text: "SPACE"
                        keyValue: "SPACE"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "ALT"
                        keyValue: "ALT"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "FN"
                        keyValue: "FN"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "MENU"
                        keyValue: "MENU"
                    }

                    K {
                        keyWidth: parent.width * .085
                        text: "CTRL"
                        keyValue: "CTRL"
                    }
                }
            }

            // LEFT / DOWN / RIGHT arrow row
            Item {
                width: keyboard.navWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .31
                        text: "←"
                        keyValue: "LEFT"
                    }

                    K {
                        keyWidth: parent.width * .31
                        text: "↓"
                        keyValue: "DOWN"
                    }

                    K {
                        keyWidth: parent.width * .31
                        text: "→"
                        keyValue: "RIGHT"
                    }
                }
            }

            // NUMPAD bottom
            Item {
                width: keyboard.numWidth
                height: keyboard.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: keyboard.gap

                    K {
                        keyWidth: parent.width * .46
                        text: "0"
                        keyValue: "0"
                    }

                    K {
                        keyWidth: parent.width * .22
                        text: "."
                        keyValue: "."
                    }

                    K {
                        keyWidth: parent.width * .22
                        text: "ENT"
                        keyValue: "NUMENTER"
                    }
                }
            }
        }
    }
}
