// 角速度メーター
import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4


CircularGauge{
    id: vMeter
    width: 300
    height: 300
    minimumValue: -90.0
    maximumValue: 90.0

    property string label: "AngularVelocity"
    property string unitLabel: "[deg/s]"

    style: CircularGaugeStyle { // スタイル設定
        background: Item{
            Rectangle {
                anchors.fill: parent
                color: "black"
            }
            Text{
                id:label
                x: parent.width / 2 - width / 2
                y: parent.height / 3 - height
                text: vMeter.label
                color: "grey"
                font.pixelSize: parent.width / 10
            }
            Text{
                id: unitLabel
                x: parent.width / 2 - width / 2
                y: parent.height / 3 * 2
                text: vMeter.unitLabel
                color: "grey"
                font.pixelSize: parent.width / 12
            }
        }
        labelStepSize: 30 // 値のラベルを30度刻みに
        minorTickmarkCount: 2
        tickmarkStepSize: 30
    }
}
