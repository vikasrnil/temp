// GeneratePathPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9

Page {
    id: generatePathPage
    width: 760
    height: 440

    signal backPressed()
    signal generateRequested(string farmName,
                             string farmJson,
                             var tractorData,
                             var implementData)

    // Models
    property var farmsModel: []
    property var tractorsModel: []
    property var implementsModel: []

    Rectangle { anchors.fill: parent; color: "#1E1E1E" }

    Row {
        height: 40
        anchors.left: parent.left
        anchors.right: parent.right

        Button { text: "<"; width: 40; onClicked: backPressed() }

        Text {
            text: "Generate Path"
            color: "white"
            font.pixelSize: 18
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    RowLayout {
        anchors {
            top: parent.top
            topMargin: 50
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }
        spacing: 12

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

        Rectangle {
            width: 270
            Layout.fillHeight: true
            radius: 12
            color: "#2A2A2A"
            border.color: "#3D3D3D"

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Text { text: "Farm Area"; color: "#ccc"; font.pixelSize: 14 }

                ComboBox {
                    id: farmBox
                    width: parent.width
                    model: farmsModel
                    Layout.fillWidth: true

                    onCurrentIndexChanged: {
                        if (currentIndex < 0) return
                        var fname = currentText
                        var json = farmBackend.loadFarm(fname)
                        web.runJavaScript("loadSavedFarm(" + json + ")")
                    }
                }

                Text { text: "Vehicle"; color: "#ccc"; font.pixelSize: 14 }

                ComboBox {
                    id: tractorBox
                    width: parent.width
                    model: tractorsModel
                    textRole: "name"
                    Layout.fillWidth: true
                }

                Text { text: "Implement"; color: "#ccc"; font.pixelSize: 14 }

                ComboBox {
                    id: implementBox
                    width: parent.width
                    model: implementsModel
                    textRole: "name"
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    width: parent.width
                    height: 46
                    radius: 6
                    color: "#00C7CC"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (farmBox.currentIndex < 0 ||
                                tractorBox.currentIndex < 0 ||
                                implementBox.currentIndex < 0) return

                            var fname = farmBox.currentText
                            var fjson = farmBackend.loadFarm(fname)
                            var tractor = tractorsModel[tractorBox.currentIndex]
                            var impl = implementsModel[implementBox.currentIndex]

                            generatePathPage.generateRequested(fname, fjson, tractor, impl)
                        }
                    }

                    Text {
                        text: "Generate Path"
                        anchors.centerIn: parent
                        color: "white"
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

    /* 🔄 REAL-TIME DATA UPDATES */
    Connections {
        target: farmBackend
        onFarmSaved:      farmsModel = farmBackend.listFarms()
        onFarmDeleted:    farmsModel = farmBackend.listFarms()
    }

    Connections {
        target: operations
        onTractorSaved:     tractorsModel = operations.loadAllTractors()
        onTractorDeleted:   tractorsModel = operations.loadAllTractors()
    }

    Connections {
        target: implementBackend
        onImplementSaved:   implementsModel = implementBackend.loadAllImplements()
        onImplementDeleted: implementsModel = implementBackend.loadAllImplements()
    }

    Component.onCompleted: {
        farmsModel = farmBackend.listFarms()
        tractorsModel = operations.loadAllTractors()
        implementsModel = implementBackend.loadAllImplements()
    }
}
