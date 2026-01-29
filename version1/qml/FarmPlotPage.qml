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

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    // ─────────────────────────────
    // TOP BAR
    // ─────────────────────────────
    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        Button {
            text: "<"
            width: 40
            background: Rectangle { color: "transparent" }
            onClicked: backPressed()
        }

        Text {
            text: "Add Farm"
            color: "white"
            font.pixelSize: 18
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ─────────────────────────────
    // MAIN PANEL
    // ─────────────────────────────
    Rectangle {
        anchors {
            top: parent.top
            topMargin: 55
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }
        radius: 12
        color: "#2A2A2A"
        border.color: "#444"
        border.width: 1

        Column {
            anchors.centerIn: parent

            Text {
                text: "Choose Your Option"
                color: "white"
                font.pixelSize: 19
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter

                // PLOT FARM BUTTON
                Rectangle {
                    width: 220
                    height: 48
                    radius: 6
                    color: "#00C7CC"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: plotFarm()
                    }

                    Text {
                        text: "Plot Farm"
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                // TRACE FARM BUTTON
                Rectangle {
                    width: 220
                    height: 48
                    radius: 6
                    color: "transparent"
                    border.color: "#00C7CC"
                    border.width: 2
                    anchors.topMargin: 22

                    MouseArea {
                        anchors.fill: parent
                        onClicked: traceFarm()
                    }

                    Text {
                        text: "Trace Farm"
                        anchors.centerIn: parent
                        color: "#00C7CC"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }
        }
    }
}
