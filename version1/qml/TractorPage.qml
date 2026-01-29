import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import QtQuick.VirtualKeyboard 2.1

Page {
    id: tractorForm
    width: 760
    height: 440

    signal backPressed()
    signal saved()

    property bool editMode: false
    property string originalName: ""
    property string imagePath: ""

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    // ---------------- TOP BAR ----------------
    Rectangle {
        width: parent.width
        height: 45
        color: "#111"

        Row {
            anchors.verticalCenter: parent.verticalCenter

            Button {
                text: "<"
                width: 40
                onClicked: backPressed()
            }

            Text {
                text: editMode ? "Edit Tractor" : "Tractor"
                color: "white"
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
            }
        }
    }


    Rectangle {
        anchors {
            top: parent.top; topMargin: 55
            left: parent.left; right: parent.right
            bottom: parent.bottom; margins: 20
        }
        radius: 12
        color: "#2A2A2A"
        border.color: "#444"

        Row {
            anchors.fill: parent
            anchors.margins: 20


            Rectangle {
                width: 230
                height: 230
                radius: 12
                color: "#1E1E1E"
                border.color: "#666"

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    color: "transparent"
                    border.color: "#999"
                    border.width: 2
                    radius: 8
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: 20
                    source: imagePath
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    visible: imagePath === ""
                    text: "Click to upload\nPNG / JPG"
                    color: "#bbbbbb"
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileDialog.open()
                }
            }

            // Small GAP
            Rectangle { width: 20; height: 1; color: "transparent" }

            // ========== FORM ==========
            Column {
                anchors.verticalCenter: parent.verticalCenter

                // HEADER
                Text {
                    text: "Tractor Info"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }

                Rectangle { height: 15; width: 1; color: "transparent" }

                // NAME ROW
                Row {
                    Text { text: "Name:"; color: "#ccc"; width: 100 }
                    TextField { id: nameField; placeholderText: "Name"; width: 200 }
                }

                Rectangle { height: 10; width: 1; color: "transparent" }

                // MODEL ROW
                Row {
                    Text { text: "Model:"; color: "#ccc"; width: 100 }
                    TextField { id: modelField; placeholderText: "Model"; width: 200 }
                }

                Rectangle { height: 10; width: 1; color: "transparent" }

                // HP ROW
                Row {
                    Text { text: "HP:"; color: "#ccc"; width: 100 }
                    TextField { id: hpField; placeholderText: "Horse Power"; width: 200 }
                }

                Rectangle { height: 10; width: 1; color: "transparent" }

                // WIDTH ROW
                Row {
                    Text { text: "Width:"; color: "#ccc"; width: 100 }
                    TextField { id: widthField; placeholderText: "Width (m)"; width: 200 }
                }

                Rectangle { height: 10; width: 1; color: "transparent" }

                // NOTES ROW
                Row {
                    Text { text: "Notes:"; color: "#ccc"; width: 100 }
                    TextArea {
                        id: notesField
                        width: 200
                        height: 60
                        wrapMode: Text.WordWrap
                        placeholderText: "Notes"
                    }
                }

                Rectangle { height: 20; width: 1; color: "transparent" }

                // -------- BUTTONS --------
                Row {
                    Button {
                        text: "Cancel"
                        width: 120
                        background: Rectangle { color: "#777"; radius: 6 }
                        onClicked: {
                            resetForm()
                            backPressed()
                        }
                    }

                    Rectangle { width: 10; height: 1; color: "transparent" }

                    Button {
                        text: editMode ? "Update" : "Save"
                        width: 120
                        background: Rectangle { color: "#00C7CC"; radius: 6 }

                        onClicked: {
                            var nameTrim = nameField.text.trim()
                            if (nameTrim === "") { console.log("Name missing"); return }

                            var data = {
                                "name": nameTrim,
                                "model": modelField.text,
                                "hp": hpField.text,
                                "width": widthField.text,
                                "notes": notesField.text,
                                "image": imagePath === "" ?
                                    "qrc:/images/tractor.png" :
                                    imagePath
                            }

                            var res = operations.saveTractorData(data)
                            console.log("Saved:", res)

                            resetForm()
                            saved()
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Tractor Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg)"]
        onAccepted: imagePath = file
    }

    function resetForm() {
        nameField.text = ""
        modelField.text = ""
        hpField.text = ""
        widthField.text = ""
        notesField.text = ""
        imagePath = ""
        editMode = false
        originalName = ""
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

