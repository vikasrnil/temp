import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9
import QtQuick.VirtualKeyboard 2.1

Page {
    id: plotPage
    width: 760
    height: 440

    signal backPressed()
    signal farmSaved(string name, string jsonData)

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    //-------------------------------------------------------
    // TOP BAR
    //-------------------------------------------------------
    Row {
        height: 40
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Button {
            text: "<"
            width: 40
            onClicked: backPressed()
        }

        Text {
            text: "Plot Farm"
            color: "white"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    //-------------------------------------------------------
    // REQUIRED FUNCTION TO LOAD SAVED JSON
    //-------------------------------------------------------
    function loadSavedFarm(jsonString) {

        console.log("QML → loadSavedFarm:", jsonString)

        // Escape quotes so JavaScript receives proper string
        let safeJson = JSON.stringify(jsonString)

        web.runJavaScript("loadSavedFarm(" + safeJson + ")")
    }

    //-------------------------------------------------------
    // LAYOUT
    //-------------------------------------------------------
    RowLayout {
        anchors {
            top: parent.top
            topMargin: 50
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        spacing: 12

        //---------------- MAP VIEW ----------------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "black"

            WebEngineView {
                id: web
                anchors.fill: parent
                url: "qrc:map.html"
                settings.localContentCanAccessRemoteUrls: true
            }
        }

        //---------------- CONTROL PANEL ----------------
        Rectangle {
            width: 270
            Layout.fillHeight: true
            radius: 12
            color: "#2A2A2A"
            border.color: "#3D3D3D"

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text { text: "Search Location"; color: "#cccccc"; font.pixelSize: 14 }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 6
                    border.color: "#00C7CC"
                    color: "transparent"

		Row {
		    anchors.fill: parent
		    anchors.margins: 6
		    spacing: 6

		    TextField {
			id: searchBox
			placeholderText: "Search place"
			color: "white"
			background: null
			width: parent.width - searchButton.width - 6
		    }

		    Rectangle {
			id: searchButton
			width: 38
			height: 32
			radius: 4
			color: "#00C7CC"
			anchors.verticalCenter: parent.verticalCenter

			MouseArea {
			    anchors.fill: parent
			    onClicked: web.runJavaScript("searchLocation('" + searchBox.text + "')")
			}

			Text {
			    text: "🔍"
			    anchors.centerIn: parent
			    color: "white"
			}
		    }
		}

                }

                Text { text: "Name"; color: "#cccccc"; font.pixelSize: 14 }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 6
                    border.color: "#00C7CC"
                    color: "transparent"

                    TextField {
                        id: nameBox
                        anchors.fill: parent
                        anchors.margins: 8
                        placeholderText: "Farm 1"
                        color: "white"
                        background: null
                    }
                }

                //-------------------------------------------------------
                // SAVE BUTTON
                //-------------------------------------------------------
                Rectangle {
                    width: parent.width
                    height: 45
                    radius: 6
                    color: "#00C7CC"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let fname = nameBox.text.trim()

                            if (fname === "") {
                                console.log("Farm name required")
                                return
                            }

                            web.runJavaScript("saveFarm()", function(resultJson) {
                                let ok = farmBackend.saveFarm(fname, resultJson)

                                if (ok) {
                                    console.log("Saved:", fname)
                                    plotPage.farmSaved(fname, resultJson)
                                }
                            })
                        }
                    }

                    Text {
                        text: "Save"
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                //-------------------------------------------------------
                // PLOT BUTTON
                //-------------------------------------------------------
                Rectangle {
                    width: parent.width
                    height: 45
                    radius: 6
                    color: "#00C7CC"

                    MouseArea { anchors.fill: parent; onClicked: web.runJavaScript("plotFarm()") }

                    Text {
                        text: "Plot"
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                //-------------------------------------------------------
                // CLEAR BUTTON
                //-------------------------------------------------------
                Rectangle {
                    width: parent.width
                    height: 45
                    radius: 6
                    color: "transparent"
                    border.color: "#00C7CC"
                    border.width: 2

                    MouseArea { anchors.fill: parent; onClicked: web.runJavaScript("clearAll()") }

                    Text {
                        text: "Clear"
                        anchors.centerIn: parent
                        color: "#00C7CC"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }
        }
    }
    
    	    onVisibleChanged: {
	    if (visible) {
		web.reload()
	    }
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
