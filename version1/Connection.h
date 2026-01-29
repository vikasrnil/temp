#pragma once

#include <QObject>
#include <QVariantList>
#include <QProcess>
#include <functional>

class Connection : public QObject
{
    Q_OBJECT

public:
    explicit Connection(QObject *parent = nullptr);

    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void disconnectFromNetwork();
    Q_INVOKABLE void updateWifiList();

signals:
    void connectionResult(const QString &message, const QString &ip = QString());
    void wifiListUpdated(const QVariantList &list);

private:
    void runNmcliAsync(const QStringList &args,
                       std::function<void(QString)> callback);

    QString currentWifiDevice(const QString &deviceOutput);
    QString currentIp(const QString &device);
};

