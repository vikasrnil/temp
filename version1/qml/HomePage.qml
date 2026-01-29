import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: home
    anchors.fill: parent

    signal tractorClicked()
    signal implementClicked()
    signal farmLandClicked()
    signal pathClicked()
    signal settingsClicked()

    Rectangle {
        anchors.fill: parent
        color: "#222222"
        radius: 10

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: "Home"
                font.pixelSize: 18
                font.bold: true
                color: "#FFFFFF"
            }

            Rectangle {
                width: parent.width
                height: parent.height - 60
                color: "#2A2A2A"
                radius: 12
                border.color: "#444"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 25

                    Text {
                        text: "Start building your path"
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        FeatureButton {
                            title: "Tractor"
                            iconPath: "/images/tractor.png"
                            onClicked: home.tractorClicked()
                            
                        }

                        FeatureButton {
                            title: "Implement"
                            iconPath: "/images/implement.png"
                            onClicked: home.implementClicked()
                           
                        }

                        FeatureButton {
                            title: "Farm Land"
                            iconPath: "/images/Farmland.png"
                             onClicked: home.farmLandClicked()
                            
                        }

                        FeatureButton {
                            title: "Path"
                            iconPath: "/images/Path.png"
                            onClicked: home.pathClicked()
                           
                        }

                        FeatureButton {
                            title: "Settings"
                            iconPath: "/images/Settings.png"
                             onClicked: home.settingsClicked()
                            
                        }
                    }
                }
            }
        }
    }
}

