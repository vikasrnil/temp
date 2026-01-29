import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1   // FileDialog
import QtQuick.VirtualKeyboard 2.1

Page {
    id: implementFormPage
    width: 760
    height: 440

    signal backPressed()
    signal saved()

    //
    // ------------------------------
    // STATE VARIABLES
    // ------------------------------
    //
    property bool editMode: false
    property string originalName: ""
    property string imagePath: ""

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"
    }

    // ---------------- TOP BAR ----------------
    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        spacing: 10

        Button {
            text: "<"
            width: 40
            onClicked: backPressed()
        }

        Text {
            text: editMode ? "Edit Implement" : "Implement"
            color: "white"
            font.pixelSize: 18
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    // ---------------- MAIN PANEL ----------------
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

        RowLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 40

            //------------------ UPLOAD BOX ------------------
            Rectangle {
                Layout.preferredWidth: 230
                Layout.preferredHeight: 230
                radius: 10
                color: "#1E1E1E"
                border.color: "#666"
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    border.color: "#999"
                    border.width: 2
                    radius: 8
                    color: "transparent"
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: 20
                    source: imagePath
                    fillMode: Image.PreserveAspectFit
                    visible: imagePath !== ""
                }

                Text {
                    visible: imagePath === ""
                    anchors.centerIn: parent
                    text: "Click to upload\nPNG, JPG"
                    color: "#999"
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileDialog.open()
                }
            }

            //------------------ FORM SECTION ------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: "Implement Info"
                    color: "white"
                    font.pixelSize: 17
                    font.bold: true
                }

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 12
                        width: 150

                        Text { text: "Implement Name :" ; color: "#ccc" }
                        Text { text: "Type :" ; color: "#ccc" }
                        Text { text: "Txxxx :" ; color: "#ccc" }
                        Text { text: "Width :" ; color: "#ccc" }
                    }

                    ColumnLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        TextField { id: nameField; placeholderText: "Name"; Layout.fillWidth: true }
                        TextField { id: typeField; placeholderText: "Type"; Layout.fillWidth: true }
                        TextField { id: txField; placeholderText: "Txxxx"; Layout.fillWidth: true }
                        TextField { id: widthField; placeholderText: "Width (m)"; Layout.fillWidth: true }
                    }
                }

                //------------------ BUTTONS ------------------
                RowLayout {
                    spacing: 20
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        text: "Cancel"
                        width: 140
                        background: Rectangle { color: "#999"; radius: 6 }

                        onClicked: {
                            nameField.text = ""
                            typeField.text = ""
                            txField.text = ""
                            widthField.text = ""
                            imagePath = ""
                            editMode = false
                            originalName = ""
                        }
                    }

                    Button {
                        text: editMode ? "Update" : "Save"
                        width: 140
                        background: Rectangle { color: "#00C7CC"; radius: 6 }

                        onClicked: {
                            var nm = nameField.text.trim()
                            if (nm === "") {
                                console.log("Name required")
                                return
                            }

                            var data = {
                                name: nm,
                                type: typeField.text,
                                tx: txField.text,
                                width: widthField.text,
                                image: imagePath !== "" ? imagePath : "qrc:/images/implement.png"
                            }

                            if (editMode) {
                                var res = implementBackend.updateImplementData(data, originalName)
                                console.log("Update result:", res)
                            } else {
                                var saveRes = implementBackend.saveImplementData(data)
                                console.log("Save result:", saveRes)
                            }

                            // Reset form
                            nameField.text = ""
                            typeField.text = ""
                            txField.text = ""
                            widthField.text = ""
                            imagePath = ""
                            editMode = false
                            originalName = ""

                            saved()
                        }
                    }
                }
            }
        }
    }

    // ---------------- FILE DIALOG ----------------
    FileDialog {
        id: fileDialog
        title: "Choose Implement Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg)"]

        onAccepted: {
            implementFormPage.imagePath = fileDialog.file
            console.log("Selected File:", fileDialog.file)
        }
    }

    // ---------------- EDIT PREFILL ----------------
    function loadForEdit(item) {
        if (!item) return

        nameField.text = item.name ?? ""
        typeField.text = item.type ?? ""
        txField.text = item.tx ?? ""
        widthField.text = item.width ?? ""
        imagePath = item.image ?? ""

        editMode = true
        originalName = item.name
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
