import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: farmListPage

    signal backPressed()
    signal addNewFarm()
    signal farmSelected(string name, string jsonData)

    // holds QStringList from farmBackend.listFarms()
    property var farmsModel: []

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"
    }

    /* ---------------- TOP BAR ---------------- */
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
                text: "Farms"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
            }
        }
    }

    /* ---------------- MAIN PANEL ---------------- */
    Rectangle {
        anchors {
            top: parent.top; topMargin: 55
            left: parent.left; right: parent.right
            bottom: parent.bottom; margins: 20
        }

        radius: 12
        color: "#2A2A2A"
        border.color: "#444"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Your Saved Farms"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 3 per row; matches tractor/implement pages
                cellWidth: 200
                cellHeight: 220
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: true
                flow: GridView.FlowLeftToRight

                // +1 → first card is "Add New Farm"
                model: farmsModel.length + 1

                delegate: Rectangle {
                    width: 180
                    height: 200
                    radius: 12
                    border.color: "#00C7CC"
                    border.width: 2
                    color: "#1E1E1E"

                    // first card is the Add New card
                    property bool isAddCard: (index === 0)

                    // For actual farm cards, pick name from farmsModel[index - 1]
                    property string farmName: isAddCard || (index - 1) >= farmsModel.length
                                              ? ""
                                              : farmsModel[index - 1]

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        /* ---------- ADD NEW FARM CARD ---------- */
                        Item {
                            visible: isAddCard
                            width: 140
                            height: 140

                            MouseArea {
                                anchors.fill: parent
                                onClicked: addNewFarm()
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 10

                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 8
                                    color: "#00C7CC22"

                                    Text {
                                        text: "+"
                                        anchors.centerIn: parent
                                        font.pixelSize: 32
                                        color: "#00C7CC"
                                        font.bold: true
                                    }
                                }

                                Text {
                                    text: "Add New"
                                    color: "white"
                                    font.pixelSize: 14
                                }
                            }
                        }

                        /* ---------- SAVED FARM CARDS ---------- */
                        Item {
                            visible: !isAddCard
                            width: 180
                            height: 200

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                // mini farm preview
                                Canvas {
                                    width: 150
                                    height: 100
                                    antialiasing: true

                                    // load this farm's polygon from backend
                                    property var points: {
                                        var json = farmBackend.loadFarm(farmName)
                                        if (!json || json === "")
                                            return []
                                        return JSON.parse(json)
                                    }

				onPaint: {
				    var ctx = getContext("2d")
				    ctx.clearRect(0, 0, width, height)

				    if (!points || points.length < 3)
					return

				    ctx.strokeStyle = "#00C7CC"
				    ctx.lineWidth = 2
				    ctx.beginPath()

				    var lats = points.map(p => p[0])
				    var lngs = points.map(p => p[1])

				    var minLat = Math.min.apply(Math, lats)
				    var maxLat = Math.max.apply(Math, lats)
				    var minLng = Math.min.apply(Math, lngs)
				    var maxLng = Math.max.apply(Math, lngs)

				    var padding = 10
				    var scaleX = (width - padding * 2) / (maxLng - minLng)
				    var scaleY = (height - padding * 2) / (maxLat - minLat)
				    var scale = Math.min(scaleX, scaleY)

				    for (var i = 0; i < points.length; ++i) {
					var p = points[i]
					var x = padding + (p[1] - minLng) * scale
					var y = height - padding - (p[0] - minLat) * scale

					if (i === 0)
					    ctx.moveTo(x, y)
					else
					    ctx.lineTo(x, y)
				    }

				    // 👇 CLOSE POLYGON
				    var first = points[0]
				    var fx = padding + (first[1] - minLng) * scale
				    var fy = height - padding - (first[0] - minLat) * scale
				    ctx.lineTo(fx, fy)

				    ctx.stroke()
				}


                                    Component.onCompleted: requestPaint()
                                }

                                Text {
                                    text: farmName
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    width: 150
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Row {
                                    spacing: 8
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Button {
                                        text: "Open"
                                        width: 70
                                        height: 28
                                        background: Rectangle { color: "#00C7CC"; radius: 6 }
                                        onClicked: {
                                            farmListPage.farmSelected(farmName, farmBackend.loadFarm(farmName))
                                        }
                                    }


                                    Button {
                                        text: "Del"
                                        width: 50
                                        height: 28
                                        background: Rectangle { color: "#CC3333"; radius: 6 }
                                        onClicked: {
                                            farmBackend.deleteFarm(farmName)
                                            farmsModel = farmBackend.listFarms()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /* ---------- LIVE REFRESH FROM BACKEND ---------- */
    Connections {
        target: farmBackend

        onFarmSaved: {
            farmsModel = farmBackend.listFarms()
        }

        onFarmDeleted: {
            farmsModel = farmBackend.listFarms()
        }
    }

    Component.onCompleted: {
        farmsModel = farmBackend.listFarms()
    }
}
