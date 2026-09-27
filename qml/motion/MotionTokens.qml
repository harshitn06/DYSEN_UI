import QtQuick

QtObject {
    readonly property int instant: 0
    readonly property int fast: 140
    readonly property int normal: 220
    readonly property int slow: 360
    readonly property int workspace: 280

    readonly property int standardEasing: Easing.OutCubic
    readonly property int smoothEasing: Easing.InOutCubic
    readonly property int enterEasing: Easing.OutQuart
    readonly property int exitEasing: Easing.InCubic
    readonly property int springEasing: Easing.OutBack
}
