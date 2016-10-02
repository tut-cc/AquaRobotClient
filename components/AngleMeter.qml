// 角度（傾き）メーター
import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item{
    id: angleMeter
    width: 300
    height: 300

    property double value: 0.0 // メーターが指し示す値
    property double minimumValueAngle: -270.0 // 最小値を表示する位置
    property double maximumValueAngle: 90.0 // 最大値を表示する位置
    property string label: "Angle Meter" // メーター中央部に表示されるテキスト

    CircularGauge {
        id: circularGauge
        anchors.fill: parent
        minimumValue: -180
        maximumValue: 180
        value: angleMeter.value
        style: CircularGaugeStyle { // スタイル設定
            needle: Item { // 針
                implicitWidth: outerRadius * 0.1 // outerRadiusはゲージの中心から外縁部までの距離
                implicitHeight: outerRadius * 1.5
                y: outerRadius * 1.5 / 2
                antialiasing: true
                Image {
                    anchors.fill: parent
                    source: "needle.png"
                }
            }
            background: Item{
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                }
                Text{
                    id:label
                    x: parent.width / 2 - width / 2
                    y: parent.height / 3 - height
                    text: angleMeter.label
                    color: "grey"
                    font.pixelSize: parent.width / 10
                }
                Text {
                    id: unitLabel
                    x: parent.width / 2 - width / 2
                    y: parent.height / 3 * 2
                    text: "[deg/s]"
                    color: "grey"
                    font.pixelSize: parent.width / 12
                }
            }
            tickmarkLabel: Text { // 刻みのラベル
                font.pixelSize: Math.max(6, outerRadius * 0.1)
                text: styleData.value // styleData.valueはラベルの値
                color: "white"
                visible: styleData.value !== -180.0 ? true : false // 180と-180が同じ位置に来るので、-180を非表示
                antialiasing: true
            }
            minimumValueAngle: angleMeter.minimumValueAngle // 最小値の位置
            maximumValueAngle: angleMeter.maximumValueAngle // 最大値の位置
            labelStepSize: 30 // ラベルを付ける値の間隔
            tickmarkStepSize: 30 // 目盛りを付ける値の間隔
            minorTickmarkCount: 2 // 目盛り間に設置する小目盛りの数
        }
    }
}

