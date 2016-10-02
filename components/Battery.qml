import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Rectangle {
    id: battery
    width: 200
    height: 30
    property int percent: 50
    Text {
        id: label
        text: "バッテリ："
        width: contentWidth // contentWidthはtextの横幅
    }
    ProgressBar {
        value: percent * 0.01
        anchors.left: label.right
        width: parent.width - label.width
    }
}
