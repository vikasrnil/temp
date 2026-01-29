import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: detailsPopup
    modal: true
    focus: true
    width: 480
    height: 320
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var dataItem: ({})
    signal editRequested(var item)
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

        // ---------------- TOP ROW ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                source: "qrc:/images/implement.png"
                width: 32; height: 32
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

            // Simple EDIT button (no image)
            // Button {
            //     text: "Edit"
            //     width: 70
            //     height: 30
            //     background: Rectangle { color: "#00C7CC"; radius: 6 }
            //     onClicked: editRequested(dataItem)
            // }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

        // ---------------- MAIN CONTENT ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // Left-side Implement image
            Rectangle {
                width: 150; height: 120
                radius: 8
                color: "white"
                border.color: "#ccc"

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: dataItem.image ?? ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            // Right-side details
            ColumnLayout {
                spacing: 6

                Text {
                    text: "Implement Name:  " + (dataItem.name ?? "")
                    color: "#222"
                    font.pixelSize: 14
                }

                Text {
                    text: "Type:  " + (dataItem.type ?? "")
                    color: "#222"
                    font.pixelSize: 14
                }

                Text {
                    text: "Txxxx:  " + (dataItem.tx ?? "")
                    color: "#222"
                    font.pixelSize: 14
                }

                Text {
                    text: "Width:  " + (dataItem.width ?? "")
                    color: "#222"
                    font.pixelSize: 14
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

        // ---------------- BOTTOM BUTTONS ----------------
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Cancel"
                width: 110
                height: 32
                background: Rectangle { color: "#bbb"; radius: 6 }
                onClicked: detailsPopup.close()
            }

        }
    }
}
