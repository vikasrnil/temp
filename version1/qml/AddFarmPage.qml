import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.1

Page {
    id: addFarmPage
    width: 760
    height: 440

    signal backPressed()
    signal plotFarm()
    signal traceFarm()
    signal farmSaved()      // ✅ REQUIRED SIGNAL ADDED

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    // ---------- TOP BAR ----------
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
            color: "white"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ---------- MAIN PANEL ----------
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

            Text {
                text: "Choose Your Option"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            Column {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // ---------- Plot Farm Button ----------
                Button {
                    width: 250
                    height: 48
                    text: "Plot Farm"
                    background: Rectangle {
                        color: "#00C7CC"
                        radius: 6
                    }
                    onClicked: plotFarm()
                }

                // ---------- Trace Farm Button ----------
                Button {
                    width: 250
                    height: 48
                    text: "Trace Farm"
                    background: Rectangle {
                        color: "transparent"
                        radius: 6
                        border.color: "#00C7CC"
                        border.width: 2
                    }
                    onClicked: traceFarm()
                }
            }
        }
    }
    InputPanel {
            id: keyboard
            z: 1000
            anchors.left: parent.left
            anchors.right: parent.right
            y: parent.height - height
            visible: Qt.inputMethod.visible
        }
}
