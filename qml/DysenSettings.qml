import QtQuick

Item {
    id: root

    anchors.fill: parent
    z: 2000000
    visible: false

    signal accentChanged(color value)
    signal bgmVolumeChanged(real value)
    signal bgmEnabledChanged(bool value)
    signal closed()

    property color editAccent: "#00F6FF"
    property real editVolume: 0.80
    property bool editBgmEnabled: true

    property var themes: [
        { name: "CYAN",   color: "#00F6FF", secondary: "#7CF2FF", motif: "CYBER // SCAN" },
        { name: "WHITE",  color: "#F5F7FA", secondary: "#AEB7C2", motif: "PRECISION // GLASS" },
        { name: "VIOLET", color: "#A78BFA", secondary: "#D9C9FF", motif: "AURORA // NEBULA" },
        { name: "GREEN",  color: "#35F0A0", secondary: "#A8FFD8", motif: "TERMINAL // BIO-TECH" },
        { name: "AMBER",  color: "#FFB84A", secondary: "#FFE1A6", motif: "COCKPIT // INDUSTRIAL" },
        { name: "PINK",   color: "#FF6EA8", secondary: "#FFC3DA", motif: "FLORAL // TECH" },
        { name: "RED",    color: "#FF4D6D", secondary: "#FFABB9", motif: "WARNING // HIGH ALERT" },
        { name: "BLUE",   color: "#4DA3FF", secondary: "#A9D4FF", motif: "ICE // DEEP TECH" }
    ]

    property string editThemeName: themeNameForColor(editAccent)
    property var editThemeSpec: themeSpecFor(editThemeName)

    function themeNameForColor(value) {
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

    function themeSpecFor(name) {
        for (var i = 0; i < themes.length; ++i) {
            if (themes[i].name === name)
                return themes[i]
        }
        return themes[0]
    }

    function openWith(accent, volumeValue, enabledValue) {
        editAccent = accent
        editVolume = volumeValue
        editBgmEnabled = enabledValue
        visible = true
        openAnimation.restart()
    }

    function close() {
        closeAnimation.restart()
    }

    function setVolume(xPos) {
        editVolume = Math.max(0.0, Math.min(1.0, xPos / volumeTrack.width))
        bgmVolumeChanged(editVolume)
    }

    function chooseTheme(item) {
        editAccent = item.color
        accentChanged(item.color)
    }

    function resetDefaults() {
        editAccent = "#00F6FF"
        editVolume = 0.80
        editBgmEnabled = true
        accentChanged(editAccent)
        bgmVolumeChanged(editVolume)
        bgmEnabledChanged(editBgmEnabled)
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.78

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }
    }

    Rectangle {
        id: panel

        width: Math.min(760, root.width - 80)
        height: Math.min(520, root.height - 100)
        anchors.centerIn: parent

        radius: editThemeName === "PINK" ? 9 : (editThemeName === "WHITE" ? 3 : 5)
        color: "#000000"
        border.width: 1
        border.color: editAccent
        opacity: 0
        scale: 0.96
        clip: true

        Rectangle {
            x: 0
            y: 0
            width: parent.width * 0.32
            height: 2
            color: editAccent
        }

        Rectangle {
            x: 12
            y: 12
            width: parent.width - 24
            height: parent.height - 24
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(editAccent.r, editAccent.g, editAccent.b, 0.14)
            radius: panel.radius > 5 ? 5 : 2
        }

        Text {
            x: 28
            y: 22
            text: "DYSEN // CONFIGURATION"
            color: editAccent
            font.family: "Monospace"
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 2
        }

        Text {
            x: 28
            y: 48
            text: "THEME LANGUAGE / SESSION AUDIO / AUTO-SAVE"
            color: "#59676E"
            font.family: "Monospace"
            font.pixelSize: 8
            font.letterSpacing: 1.1
        }

        Rectangle {
            x: 28
            y: 73
            width: parent.width - 56
            height: 1
            color: Qt.rgba(editAccent.r, editAccent.g, editAccent.b, 0.16)
        }

        Text {
            x: 28
            y: 92
            text: "THEME SYSTEM"
            color: editAccent
            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.2
        }

        Grid {
            id: themeGrid
            x: 28
            y: 116
            width: parent.width - 56
            columns: 4
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: root.themes

                delegate: Item {
                    width: (themeGrid.width - 30) / 4
                    height: 66

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: "#030303"
                        border.width: editThemeName === modelData.name ? 2 : 1
                        border.color: editThemeName === modelData.name
                            ? modelData.secondary
                            : "#283138"

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: modelData.color
                        opacity: editThemeName === modelData.name ? 0.07 : 0
                    }
                    }

                    Rectangle {
                        x: 10
                        y: 10
                        width: 32
                        height: 32
                        radius: modelData.name === "PINK" ? 8 : 4
                        color: modelData.color
                    }

                    Rectangle {
                        x: 47
                        y: 10
                        width: parent.width - 57
                        height: 4
                        radius: 2
                        color: modelData.secondary
                    }

                    Text {
                        x: 47
                        y: 21
                        text: modelData.name
                        color: editThemeName === modelData.name ? modelData.secondary : "#7D8A92"
                        font.family: "Monospace"
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        x: 10
                        y: 49
                        text: modelData.motif
                        color: editThemeName === modelData.name ? modelData.color : "#44525A"
                        font.family: "Monospace"
                        font.pixelSize: 6
                        font.letterSpacing: 0.5
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.chooseTheme(modelData)
                    }
                }
            }
        }

        // Selected-theme preview: actual DYSEN panel language in miniature.
        Rectangle {
            x: 28
            y: 263
            width: parent.width - 56
            height: 82
            radius: 4
            color: "#000000"
            border.width: 1
            border.color: editAccent

            Rectangle {
                x: 1
                y: 1
                width: parent.width - 2
                height: 18
                color: editThemeName === "PINK"
                    ? "#10050A"
                    : editThemeName === "VIOLET"
                        ? "#09060F"
                        : "#02080A"

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 72
                    height: 2
                    color: editAccent
                }
            }

            Text {
                x: 12
                y: 28
                text: editThemeName + "  //  " + editThemeSpec.motif
                color: editAccent
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
                font.letterSpacing: 0.9
            }

            Rectangle {
                x: 12
                y: 50
                width: parent.width * 0.26
                height: 3
                radius: 1.5
                color: editAccent
            }

            Rectangle {
                x: parent.width * 0.30
                y: 50
                width: parent.width * 0.20
                height: 3
                radius: 1.5
                color: editThemeSpec.secondary
            }

            Rectangle {
                x: parent.width * 0.54
                y: 50
                width: parent.width * 0.42
                height: 3
                radius: 1.5
                color: Qt.rgba(editAccent.r, editAccent.g, editAccent.b, 0.20)
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                y: 62
                text: "PANEL LANGUAGE PREVIEW"
                color: "#4F5C63"
                font.family: "Monospace"
                font.pixelSize: 6
                font.letterSpacing: 0.7
            }
        }

        Text {
            x: 28
            y: 365
            text: "BACKGROUND MUSIC"
            color: editAccent
            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.2
        }

        Item {
            x: parent.width - 142
            y: 356
            width: 114
            height: 28

            Rectangle {
                anchors.fill: parent
                radius: 3
                color: editBgmEnabled
                    ? Qt.rgba(editAccent.r, editAccent.g, editAccent.b, 0.10)
                    : "#050505"
                border.width: 1
                border.color: editBgmEnabled ? editAccent : "#263037"
            }

            Text {
                anchors.centerIn: parent
                text: editBgmEnabled ? "ENABLED" : "MUTED"
                color: editBgmEnabled ? editAccent : "#586870"
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
                font.letterSpacing: 1
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    editBgmEnabled = !editBgmEnabled
                    bgmEnabledChanged(editBgmEnabled)
                }
            }
        }

        Text {
            x: 28
            y: 397
            text: "VOLUME"
            color: "#78868D"
            font.family: "Monospace"
            font.pixelSize: 8
            font.bold: true
            font.letterSpacing: 1
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 28
            y: 396
            text: Math.round(editVolume * 100) + "%"
            color: editAccent
            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
        }

        Rectangle {
            id: volumeTrack
            x: 28
            y: 420
            width: parent.width - 56
            height: 5
            radius: 2.5
            color: "#111820"

            Rectangle {
                width: volumeTrack.width * editVolume
                height: parent.height
                radius: 2.5
                color: editAccent
            }

            Rectangle {
                width: 12
                height: 12
                x: volumeTrack.width * editVolume - 6
                y: -3
                radius: 6
                color: editAccent
                border.width: 2
                border.color: "#000000"
            }

            MouseArea {
                anchors.fill: parent
                onPressed: root.setVolume(mouse.x)
                onPositionChanged: {
                    if (pressed)
                        root.setVolume(mouse.x)
                }
            }
        }

        Text {
            x: 28
            y: 441
            text: "Changes are saved automatically."
            color: "#59676E"
            font.family: "Monospace"
            font.pixelSize: 7
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 28
            y: 441
            text: "CTRL + ,"
            color: editAccent
            font.family: "Monospace"
            font.pixelSize: 7
            font.bold: true
        }

        Item {
            x: 28
            y: parent.height - 40
            width: 132
            height: 28

            Rectangle {
                anchors.fill: parent
                color: "#050505"
                border.width: 1
                border.color: "#243038"
            }

            Text {
                anchors.centerIn: parent
                text: "RESET DEFAULTS"
                color: "#6B7A82"
                font.family: "Monospace"
                font.pixelSize: 7
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.resetDefaults()
            }
        }

        Item {
            x: parent.width - 160
            y: parent.height - 40
            width: 132
            height: 28

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(editAccent.r, editAccent.g, editAccent.b, 0.08)
                border.width: 1
                border.color: editAccent
            }

            Text {
                anchors.centerIn: parent
                text: "CLOSE"
                color: editAccent
                font.family: "Monospace"
                font.pixelSize: 8
                font.bold: true
                font.letterSpacing: 1
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }
    }

    ParallelAnimation {
        id: openAnimation

        NumberAnimation {
            target: panel
            property: "opacity"
            from: 0
            to: 1
            duration: 210
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panel
            property: "scale"
            from: 0.96
            to: 1
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation

        NumberAnimation {
            target: panel
            property: "opacity"
            from: 1
            to: 0
            duration: 150
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panel
            property: "scale"
            from: 1
            to: 0.97
            duration: 150
            easing.type: Easing.InCubic
        }

        onFinished: {
            root.visible = false
            root.closed()
        }
    }
}
