import QtQuick

QtObject {
    id: controller

    property bool enabled: true
    property real velocity: 0.0
    property real distance: 0.0
    property int baseDuration: 280

    readonly property int calculatedDuration: {
        if (distance <= 0.0)
            return baseDuration

        var d = Math.abs(distance)
        var v = Math.abs(velocity)

        if (v <= 0.01)
            return Math.max(180, Math.min(420, baseDuration + d * 40))

        var result = (d / v) * 1000

        return Math.max(150, Math.min(420, result))
    }

    signal transitionStarted()
    signal transitionFinished()

    function begin(distanceValue, velocityValue) {
        if (!enabled)
            return

        distance = Math.max(0.0, Math.abs(distanceValue))
        velocity = velocityValue

        transitionStarted()
    }

    function finish() {
        transitionFinished()
    }
}
