import QtQuick
import QtQuick.Window

Canvas {
    id: canvas

    property real phase: 0

    Timer {
        interval: 16
        running: true
        repeat: true

        onTriggered: {
            canvas.phase += .075
            canvas.requestPaint()
        }
    }

    onPaint: {
        var ctx = getContext("2d")

        ctx.reset()

        // grid
        ctx.strokeStyle = (Window.window ? Window.window.dysenAccentDim : "#00333B")
        ctx.lineWidth = .5

        for (var x = 0; x < width; x += 28) {
            ctx.beginPath()
            ctx.moveTo(x, 0)
            ctx.lineTo(x, height)
            ctx.stroke()
        }

        for (var y = 0; y < height; y += 24) {
            ctx.beginPath()
            ctx.moveTo(0, y)
            ctx.lineTo(width, y)
            ctx.stroke()
        }

        // waveform
        ctx.beginPath()

        for (var px = 0; px < width; px += 2) {

            var wave =
                Math.sin(px * .045 + phase) * height * .20 +
                Math.sin(px * .11 - phase * .7) * height * .08 +
                Math.sin(px * .22 + phase * 1.4) * height * .035

            var py = height / 2 + wave

            if (px === 0)
                ctx.moveTo(px, py)
            else
                ctx.lineTo(px, py)
        }

        ctx.strokeStyle = "#a8edf7"
        ctx.lineWidth = 1.2

        ctx.stroke()
    }

    Component.onCompleted: requestPaint()
}
