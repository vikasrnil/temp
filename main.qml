ApplicationWindow {
    visible: true
    width: 800
    height: 400
    title: "WiFi Manager"

    property string selectedSSID: ""
    property bool wifiConnected: wifiHandler.isConnected()
    property string wifiIpAddress: wifiHandler.getIpAddress()
    property bool wifiOn: true
    property bool showWifiList: false
    property string connectedSSID: ""  // New property to store the connected SSID

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            wifiConnected = wifiHandler.isConnected()
            wifiIpAddress = wifiHandler.getIpAddress()
            connectedSSID = wifiHandler.getConnectedSSID()  // Get the connected SSID
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10
        padding: 20

        // Title
        Text {
            text: "WiFi Manager"
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1976d2"
        }

        // WiFi status icon and text
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                width: 18
                height: 18
                radius: 9
                visible: wifiOn
                color: wifiConnected ? "#2ecc71" : "#e74c3c"
                border.width: 1
                border.color: "#555"
            }

            Text {
                text: wifiOn ?
                          (wifiConnected ? "Connected to " + connectedSSID + ", IP: " + wifiIpAddress : "Disconnected")
                        : "WiFi Off"
                font.pixelSize: 16
                color: wifiConnected ? "green" : "red"
            }
        }

        // WiFi ON/OFF Switch
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Text { text: "WiFi:"; font.pixelSize: 18 }

            Switch {
                id: wifiSwitch
                checked: wifiOn
                onToggled: {
                    wifiOn = checked
                    wifiHandler.wifiOnOff(checked)
                    if (!checked) {
                        // Optionally clear WiFi list when WiFi is turned off
                        showWifiList = false
                    }
                }
            }
        }

        // Show/Hide WiFi List Button
        Button {
            id: toggleButton
            width: 250
            height: 42
            anchors.horizontalCenter: parent.horizontalCenter
            text: showWifiList ? "Hide WiFi List" : "Show WiFi List"
            background: Rectangle {
                color: showWifiList ? "#e74c3c" : "#4caf50"
                radius: 22
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                showWifiList = !showWifiList
                if (showWifiList) {
                    wifiListView.model = wifiHandler.scanWifi()
                }
            }
        }

        // WiFi List (visible only when showWifiList is true)
        Rectangle {
            width: parent.width - 40
            height: showWifiList ? 140 : 0
            color: "#ffffff"
            radius: 12
            border.color: "#cccccc"
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            visible: showWifiList
            Behavior on height { NumberAnimation { duration: 200 } }

            ListView {
                id: wifiListView
                width: parent.width
                height: parent.height
                clip: true
                spacing: 4
                anchors.centerIn: parent  // Center the ListView in the parent container

                model: ListModel {}

                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    radius: 8
                    color: "#f7f7f7"
                    border.color: "#ddd"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter  // Center the delegate

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: model.name
                            font.pixelSize: 14
                            color: "#333"
                            elide: Text.ElideNone
                            wrapMode: Text.Wrap
                            width: parent.width * 0.8
                            anchors.centerIn: parent  // Center the text within the delegate
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: model.name === connectedSSID ? "#2ecc71" : "transparent"  // Green if connected, transparent otherwise
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedSSID = model.name
                            passField.text = ""
                            pwdPopup.open()
                        }
                    }
                }

                // Receive the Wi-Fi list from the handler
                Component.onCompleted: {
                    wifiHandler.wifiScanCompleted.connect(function(wifiList) {
                        wifiListView.model.clear()
                        wifiList.forEach(function(ssid) {
                            wifiListView.model.append({name: ssid});
                        });
                    });
                }
            }
        }
    }

    // Password popup
Dialog {
    id: pwdPopup
    modal: true
    title: "Connect to " + selectedSSID
    standardButtons: Dialog.Ok | Dialog.Cancel

    Column {
        spacing: 10
        padding: 20

        TextField {
            id: passField
            width: 260
            placeholderText: "Password"
            echoMode: TextInput.Password
            font.pixelSize: 16
        }
    }

    onAccepted: {
        wifiHandler.connectToWifi(selectedSSID, passField.text)
        pwdPopup.visible = false  // Close the dialog when the user clicks "Ok"
    }

    onRejected: {
        pwdPopup.visible = false  // Optionally hide the dialog if the user clicks "Cancel"
    }
}

}

