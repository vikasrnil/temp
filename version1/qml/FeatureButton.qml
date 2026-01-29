import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: card
    width: 120
    height: 120
    radius: 10
    color: "transparent"
    border.color: "#00C7CC"
    border.width: 3

    property alias title: label.text
    property string iconPath: ""


    signal clicked()

    Column {
        anchors.centerIn: parent
        spacing: 6

        Image {
            source: iconPath
            width: 50
            height: 50
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: label
            text: ""
            font.pixelSize: 14
            font.bold: true
            color: "#FFFFFF"
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            card.clicked()
            console.log(title + " clicked!")   // (optional)
        }
        hoverEnabled: true
        onEntered: card.opacity = 0.8
        onExited: card.opacity = 1.0
    }
}
