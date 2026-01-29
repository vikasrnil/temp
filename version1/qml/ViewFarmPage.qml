// ViewFarmPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9

Page {
    id: viewPage
    width: 760
    height: 440

    signal backPressed()
    property string farmJson: ""

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"
    }

    /* ---------- TOP BAR ---------- */
    Rectangle {
        id: topBar
        width: parent.width
        height: 45
        color: "#111"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            anchors.left: parent.left
            anchors.leftMargin: 10

            Button {
                text: "<"
                width: 40
                onClicked: backPressed()
            }

            Text {
                text: "Farm Preview"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    /* ---------- MAP ---------- */
    WebEngineView {
        id: web
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
        }
        url: "qrc:/map_view.html"
        settings.localContentCanAccessRemoteUrls: true

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                showFarmOnMap()
            }
        }
    }

    function showFarmOnMap() {
        if (!farmJson || farmJson === "") return;

        // Safe JSON string for JS
        let safeJson = JSON.stringify(farmJson)

        // Call your map.html JS function
        web.runJavaScript("loadSavedFarmAndPlot(" + safeJson + ");")
    }

    onFarmJsonChanged: showFarmOnMap
}

