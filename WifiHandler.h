#pragma once
#include <QObject>
#include <QStringList>

class WifiHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)

public:
    explicit WifiHandler(QObject *parent = nullptr);

    Q_INVOKABLE bool wifiOnOff(bool on);
    Q_INVOKABLE QStringList scanWifi();
    Q_INVOKABLE bool connectToWifi(const QString &ssid, const QString &password);
    Q_INVOKABLE QString getIpAddress();
    Q_INVOKABLE bool isConnected();

signals:
    void connectionStatusChanged(bool connected);

private:
    bool lastStatus = false;
};
