import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9
import QtQuick.VirtualKeyboard 2.1
import QtGraphicalEffects 1.0

Page {
    id: tracePage
    width: 760
    height: 440

    signal backPressed()
    signal farmTracedSaved(string name, string jsonData)

    // Backend values
    property real currentSpeed: 0.0
    property real currentHeading: 0.0
    property bool recording: false
    property var recordedJson: ""

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    // ---------------- TOP BAR ----------------
    Row {
        height: 40
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 10

        Button {
            text: "<"
            width: 40
            onClicked: backPressed()
        }

        Text {
            text: "Trace Farm"
            color: "white"
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ---------------- MAIN LAYOUT ----------------
    RowLayout {
        anchors {
            top: parent.top
            topMargin: 50
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 10
            margins: 10
        }
        spacing: 10

        // LEFT: MAP
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "black"
            border.color: "#333"

            WebEngineView {
                id: webView
                anchors.fill: parent
                url: "qrc:map.html"
                settings.localContentCanAccessRemoteUrls: true
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                spacing: 10
                height: 48

                Rectangle {
                    width: 110; height: parent.height
                    radius: 6; color: "#00C7CC"
                    Text { anchors.centerIn: parent; text:"Start"; color:"white"; font.pixelSize:16 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            recording = true
                            webView.runJavaScript("startRecording && startRecording()")
                        }
                    }
                }

                Rectangle {
                    width: 110; height: parent.height
                    radius: 6; color: "transparent"
                    border.color:"#00C7CC"; border.width:2
                    Text { anchors.centerIn: parent; text:"Stop"; color:"#00C7CC"; font.pixelSize:16 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            recording = false
                            webView.runJavaScript("stopRecording && stopRecording()")
                            saveDialog.open()
                        }
                    }
                }

                Rectangle {
                    width: 110; height: parent.height
                    radius: 6; color: "#00C7CC"
                    Text { anchors.centerIn: parent; text:"Save"; color:"white"; font.pixelSize:16 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            webView.runJavaScript("saveFarm()", function(json){
                                recordedJson = json
                                saveDialog.open()
                            })
                        }
                    }
                }
            }
        }

        // ---------------- RIGHT PANEL (ONE CARD) ----------------
        Rectangle {
            width: 320
            Layout.fillHeight: true
            radius: 16
            color: "#262626"
            border.color: "#333"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // ------------- SPEEDOMETER (scaled) ----------------
                Item {
                    id: speedContainer
                    width: 360 * 0.45
                    height: 360 * 0.45
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        id: speedWrapper
                        width: 360
                        height: 360
                        anchors.centerIn: parent

                        transform: Scale {
                            xScale: 0.45
                            yScale: 0.45
                            origin.x: speedWrapper.width/2
                            origin.y: speedWrapper.height/2
                        }

                        // === YOUR ORIGINAL SPEEDOMETER CODE (UNCHANGED) ===
                        Item {
                            id: speedometer
                            width: 360
                            height: 360

                            property int speed: currentSpeed
                            property int maxSpeed: 45

                            readonly property real startAngle: Math.PI * 0.75
                            readonly property real endAngle: Math.PI * 2.25

                            Canvas {
                                id: dialCanvas
                                anchors.fill: parent
                                onPaint: {
                                    const ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);

                                    const cx = width / 2;
                                    const cy = height / 2;
                                    const radius = Math.min(width, height) / 2 - 30;

                                    ctx.lineWidth = 16;
                                    ctx.strokeStyle = "#222";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, radius, startAngle, endAngle);
                                    ctx.stroke();

                                    const grad = ctx.createLinearGradient(0, 0, width, 0);
                                    grad.addColorStop(0, "#00ffff");
                                    grad.addColorStop(0.5, "#00ff66");
                                    grad.addColorStop(1, "#ffff00");
                                    ctx.strokeStyle = grad;
                                    ctx.lineWidth = 18;

                                    const clamped = Math.min(speed, maxSpeed);
                                    const angle = startAngle + (clamped / maxSpeed) * (endAngle - startAngle);
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, radius, startAngle, angle);
                                    ctx.stroke();
                                }

                                Connections {
                                    target: speedometer
                                    onSpeedChanged: dialCanvas.requestPaint()
                                }
                            }

                            Rectangle {
                                width: 4
                                height: height / 2.2
                                radius: 2
                                color: "#ff0055"
                                anchors.centerIn: parent
                                transform: Rotation {
                                    origin.x: 2
                                    origin.y: speedometer.height / 2.2
                                    angle: (Math.min(speedometer.speed, speedometer.maxSpeed) / speedometer.maxSpeed) * 270
                                    Behavior on angle { NumberAnimation { duration: 300 } }
                                }
                            }

                            Rectangle {
                                width: 60
                                height: 60
                                radius: 30
                                anchors.centerIn: parent
                                color: "#111"
                                border.color: "#00ffcc"
                                border.width: 3

                                Text {
                                    text: speedometer.speed + " km/h"
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pixelSize: 20
                                    font.bold: true
                                }
                            }

                            Text {
                                text: "D"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#00ffcc"
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 20
                            }
                        }
                    }
                }

                // ------------- HEADING INDICATOR (scaled) ----------------
                Item {
                    id: headingContainer
                    width: 320 * 0.55
                    height: 320 * 0.55
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        id: headingWrapper
                        width: 320
                        height: 320
                        anchors.centerIn: parent

                        transform: Scale {
                            xScale: 0.55
                            yScale: 0.55
                            origin.x: headingWrapper.width/2
                            origin.y: headingWrapper.height/2
                        }

                        // === YOUR ORIGINAL HEADING INDICATOR CODE (UNCHANGED) ===
                        Item {
                            id: headingIndicator
                            width: 320
                            height: 320
                            property real heading: currentHeading

                            Rectangle {
                                anchors.fill: parent
                                color: "#2c2c2c"
                                radius: 20

                                Canvas {
                                    id: compass
                                    anchors.centerIn: parent
                                    width: 300
                                    height: 300
                                    antialiasing: true

                                    onPaint: {
                                        const ctx = getContext("2d");
                                        const cx = width / 2;
                                        const cy = height / 2;
                                        const radius = Math.min(width, height) / 2 - 20;

                                        ctx.clearRect(0, 0, width, height);

                                        ctx.beginPath();
                                        ctx.arc(cx, cy, radius, 0, 2*Math.PI);
                                        ctx.lineWidth = 3;
                                        ctx.strokeStyle = "#CCCCCC";
                                        ctx.stroke();

                                        for (let i = 0; i < 360; i += 30) {
                                            const angle = i * Math.PI / 180;
                                            const innerR = (i % 90 === 0) ? radius - 15 : radius - 10;

                                            ctx.beginPath();
                                            ctx.moveTo(cx + Math.sin(angle) * innerR,
                                                       cy - Math.cos(angle) * innerR);
                                            ctx.lineTo(cx + Math.sin(angle) * radius,
                                                       cy - Math.cos(angle) * radius);
                                            ctx.strokeStyle = "#AAAAAA";
                                            ctx.lineWidth = 1;
                                            ctx.stroke();

                                            let label = "";
                                            if (i===0) label="N";
                                            else if (i===90) label="E";
                                            else if (i===180) label="S";
                                            else if (i===270) label="W";

                                            if (label) {
                                                ctx.font = "bold 14px sans-serif";
                                                ctx.fillStyle = "white";
                                                ctx.textAlign = "center";

                                                ctx.fillText(label,
                                                    cx + Math.sin(angle)*(radius-30),
                                                    cy - Math.cos(angle)*(radius-30));
                                            }
                                        }

                                        const angle = headingIndicator.heading * Math.PI/180;
                                        ctx.beginPath();
                                        ctx.moveTo(cx, cy);
                                        ctx.lineTo(
                                            cx + Math.sin(angle)*(radius-20),
                                            cy - Math.cos(angle)*(radius-20)
                                        );
                                        ctx.strokeStyle = "red";
                                        ctx.lineWidth = 4;
                                        ctx.stroke();

                                        ctx.beginPath();
                                        ctx.arc(cx, cy, 5, 0, 2*Math.PI);
                                        ctx.fillStyle = "red";
                                        ctx.fill();

                                        ctx.font = "bold 20px sans-serif";
                                        ctx.fillStyle = "#00ffff";
                                        ctx.textAlign = "center";
                                        ctx.fillText(Math.round(headingIndicator.heading)+"°",
                                                     cx, cy+40);
                                    }

                                    Connections {
                                        target: headingIndicator
                                        onHeadingChanged: compass.requestPaint()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------- SAVE DIALOG ----------------
    Dialog {
        id: saveDialog
        title: "Save Trace"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        contentItem: Column {
            spacing: 10
            padding: 12
            TextField { id: saveName; placeholderText: "Enter farm name" }
            Text { text:"Points will be saved."; color:"#888" }
        }

        onAccepted: {
            let name = saveName.text.trim()
            if (name === "") return

            webView.runJavaScript("saveFarm()", function(json){
                farmBackend.saveFarm(name, json)
            })
        }
    }

    // ---------------- BACKEND: GPS LIVE UPDATE ----------------
    Connections {
        target: gpsDataManager
        function onDataUpdated() {
            currentSpeed = gpsDataManager.speed
            currentHeading = gpsDataManager.heading

            webView.runJavaScript("updateLatLng("
                                  + gpsDataManager.latitude + ","
                                  + gpsDataManager.longitude + ")")
        }
    }

    // ---------------- KEYBOARD ----------------
    InputPanel {
        id: keyboard
        anchors.left: parent.left
        anchors.right: parent.right
        y: parent.height - height
        visible: Qt.inputMethod.visible
    }
}
