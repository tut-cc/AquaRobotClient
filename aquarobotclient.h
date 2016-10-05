// 水中ロボットを操縦するためのクラス
#ifndef AQUAROBOTCLIENT_H
#define AQUAROBOTCLIENT_H

#include <QObject>
#include <QtWebSockets/QWebSocket>
#include <QTimer>
#include <QFile>

class AquaRobotClient : public QObject
{
    Q_OBJECT // Qt関連のオブジェクトで必須のマクロ privateのとこで宣言する必要あり
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY stateChanged)
    Q_PROPERTY(bool isEmergencyMode READ isEmergencyMode NOTIFY dataUpdated)
    Q_PROPERTY(QString host READ host NOTIFY stateChanged)
    Q_PROPERTY(int port READ port NOTIFY stateChanged)
    Q_PROPERTY(double vx READ vx NOTIFY dataUpdated) // QMLからオブジェクトの要素を呼び出せるようにするためのマクロ
    Q_PROPERTY(double vy READ vy NOTIFY dataUpdated)
    Q_PROPERTY(double vz READ vz NOTIFY dataUpdated)
    Q_PROPERTY(double ax READ ax NOTIFY dataUpdated)
    Q_PROPERTY(double ay READ ay NOTIFY dataUpdated)
    Q_PROPERTY(double az READ az NOTIFY dataUpdated)
    Q_PROPERTY(double pitch READ pitch NOTIFY dataUpdated)
    Q_PROPERTY(double roll READ roll NOTIFY dataUpdated)
    Q_PROPERTY(double yaw READ yaw NOTIFY dataUpdated)
    Q_PROPERTY(double avx READ avx NOTIFY dataUpdated)
    Q_PROPERTY(double avy READ avy NOTIFY dataUpdated)
    Q_PROPERTY(double avz READ avz NOTIFY dataUpdated)
    Q_PROPERTY(double battery READ battery NOTIFY dataUpdated)
    Q_PROPERTY(double vxOrder READ vxOrder WRITE setVxOrder NOTIFY vxOrderChanged)
    Q_PROPERTY(double vzOrder READ vzOrder WRITE setVzOrder NOTIFY vzOrderChanged)
    Q_PROPERTY(double avyOrder READ avyOrder WRITE setAvyOrder NOTIFY avyOrderChanged)
public:
    explicit AquaRobotClient(QObject *parent = Q_NULLPTR);
    ~AquaRobotClient();
    bool isConnected();
    bool isEmergencyMode();
    QString host();
    int port();
    double vx();
    double vy();
    double vz();
    double ax();
    double ay();
    double az();
    double pitch();
    double roll();
    double yaw();
    double avx();
    double avy();
    double avz();
    double battery();
    double vxOrder();
    double vzOrder();
    double avyOrder();
    void setVxOrder(double v);
    void setVzOrder(double v);
    void setAvyOrder(double av);

public slots:
    void open(const QString &host, int port);
    void close();
    Q_INVOKABLE void setEmergencyMode(bool mode); // Q_INVOKABLEでQMLからも呼び出せるように
    void writeLog(const QString &str);
    void onBinaryMessageReceived(const QByteArray &data);
    void sendCommand();
    void onConnected();
    void onDisconnected();

signals:
    void dataUpdated(); // 水中ロボットから新しいデータを受信した時に発生
    void stateChanged(bool connected); // 水中ロボットとの通信状態が変化した時に発生
                                    // isConnectedプロパティをQML上で動作させるためのもの
    //void opened(); // 水中ロボットとの通信が確立された時に発生
    //void closed(); // 水中ロボットとの通信が切断された時に発生
    void vxOrderChanged();
    void vzOrderChanged();
    void avyOrderChanged();

private:
    QWebSocket m_webSocket; // WebSocket
    QFile m_logFile; // ログを出力するファイル
    QTextStream m_logFileStream; // ログファイルの出力で使用するストリーム
    QTimer m_timer; // 水中ロボットへ命令を一定間隔で送信するためのタイマ
    double m_vx, m_vy, m_vz; // 速度[m/s]
    double m_ax, m_ay, m_az; // 加速度[m/s^2]
    double m_pitch, m_roll, m_yaw; // 機体の角度[deg]
    double m_avx, m_avy, m_avz; // 角速度[deg/s]
    double m_battery; // バッテリ残量[%]
    double m_vxOrder, m_vzOrder, m_avyOrder; // x・z方向への速度指令値[m/s]、旋回角速度指令値[deg/s]
    bool m_emergencyMode; // 緊急停止モードのフラグ、緊急モード時には全てのモータを停止
    enum class emergencyModeOrders : int { OFF = 0, ON = 1, NOCHANGE = 2 }; // 無効化、有効化、変更なし
    emergencyModeOrders m_emergencyModeOrder; // 緊急停止モードを有効・無効にするか否かの指令
};

#endif // AQUAROBOTCLIENT_H
