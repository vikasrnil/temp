import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: savedImplPage
    width: 760
    height: 440

    signal backPressed()
    signal addNew()
    signal editRequested(var item)
    signal selected(var item)

    property var implementsList: []

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"
    }

    /* ---------- TOP BAR ---------- */
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
                text: "Implements"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
            }
        }
    }

    /* ---------- MAIN AREA ---------- */
    Rectangle {
        anchors {
            top: parent.top; topMargin: 55
            left: parent.left; right: parent.right
            bottom: parent.bottom; margins: 20
        }

        radius: 12
        color: "#2A2A2A"
        border.color: "#444"

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Your Saved Tractors"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            GridView {
                id: grid
                anchors {
                    top: parent.top; topMargin: 40
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                cellWidth: 200
                cellHeight: 220
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: true
                flow: GridView.FlowLeftToRight

                model: implementsList.length + 1   // Add New first card

                delegate: Rectangle {
                    width: 180
                    height: 200
                    radius: 12
                    color: "#1E1E1E"
                    border.color: "#00C7CC"
                    border.width: 2

                    property bool isAddCard: (index === 0)
                    property var implData: isAddCard ? null : implementsList[index - 1]

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        /* ---------- Add New Card ---------- */
                        Item {
                            visible: isAddCard
                            width: 140; height: 140

                            MouseArea { anchors.fill: parent; onClicked: addNew() }

                            Column {
                                anchors.centerIn: parent
                                spacing: 10

                                Rectangle {
                                    width: 60; height: 60
                                    radius: 8
                                    color: "#00C7CC22"
                                    Text {
                                        text: "+"
                                        anchors.centerIn: parent
                                        font.pixelSize: 32
                                        font.bold: true
                                        color: "#00C7CC"
                                    }
                                }

                                Text {
                                    text: "Add New"
                                    font.pixelSize: 14
                                    color: "white"
                                }
                            }
                        }

                        /* ---------- Saved Card UI ---------- */
                        Item {
                            visible: !isAddCard
                            width: 180; height: 200

                            Column {
                                anchors.centerIn: parent
                                spacing: 10

                                Rectangle {
                                    width: 110; height: 85
                                    radius: 8
                                    color: "white"
                                    border.color: "#666"

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        source: implData.image
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }

                                Text {
                                    text: implData.name
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    width: 140
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Row {
                                    spacing: 8
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Button {
                                        text: "Select"
                                        width: 60
                                        height: 28
                                        background: Rectangle { color: "#00C7CC"; radius: 6 }
                                        onClicked: {
                                            implementPopup.dataItem = implData
                                            implementPopup.open()
                                        }
                                    }

                                    Button {
                                        text: "Del"
                                        width: 50
                                        height: 28
                                        background: Rectangle { color: "#CC3333"; radius: 6 }
                                        onClicked: confirmDelete(implData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /* Popup stays unchanged */
    ImplementDetailsPopup {
        id: implementPopup
        onEditRequested: function(item) { savedImplPage.editRequested(item); close() }
        onSelected: function(item) { savedImplPage.selected(item); close() }
    }

    Dialog {
        id: deleteDialog
        modal: true
        width: 250
        property string targetName: ""

        contentItem: Text {
            text: "Delete '" + targetName + "'?"
            color: "white"
            wrapMode: Text.WordWrap
            anchors.margins: 10
        }

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            implementBackend.deleteImplementData(targetName)
            implementsList = implementBackend.loadAllImplements()
        }
    }

    function confirmDelete(name) {
        deleteDialog.targetName = name
        deleteDialog.open()
    }

    Component.onCompleted: {
        implementsList = implementBackend.loadAllImplements()
    }

    Connections {
        target: implementBackend
        onImplementSaved: implementsList = implementBackend.loadAllImplements()
        onImplementDeleted: implementsList = implementBackend.loadAllImplements()
    }
}
