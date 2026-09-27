import QtQuick
import QtQuick.Window

Item {
    id: grid

    property string snapshot: ""
    property int columns: 120
    property int rows: 32

    property real cellWidth: 7.2
    property real cellHeight: 15

    property int cursorX: 0
    property int cursorY: 0
    property bool cursorVisible: false

    property var cells: []

    function rebuild() {
        if (!snapshot || snapshot.length === 0) {
            cells = []
            return
        }

        try {
            cells = JSON.parse(snapshot)
        } catch (e) {
            console.log("DYSEN GRID JSON:", e)
            cells = []
        }
    }

    onSnapshotChanged: rebuild()

    width:
        columns * cellWidth

    height:
        rows * cellHeight

    Component.onCompleted: rebuild()

    // =====================================================
    // CELL BACKGROUND + TEXT
    // =====================================================

    Repeater {
        model: grid.rows * grid.columns

        delegate: Rectangle {
            property int cellIndex: index

            property int row:
                Math.floor(
                    cellIndex / grid.columns
                )

            property int column:
                cellIndex % grid.columns

            property var cell:
                (
                    grid.cells.length > row &&
                    grid.cells[row] &&
                    grid.cells[row].length > column
                )
                ? grid.cells[row][column]
                : [" ", "#BFEAF0", "#000000", false, false, false]

            x:
                column * grid.cellWidth

            y:
                row * grid.cellHeight

            width: grid.cellWidth
            height: grid.cellHeight

            color:
                cell.length > 2
                ? cell[2]
                : "#000000"

            Text {
                anchors.fill: parent

                text:
                    cell.length > 0
                    ? cell[0]
                    : " "

                color:
                    cell.length > 1
                    ? cell[1]
                    : "#BFEAF0"

                font.family: "monospace"

                font.pixelSize: 11

                font.bold:
                    cell.length > 3
                    ? cell[3]
                    : false

                font.italic: false

                verticalAlignment:
                    Text.AlignVCenter

                horizontalAlignment:
                    Text.AlignLeft

                renderType:
                    Text.NativeRendering

                // Keep each terminal cell exactly one character.
                clip: true
            }
        }
    }

    // =====================================================
    // CURSOR
    // =====================================================

    Rectangle {
        id: cursor

        visible:
            grid.cursorVisible &&
            grid.cursorX >= 0 &&
            grid.cursorX < grid.columns &&
            grid.cursorY >= 0 &&
            grid.cursorY < grid.rows

        x:
            grid.cursorX *
            grid.cellWidth

        y:
            grid.cursorY *
            grid.cellHeight

        width:
            grid.cellWidth

        height:
            grid.cellHeight

        color: Window.window ? Window.window.dysenAccent : "#00F6FF"

        opacity: 0.8

        SequentialAnimation on opacity {
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.15
                duration: 450
            }

            NumberAnimation {
                to: 0.8
                duration: 450
            }
        }
    }
}
