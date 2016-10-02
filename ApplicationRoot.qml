// import 型が登録されたバージョン付きのネームスペースを読み込む javascriptやQmlがある相関ディレクトリごとimportもできる
import QtQuick.Controls 1.2 // ボタンやチェックボックスなど、基本的なUIの部品
import QtQuick 2.5 // 基本的な型など
import QtWebEngine 1.2 // webブラウザ
import QtQuick.Extras 1.4 // サークルゲージ
import "components" // 自作の部品など
import "components/gamepad"

ApplicationWindow {
    id: window
    title: "水中ロボット：コントローラ"
    visible: true // ApplicationWindowは標準では非表示状態になっている
    width: 1200
    height: 900

    Item{ // 左
        id: leftPane
        width: 300
        height: 900
        anchors.top: parent.top
        anchors.left: parent.left

        VelocityMeter{ // vxメーター
            id: vxMeter
            width: 300
            height: 300
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            label: "vx"
            value: AquaRobot.vx
        }

        VelocityMeter{ // vzメーター
            id: vzMeter
            width: 300
            height: 300
            anchors.top: vxMeter.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            label: "vz"
            value: AquaRobot.vz
        }

        AngularVelocityMeter{
            id: avyMeter
            width: 300
            height: 300
            anchors.top: vzMeter.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            label: "avy"
            value: AquaRobot.avy
        }
    }

    Item{ // 中央
        id: centralPane
        width: 600
        height: 900
        anchors.left: leftPane.right
        anchors.top: parent.top

        Item{ // カメラからの動画を表示するアイテム
            id: cameraStream
            width: 600
            height: 480
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            WebEngineView{ // webブラウザでmjpg_streamerからの動画を表示
                url: "http://www.tut.ac.jp/" // 本当はraspiからのストリーミングアドレスにするべき
                anchors.fill: parent // 親と同じサイズ・位置を持つ
            }
        }

        Item{ // 通信、バッテリなどの状態を表示するバー
            id: statusBar
            width: 600
            height: 20
            anchors.top: cameraStream.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle{ // 接続状態の表示
                id: connectStatus
                width: 200
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 2 // マージン（余白）
                color: "black"

                Text{
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Connection: " + AquaRobot.isConnected
                    color: "white"
                    font.pixelSize: parent.height
                }
            }
            BatteryMeter{
                id: batteryMeter
                width: 200
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: connectStatus.right
                anchors.margins: 2
                percent: AquaRobot.battery
            }
            Rectangle{
                id: emergencyModeState
                width: 200
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: batteryMeter.right
                anchors.margins: 2
                color: "black"

                Text{
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Emergency: " + AquaRobot.isEmergencyMode
                    color: "white"
                    font.pixelSize: parent.height
                }
            }
        }

        XboxController{ // ボタン割り当ての表示
            id: xboxController
            width: 600
            height: 400
            anchors.top: statusBar.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            gamepad.onButtonAChanged: {
                if(value)
                    AquaRobot.setEmergencyMode(false)
            }
            gamepad.onButtonGuideChanged: {
                if(value)
                    AquaRobot.setEmergencyMode(true)
            }
            gamepad.onButtonL1Changed: AquaRobot.vzOrder = value ? -1.0 : 0
            gamepad.onButtonR1Changed: AquaRobot.vzOrder = value ? 1.0 : 0
            gamepad.onAxisLeftYChanged: AquaRobot.vxOrder = value * -5.0
            gamepad.onAxisRightXChanged: AquaRobot.avyOrder = value * 50
        }
    }

    Item{ // 右
        id: rightPane
        width: 300
        height: 900
        anchors.left: centralPane.right
        anchors.top: parent.top

        AngleMeter{ // 角度（傾き）メーター ピッチ
            id: pitchMeter
            width: 300
            height: 300
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            minimumValueAngle: -270.0 // 最小値が表示される位置
            maximumValueAngle: 90.0 // 最大値が表示される位置
            label: "Pitch" // メーター中央部に表示されるテキスト
            value: AquaRobot.pitch // ここで指定された値がメーターで示される
        }

        AngleMeter{ // ロールメーター
            id: rollMeter
            width: 300
            height: 300
            anchors.top: pitchMeter.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            minimumValueAngle: -180.0
            maximumValueAngle: 180.0
            label: "Roll"
            value: AquaRobot.roll
        }

        AngleMeter{ // ヨーメーター
            id: yawMeter
            width: 300
            height: 300
            anchors.top: rollMeter.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            minimumValueAngle: -180.0
            maximumValueAngle: 180.0
            label: "Yaw"
            value: AquaRobot.yaw
        }
    }
}
