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
    width: 1024
    height: 700
    color: "black"

    property int webSocketPort: 8080 // デフォルトのwebSocketポート
    property int cameraPort: 8081    // デフォルトの動画ストリーミングポート
    property string serverHost: "192.168.1.1" // サーバのホスト

    Item{ // 水中ロボット接続ダイアログ
        anchors.fill: parent
        id: connectDialog
        z: 10 // アイテムどうしが重なっている場合、値が大きいものが上に表示される デフォルトは0なのでこれが一番上のアイテムとして表示される
        Rectangle{ // ウィンドウ全体に半透明の黒い覆いをかける
            anchors.fill: parent
            color: "black"
            opacity: 0.7 // 半透明
        }
        Rectangle{
            anchors.centerIn: parent
            color: "white"
            width: 400
            height: 200
            radius: 10
            Column{
                Text{
                    text: "水中ロボットと接続"
                    font.pixelSize: 30
                }

                Grid{
                    columns: 2 // 一行に表示するアイテム数
                    Text{
                        text: "ホスト名："
                        font.pixelSize: 20
                    }
                    TextField{
                        id: hostInput
                        text: serverHost
                        height: 20
                    }
                    Text{
                        text: "カメラポート："
                        font.pixelSize: 20
                    }
                    TextField{
                        id: cameraPortInput
                        text: cameraPort
                        height: 20
                    }
                    Text{
                        text: "WebSocketポート："
                        font.pixelSize: 20
                    }
                    TextField{
                        id: wsPortInput
                        text: webSocketPort
                        height: 20
                    }
                }
                Row{
                    Button{
                        text: "接続"
                        onClicked: {
                            connectDialog.visible = false
                            AquaRobot.open(hostInput.text, wsPortInput.text)
                            cameraStream.host = hostInput.text
                            cameraStream.port = cameraPortInput.text
                        }
                    }
                    Button{
                        text: "キャンセル"
                        onClicked: {
                            connectDialog.visible = false
                        }
                    }
                }
            }
        }
    }

    Item{ // 左
        id: leftPane
        width: (parent.width - centralPane.width) / 2
        height: parent.height
        anchors.top: parent.top
        anchors.left: parent.left

        AngularVelocityMeter{ // x軸角加速度
            id: avxMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            label: "avx"
            value: AquaRobot.avx
        }

        AngularVelocityMeter{ // y軸角加速度
            id: avyMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label: "avy"
            value: AquaRobot.avy
        }

        AngularVelocityMeter{ // z軸角加速度
            id: avzMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            label: "avz"
            value: AquaRobot.avz
        }
    }

    Item{ // 中央
        id: centralPane
        width: cameraStream.width
        height: parent.height
        anchors.left: leftPane.right
        anchors.top: parent.top

        Item{ // カメラからの動画を表示するアイテム
            id: cameraStream
            width: 600
            height: 480
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            property string host: ""
            property int port: 0

            WebEngineView{ // webブラウザでmjpg_streamerからの動画を表示
                url: "http://" + parent.host + ":" + parent.port + "/stream_simple.html"
                anchors.fill: parent // 親と同じサイズ・位置を持つ
            }
        }

        Item{ // 通信、バッテリなどの状態を表示するバー
            id: statusBar
            width: parent.width
            height: 20
            anchors.top: cameraStream.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle{ // 接続状態の表示
                id: connectStatus
                width: parent.width / 3
                height: parent.height - 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 2 // マージン（余白）
                color: "black"

                Row{
                    Image{
                        width: connectStatus.height;
                        height: connectStatus.height;
                        source: AquaRobot.isConnected ? "components/ok.png" : "components/error.png"
                    }

                    Text{
                       // anchors.left: parent.left
                        //anchors.verticalCenter: parent.verticalCenter
                        text: AquaRobot.host + ":" + AquaRobot.port + " "
                        color: "white"
                        font.pixelSize: connectStatus.height
                    }

                    Button{
                        text: "再接続"
                        onClicked: {
                            connectDialog.visible = true
                            AquaRobot.close()
                        }
                        height: connectStatus.height
                        visible: !(AquaRobot.isConnected)
                    }
                }
            }
            BatteryMeter{
                id: batteryMeter
                width: parent.width / 3
                height: parent.height - 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: connectStatus.right
                anchors.margins: 2
                percent: AquaRobot.battery
            }
            Rectangle{
                id: emergencyModeState
                width: parent.width / 3
                height: parent.height - 4
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
            width: parent.width
            height: parent.height - (cameraStream.height + statusBar.height)
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
            // スティックを触っていなくてもある程度の値が検出されてしまうので、絶対値が閾値以下は0とする
            gamepad.onAxisLeftYChanged: AquaRobot.vxOrder = (value < 0.20 && value > -0.20) ? 0 : (value * -5.0)
            gamepad.onAxisRightXChanged: AquaRobot.avyOrder = (value < 0.20 && value > -0.20) ? 0 : value * 50
        }
    }

    Item{ // 右
        id: rightPane
        width: (parent.width - centralPane.width) / 2
        height: parent.height
        anchors.left: centralPane.right
        anchors.top: parent.top

        AccelerationMeter{ // x軸加速度
            id: axMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            label: "ax" // メーター中央部に表示されるテキスト
            value: AquaRobot.ax // ここで指定された値がメーターで示される
        }

        AccelerationMeter{ // y軸加速度
            id: ayMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label: "ay"
            value: AquaRobot.ay
        }

        AccelerationMeter{ // z軸加速度
            id: azMeter
            width: parent.width < parent.height / 3 ? parent.width : parent.height / 3
            height: width
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            label: "az"
            value: AquaRobot.az
        }
    }
}
