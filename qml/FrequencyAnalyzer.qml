import QtQuick

Canvas {
    id: analyzer

    property real phase: 0

    Timer {
        interval: 80
        running: true
        repeat: true

        onTriggered: {
            analyzer.phase += .15
            analyzer.requestPaint()
        }
    }

    onPaint: {

        var ctx = getContext("2d")
        ctx.reset()

        var bars = Math.max(
            10,
            Math.floor(width / 15)
        )

        var gap = width / bars

        for (var i = 0; i < bars; i++) {

            var v =
                .18 +
                Math.abs(
                    Math.sin(
                        i * .8 +
                        phase
                    )
                ) * .72

            var h = height * v

            ctx.fillStyle = "#347f8a"

            ctx.fillRect(
                i * gap + 2,
                height - h,
                Math.max(2, gap - 4),
                h
            )
        }

        ctx.strokeStyle = "#173b43"
        ctx.lineWidth = .5

        for (var y = 0; y < height; y += 20) {

            ctx.beginPath()
            ctx.moveTo(0, y)
            ctx.lineTo(width, y)
            ctx.stroke()
        }
    }

    Component.onCompleted: requestPaint()
}
