#pragma once
#include <QObject>
#include <QStringList>

class WifiHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)
    Q_PROPERTY(QString ipAddress READ getIpAddress NOTIFY ipChanged)
    Q_PROPERTY(QString connectedSSID READ getConnectedSSID NOTIFY ssidChanged)

public:
    explicit WifiHandler(QObject *parent = nullptr);

    Q_INVOKABLE bool wifiOnOff(bool on);
    Q_INVOKABLE QStringList scanWifi();
    Q_INVOKABLE bool connectToWifi(const QString &ssid, const QString &password);

    QString getIpAddress();
    QString getConnectedSSID();
    bool isConnected();

signals:
    void connectionStatusChanged(bool connected);
    void ipChanged(const QString &ip);
    void ssidChanged(const QString &ssid);
};
