import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 450
    title: "WiFi Manager"

    property bool wifiOn: wifi.wifiOn
    property bool wifiConnected: false
    property string connectedSSID: ""
    property string ipAddr: ""
    property bool showWifiList: false
    property string selectedSSID: ""

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            wifiConnected = wifi.connected
            connectedSSID = wifi.getConnectedSSID()
            ipAddr = wifi.getIpAddress()
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12
        padding: 20

        // Title
        Text {
            text: "WiFi Manager"
            font.pixelSize: 30
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // WiFi status
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: 16
                height: 16
                radius: 8
                color: !wifiOn ? "gray" : (wifiConnected ? "green" : "red")
            }

            Text {
                text: !wifiOn
                      ? "WiFi Off"
                      : (wifiConnected ? "Connected to " + connectedSSID + " (" + ipAddr + ")" : "Disconnected")
                color: wifiConnected ? "green" : "red"
            }
        }

        // WiFi toggle
        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Text { text: "WiFi:" }

            Switch {
                checked: wifiOn
                onToggled: {
                    wifiOn = checked
                    wifi.wifiOn = checked
                    if (!checked) showWifiList = false
                }
            }
        }

        // Show WiFi list button
        Button {
            text: showWifiList ? "Hide WiFi List" : "Show WiFi List"
            width: 240
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                showWifiList = !showWifiList
                if (showWifiList) wifi.scanWifi()
            }
        }

        // WiFi list view
        Rectangle {
            width: parent.width - 40
            height: showWifiList ? 180 : 0
            Behavior on height { NumberAnimation { duration: 150 } }
            color: "white"
            radius: 10
            border.color: "#ccc"
            visible: showWifiList
            clip: true

            ListView {
                id: wifiListView
                anchors.fill: parent
                model: ListModel {}

                delegate: Rectangle {
                    width: parent.width
                    height: 44
                    color: "#f5f5f5"
                    border.color: "#ccc"
                    radius: 6

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text { text: name; width: parent.width * 0.8 }

                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: name === connectedSSID ? "green" : "transparent"
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
        modal: true
        title: "Connect to " + selectedSSID
        standardButtons: Dialog.Ok | Dialog.Cancel

        Column {
            spacing: 10; padding: 20

            TextField {
                id: passField
                placeholderText: "Password"
                echoMode: TextInput.Password
                width: 240
            }
        }

        onAccepted: {
            wifi.connectToWifi(selectedSSID, passField.text)
        }
    }

    // Handle scan results
    Connections {
        target: wifi
        onWifiScanCompleted: {
            wifiListView.model.clear()
            for (var i = 0; i < wifiList.length; i++)
                wifiListView.model.append({ name: wifiList[i] })
        }
    }
}
