import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: tractorPopup
    modal: true
    focus: true
    width: 480
    height: 320
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var dataItem: ({})
    signal selected(var item)

    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#ccc"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ------- HEADER -------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                source: dataItem.image ?? ""
                width: 32
                height: 32
                fillMode: Image.PreserveAspectFit
            }

            Text {
                text: dataItem.name ?? ""
                font.pixelSize: 20
                font.bold: true
                color: "#222"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

        // ------- MAIN CONTENT -------
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Rectangle {
                width: 150
                height: 120
                radius: 8
                border.color: "#ccc"
                color: "white"

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: dataItem.image ?? ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                spacing: 6

                Text { text: "Name:  " + (dataItem.name ?? ""); color: "#222" }
                Text { text: "Model:  " + (dataItem.model ?? ""); color: "#222" }
                Text { text: "HP:  " + (dataItem.hp ?? ""); color: "#222" }
                Text { text: "Width:  " + (dataItem.width ?? ""); color: "#222" }
                Text { text: "Notes:  " + (dataItem.notes ?? ""); color: "#222" }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

        // ------- BUTTONS -------
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Cancel"
                width: 110
                height: 32
                background: Rectangle { color: "#bbb"; radius: 6 }
                onClicked: tractorPopup.close()
            }

            // Button {
            //     text: "Select"
            //     width: 110
            //     height: 32
            //     background: Rectangle { color: "#00C7CC"; radius: 6 }
            //     onClicked: selected(dataItem)
            // }
        }
    }
}

