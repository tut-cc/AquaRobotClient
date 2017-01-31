#include "aquarobotclient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <iostream>

QT_USE_NAMESPACE

// コンストラクタ
// parent引数は特に指定する必要は無い
AquaRobotClient::AquaRobotClient(QObject *parent) : QObject(parent)
{
    m_logFile.setFileName(QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss") + ".log"); // ログファイルの名前を年-月-日_時-分-秒.logとする

    if(!(m_logFile.open(QIODevice::WriteOnly | QIODevice::Text))) // 書き込みモードでファイルを開く
        std::cout << "In " << __FILE__ << ": Line " << __LINE__ << ": " << "ログファイルのオープンに失敗" << std::endl; // それぞれのマクロはソースのファイル名、行数に置き換わる
    m_logFileStream.setDevice(&m_logFile); // ファイルストリームをオープン

    m_timer.setInterval(SEND_INTERVAL_MILISEC); // 命令送信間隔[milisec]の設定
    m_timer.stop(); // タイマを一応停止
    m_timer.setSingleShot(false); // タイマが一度タイムアウトしても再び開始するように設定
    connect(&m_timer, &QTimer::timeout, this, &AquaRobotClient::sendCommand); // タイマがタイムアウトする度に命令を送信
    connect(&m_webSocket, &QWebSocket::connected, this, &AquaRobotClient::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &AquaRobotClient::onDisconnected);
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &AquaRobotClient::onTextMessageReceived);
}

// デストラクタ
AquaRobotClient::~AquaRobotClient(){
    m_webSocket.close();
    m_logFile.close();
}

// 水中ロボットと接続済みか？
// 返り値：true 接続、false 未接続
bool AquaRobotClient::isConnected(){
    return m_webSocket.isValid();
}

// 緊急モードが有効か？
// 返り値：true 有効、false 無効
bool AquaRobotClient::isEmergencyMode(){
    return m_emergencyMode;
}

// 現在接続中の水中ロボットのホスト名を返す
// 接続していなければ空の文字列を返す…はず
QString AquaRobotClient::host(){
    return m_webSocket.requestUrl().host();
}

// 返り値：現在接続中の水中ロボットのポート番号
int AquaRobotClient::port(){
    return m_webSocket.requestUrl().port();
}

// 返り値：x軸速度[m/s]
double AquaRobotClient::vx(){
    return m_vx;
}

// 返り値：y軸速度[m/s]
double AquaRobotClient::vy(){
    return m_vy;
}

// 返り値：z軸速度[m/s]
double AquaRobotClient::vz(){
    return m_vz;
}

// 返り値：x軸加速度[m/s^2]
double AquaRobotClient::ax(){
    return m_ax;
}

// 返り値：y軸加速度[m/s^2]
double AquaRobotClient::ay(){
    return m_ay;
}

// 返り値：z軸加速度[m/s^2]
double AquaRobotClient::az(){
    return m_az;
}

// 返り値：ピッチ[deg]
double AquaRobotClient::pitch(){
    return m_pitch;
}

// 返り値：ロール[deg]
double AquaRobotClient::roll(){
    return m_roll;
}

// 返り値：ヨー[deg]
double AquaRobotClient::yaw(){
    return m_yaw;
}

// 返り値：x軸周りの角速度[deg/s]
double AquaRobotClient::avx(){
    return m_avx;
}

// 返り値：y軸周りの角速度
double AquaRobotClient::avy(){
    return m_avy;
}

// 返り値：z軸周りの角速度
double AquaRobotClient::avz(){
    return m_avy;
}

// 返り値：バッテリ残量[%]
double AquaRobotClient::battery(){
    return m_battery;
}

// 返り値：x軸速度指令値[m/s]
double AquaRobotClient::vxOrder(){
    return m_vxOrder;
}

// 返り値：z軸速度指令値[m/s]
double AquaRobotClient::vzOrder(){
    return m_vzOrder;
}

// 返り値：旋回速度指令値[deg/s]
double AquaRobotClient::avyOrder(){
    return m_avyOrder;
}

// x軸速度指令値を指定
// 引数：v 速度[m/s]
void AquaRobotClient::setVxOrder(double v){
    m_vxOrder = v;
    //writeLog(QString("%1(): vxOrder = %2 [m/s] （x軸速度指令値を設定）").arg(__FUNCTION__, QString::number(v))); // ログ出力 QString.argでテキストを整形している
    emit vxOrderChanged();
}

// z軸速度指令値を指定
// 引数：v 速度[m/s]
void AquaRobotClient::setVzOrder(double v){
    m_vzOrder = v;
    //writeLog(QString("%1(): vzOrder = %2 [m/s] （z軸速度指令値を設定）").arg(__FUNCTION__, QString::number(v)));

    emit vzOrderChanged();
}

// 旋回角速度指令値を指定
// 引数：av 角速度[deg/s]
void AquaRobotClient::setAvyOrder(double av){
    m_avyOrder = av;
    //writeLog(QString("%1(): avyOrder = %2 [deg/s] （y軸角速度指令値を設定）").arg(__FUNCTION__, QString::number(av)));

    emit avyOrderChanged();
}

// 水中ロボットとの通信を開始
// 引数：host 水中ロボットのホスト名, port ポート番号
void AquaRobotClient::open(const QString &host, int port){
    QUrl url;
    url.setScheme("ws"); // URIのスキームをWebSocketに設定
    url.setHost(host);
    url.setPort(port);
    writeLog(QString("%1(): 水中ロボット（%2）との接続処理開始").arg(__FUNCTION__, url.toString(QUrl::None)));

    // 接続時に急に動き出さないように緊急停止モードを有効化して各指令値も0に
    setEmergencyMode(true);

    writeLog(QString("%1(): WebSocketのオープン").arg(__FUNCTION__));
    m_webSocket.open(url);
}

