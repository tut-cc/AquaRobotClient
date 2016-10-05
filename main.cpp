#include <QtWidgets/QApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtWebEngine/QtWebEngine>
#include "aquarobotclient.h"

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    QtWebEngine::initialize(); // WebEngineの初期化

    QQmlApplicationEngine appEngine;
    AquaRobotClient client;
    appEngine.rootContext()->setContextProperty("AquaRobot", &client); // QMLからclientオブジェクトが参照できるようにする
    appEngine.load(QUrl("qrc:/ApplicationRoot.qml")); // QMLの読み込み

    return app.exec();
}
