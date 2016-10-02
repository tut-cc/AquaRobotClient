import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Rectangle {
    id: batteryMeter
    width: 200
    height: 30
    color: "black"

    property int percent: 50

    Text {
        id: label
        text: "バッテリ："
        width: contentWidth // contentWidthはtextの横幅
        height: parent.height
        color: "white"
        font.pixelSize: height
    }
    ProgressBar {
        value: percent * 0.01
        anchors.left: label.right
        width: parent.width - label.width
        height: parent.height
    }
}
