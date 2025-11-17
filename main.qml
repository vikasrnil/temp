import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    width: 480
    height: 700
    color: "#f0f2f5"

    WifiHandler {
        id: wifi
        onConnectionStatusChanged: {
            statusText.text = connected ? "Connected" : "Disconnected"
            statusIcon.color = connected ? "green" : "red"
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Row {
            spacing: 10
            Text { text: "Status:"; font.pixelSize: 20 }

            Rectangle {
                id: statusIcon
                width: 20; height: 20
                radius: 10
                color: "red"
            }

            Text {
                id: statusText
                text: wifi.connected ? "Connected" : "Disconnected"
                font.pixelSize: 20
            }
        }

        // WiFi ON / OFF BUTTON
        Button {
            id: wifiToggle
            text: "WiFi ON / OFF"
            onClicked: {
                wifi.wifiOnOff(!wifi.connected)
            }
        }

        // SHOW / HIDE WiFi LIST BUTTON
        Button {
            id: listToggle
            text: wifiList.visible ? "Hide WiFi List" : "Show WiFi List"
            onClicked: {
                wifiList.visible = !wifiList.visible
                if (wifiList.visible)
                    wifiListModel = wifi.scanWifi()
            }
        }

        // LIST MODEL
        property var wifiListModel: []

        // WIFI LIST VIEW
        ListView {
            id: wifiList
            visible: false
            width: 350
            height: 250
            clip: true

            model: wifiListModel

            delegate: Rectangle {
                width: parent.width
                height: 40
                color: "#ffffff"
                border.color: "#cccccc"
                Text {
                    anchors.centerIn: parent
                    text: modelData
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        popupSsid.text = modelData
                        passwordPopup.open()
                    }
                }
            }
        }
    }

    // PASSWORD POPUP
    Popup {
        id: passwordPopup
        modal: true
        width: 300
        height: 200
        focus: true

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                id: popupSsid
                text: ""
                font.pixelSize: 20
            }

            TextField {
                id: passwordField
                width: 200
                placeholderText: "Password"
                echoMode: TextInput.Password
            }

            Button {
                text: "Connect"
                onClicked: {
                    if (wifi.connectToWifi(popupSsid.text, passwordField.text)) {
                        passwordPopup.close()
                        listToggle.text = "Show WiFi List"
                        wifiList.visible = false
                    }
                }
            }

            Button {
                text: "Cancel"
                onClicked: passwordPopup.close()
            }
        }
    }
}
