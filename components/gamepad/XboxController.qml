/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Gamepad module
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

// qtのgamepadのサンプルから拝借
// xboxのボタン画像とかもサンプルより

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtGamepad 1.0

Item {
    id: xboxController
    visible: true
    width: 600
    height: 400

    Rectangle {
        id: background
        color: "#363330"
        anchors.fill: parent // 親と同じサイズ・位置


        ButtonImage { // Lボタン
            id: buttonL1
            width: xboxController.width / 3
            height: xboxController.height / 4
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 8
            source: "xboxControllerLeftShoulder.png"
            active: gamepad.buttonL1
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "浮上"
                font.pixelSize: 40
                style: Text.Outline
                styleColor: "white"
            }
        }


        ButtonImage { // Xboxボタン
            id: xboxButton
            width: xboxController.height / 3
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "xboxControllerButtonGuide.png"
            active: gamepad.buttonGuide
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "緊急停止"
                font.pixelSize: 40
                style: Text.Outline
                styleColor: "white"
            }
        }

        ButtonImage { // Rボタン
            id: buttonR1
            width: xboxController.width / 3
            height: xboxController.height / 4
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 8
            source: "xboxControllerRightShoulder.png"
            active: gamepad.buttonR1
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "潜水"
                font.pixelSize: 40
                style: Text.Outline
                styleColor: "white"
            }
        }

        ButtonImage {
            id: buttonA
            width: xboxController.height / 5
            height: width
            x: parent.width / 3 * 2 + width / 2
            y: parent.height / 2 - height / 2
            source: "xboxControllerButtonA.png";
            active: gamepad.buttonA
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "緊急解除"
                font.pixelSize: 20
                style: Text.Outline
                styleColor: "white"
            }
        }

        RightThumbstick {
            width: xboxController.height / 3
            height: width
            x: parent.width / 4 * 3 - width / 2
            y: parent.height - height
            id: rightThumbstick
            gamepad: xboxController.gamepad
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "旋回"
                font.pixelSize: 40
                style: Text.Outline
                styleColor: "white"
            }
        }

        LeftThumbstick { // 左スティック
            id: leftThumbstick
            width: xboxController.height / 3
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            gamepad: xboxController.gamepad
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "前後"
                font.pixelSize: 40
                style: Text.Outline
                styleColor: "white"
            }
        }
    }

    Connections {
        target: GamepadManager
        onGamepadConnected: gamepad.deviceId = deviceId
    }

    property Gamepad gamepad: Gamepad{ // XboxControllerの外からでもスロットを設定できるようにプロパティにしてある
        id: gamepad
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1
    }
}
