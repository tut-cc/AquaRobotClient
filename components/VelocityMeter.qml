// 速度メーター
import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item{
    id: velocityMeter
    width: 300
    height: 300

    property string label: "VelocityMeter" // メーター中央部に表示されるテキスト
    property string unitLabel: "[m/s]" // 単位
    property double value: 0.0 // メーターが指し示す値

    CircularGauge{
        id: gauge
        anchors.fill: parent
        minimumValue: -10.0
        maximumValue: 10.0
        value: velocityMeter.value

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
                    text: velocityMeter.label
                    color: "grey"
                    font.pixelSize: parent.width / 10
                }
                Text{
                    id: unitLabel
                    x: parent.width / 2 - width / 2
                    y: parent.height / 3 * 2
                    text: velocityMeter.unitLabel
                    color: "grey"
                    font.pixelSize: parent.width / 10
                }
            }
            labelStepSize: 5 // 値のラベルを30度刻みに
            tickmarkStepSize: 5 // 目盛りを表示する値の間隔
            minorTickmarkCount: 4 // 目盛り間に置く少目盛りの数
        }
    }

}

