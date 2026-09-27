import QtQuick

Canvas {
    id: graph

    property real phase: 0

    Timer {
        interval: 40
        running: true
        repeat: true

        onTriggered: {
            graph.phase += .08
            graph.requestPaint()
        }
    }

    onPaint: {

        var ctx = getContext("2d")
        ctx.reset()

        ctx.strokeStyle = "#102f37"
        ctx.lineWidth = .5

        for (var x = 0; x < width; x += 30) {
            ctx.beginPath()
            ctx.moveTo(x, 0)
            ctx.lineTo(x, height)
            ctx.stroke()
        }

        for (var y = 0; y < height; y += 20) {
            ctx.beginPath()
            ctx.moveTo(0, y)
            ctx.lineTo(width, y)
            ctx.stroke()
        }

        ctx.beginPath()

        for (var px = 0; px <= width; px += 3) {

            var value =
                Math.sin(px * .075 + phase) * .22 +
                Math.sin(px * .19 - phase * .7) * .10 +
                Math.sin(px * .42 + phase) * .04

            var py =
                height / 2 +
                value * height

            if (px === 0)
                ctx.moveTo(px, py)
            else
                ctx.lineTo(px, py)
        }

        ctx.strokeStyle = "#67d7e3"
        ctx.lineWidth = 1.2
        ctx.stroke()
    }

    Component.onCompleted: requestPaint()
}
