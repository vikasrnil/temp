import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 420
    title: "WiFi Manager"

    property string selectedSSID: ""

    Timer {
        interval: 1200
        running: true
        repeat: true
        onTriggered: {
            wifiListModel.clear()
            var list = wifiHandler.scanWifi()
            for (var i = 0; i < list.length; i++)
                wifiListModel.append({ name: list[i] })
        }
    }

    Column {
        anchors.fill: parent
        spacing: 16
        padding: 20

        // Header
        Text {
            text: "WiFi Manager"
            font.pixelSize: 30
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // WiFi Status Row
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: wifiHandler.connected ? "green" : "red"
            }

            Text {
                font.pixelSize: 18
                text: wifiHandler.connected
                      ? "Connected to " + wifiHandler.connectedSSID +
                        " (IP: " + wifiHandler.ipAddress + ")"
                      : "Disconnected"
            }
        }

        // WiFi Switch
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Text { text: "WiFi:"; font.pixelSize: 20 }

            Switch {
                id: wifiSwitch
                checked: true
                onToggled: wifiHandler.wifiOnOff(checked)
            }
        }

        // WiFi List
        Rectangle {
            width: parent.width - 40
            height: 200
            color: "white"
            radius: 10
            border.width: 1
            border.color: "#ccc"

            ListView {
                anchors.fill: parent
                model: ListModel { id: wifiListModel }
                spacing: 4

                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    radius: 6
                    color: "#f2f2f2"
                    border.width: 1
                    border.color: "#ddd"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: name
                            font.pixelSize: 16
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: wifiHandler.connectedSSID === name ? "green" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedSSID = name
                            passField.text = ""
                            pwdPopup.open()
                        }
                    }
                }
            }
        }
    }

    // Password Popup
    Dialog {
        id: pwdPopup
        title: "Connect to " + selectedSSID
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        Column {
            spacing: 10
            padding: 20

            TextField {
                id: passField
                width: 250
                placeholderText: "Password"
                echoMode: TextInput.Password
            }
        }

        onAccepted: wifiHandler.connectToWifi(selectedSSID, passField.text)
    }
}
