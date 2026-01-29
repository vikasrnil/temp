import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: addFarmPage
    width: 760
    height: 440

    signal backPressed()
    signal plotFarm()
    signal traceFarm()

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"
    }

    // Top Bar
    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        Button {
            text: "<"
            width: 40
            onClicked: backPressed()
        }

        Text {
            text: "Add Farm"
            font.pixelSize: 18
            font.bold: true
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            topMargin: 55
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }
        radius: 10
        color: "#2A2A2A"
        border.color: "#444"

        Column {
            anchors.centerIn: parent
            spacing: 30

            Text {
                text: "Choose Your Option"
                font.pixelSize: 18
                color: "white"
                font.bold: true
            }

            // Plot Button
            Button {
                width: 220
                height: 48
                text: "Plot Farm"
                background: Rectangle { color: "#00C7CC"; radius: 6 }
                onClicked: plotFarm()
            }

            // Trace Button
            Button {
                width: 220
                height: 48
                text: "Trace Farm"
                background: Rectangle { border.color: "#00C7CC"; border.width: 2; color: "transparent"; radius: 6 }
                onClicked: traceFarm()
            }
        }
    }
}
