import QtQuick

Behavior {
    id: behavior

    property int durationMs: 280
    property int easingType: Easing.OutCubic

    NumberAnimation {
        duration: behavior.durationMs
        easing.type: behavior.easingType
    }
}