// 水中ロボットとの通信を切断
void AquaRobotClient::close(){
    writeLog(QString("%1(): 通信を切断").arg(__FUNCTION__));
    m_webSocket.close();
}

// 緊急モードを有効化または解除 念のために各指令値もリセット
// 引数：modeOn trueで有効化 falseで解除
void AquaRobotClient::setEmergencyMode(bool mode){
    writeLog(QString("%1(): 各指令値を0にセット").arg(__FUNCTION__));
    setVxOrder(0.0);
    setVzOrder(0.0);
    setAvyOrder(0.0);
    if(mode){
        m_emergencyModeOrder = emergencyModeOrders::ON;
        writeLog(QString("%1(): emergencyModeOrder = 1 (緊急モードを有効化）").arg(__FUNCTION__));
    }else{
        m_emergencyModeOrder = emergencyModeOrders::OFF;
        writeLog(QString("%1(): emergencyModeOrder = 0 (緊急モードを解除）").arg(__FUNCTION__));
    }
}

// ログファイルに時刻付きでテキストを出力
// 引数：str 出力するテキスト
void AquaRobotClient::writeLog(const QString &str){
    if(m_logFileStream.status() != QTextStream::WriteFailed)
        m_logFileStream << QDateTime::currentDateTime().toString("yyyy/MM/dd HH:mm:ss.zzz ") << str << endl;
}

// 水中ロボットからJsonデータを受信した際に呼ばれるスロット
void AquaRobotClient::onTextMessageReceived(const QString &data)
{
    QJsonDocument jsonDoc; // Jsonをオブジェクトに変換するためのオブジェクト
    QJsonObject jsonData; // Jsonデータを格納するためのオブジェクト
    jsonDoc = QJsonDocument::fromJson(data.toLocal8Bit()); // 受信したバイト列をJsonファイルとして読み込み
    jsonData = jsonDoc.object(); // Json内の値を直接操作できるオブジェクトに変換

    m_emergencyMode = jsonData["emergencyMode"].toBool();
    if(static_cast<int>(m_emergencyModeOrder) == (int)isEmergencyMode()) // 緊急停止モードの変更命令が適用されたなら
        m_emergencyModeOrder = emergencyModeOrders::NOCHANGE;
    m_vx = jsonData["vx"].toDouble();
    m_vy = jsonData["vy"].toDouble();
    m_vz = jsonData["vz"].toDouble();
    m_ax = jsonData["ax"].toDouble();
    m_ay = jsonData["ay"].toDouble();
    m_az = jsonData["az"].toDouble();
    m_pitch = jsonData["pitch"].toDouble();
    m_roll = jsonData["roll"].toDouble();
    m_yaw = jsonData["yaw"].toDouble();
    m_avx = jsonData["avx"].toDouble();
    m_avy = jsonData["avy"].toDouble();
    m_avz = jsonData["avz"].toDouble();
    m_battery = jsonData["battery"].toDouble();

    QString log;
    log.append(QString("%1(): 水中ロボットからデータを受信: ").arg(__FUNCTION__));
    log.append(QString("emergencyMode = %1, ").arg(m_emergencyMode));
    log.append(QString("vx = %1, ").arg(m_vx));
    log.append(QString("vy = %1, ").arg(m_vy));
    log.append(QString("vz = %1, ").arg(m_vz));
    log.append(QString("ax = %1, ").arg(m_ax));
    log.append(QString("ay = %1, ").arg(m_ay));
    log.append(QString("az = %1, ").arg(m_az));
    log.append(QString("pitch = %1, ").arg(m_pitch));
    log.append(QString("roll = %1, ").arg(m_roll));
    log.append(QString("yaw = %1, ").arg(m_yaw));
    log.append(QString("avx = %1, ").arg(m_avx));
    log.append(QString("avy = %1, ").arg(m_avy));
    log.append(QString("avz = %1, ").arg(m_avz));
    log.append(QString("battery = %1").arg(m_battery));
    writeLog(log);
    emit dataUpdated(); // データが更新されたことを通知
}

// 各指令値などのデータを水中ロボットに送信 タイマで一定間隔ごとに自動で呼び出されるスロット
void AquaRobotClient::sendCommand(){
    QJsonObject jsonData;

    jsonData["vxOrder"] = vxOrder();
    jsonData["vzOrder"] = vzOrder();
    jsonData["avyOrder"] = avyOrder();
    jsonData["emergencyModeOrder"] = static_cast<int>(m_emergencyModeOrder);

    QJsonDocument jsonDoc(jsonData);
    m_webSocket.sendBinaryMessage(jsonDoc.toJson());

    QString log;
    log.append(QString("%1(): 水中ロボットにデータを送信: ").arg(__FUNCTION__));
    log.append(QString("vxOrder = %1, ").arg(vxOrder()));
    log.append(QString("vzOrder = %1, ").arg(vzOrder()));
    log.append(QString("avyOrder = %1, ").arg(avyOrder()));
    log.append(QString("emergencyModeOrder = %1").arg(static_cast<int>(m_emergencyModeOrder)));
    writeLog(log);
}

// 水中ロボットとの通信が確立された時に実行される
void AquaRobotClient::onConnected(){
    m_timer.start();
    emit stateChanged(true);
    writeLog(QString("%1(): 水中ロボットとの通信を確立しました").arg(__FUNCTION__));
}

// 水中ロボットとの通信が切断された時に実行される
void AquaRobotClient::onDisconnected(){
    m_timer.stop();
    emit stateChanged(false);
    writeLog(QString("%1(): 水中ロボットとの通信が切断されました").arg(__FUNCTION__));
}
