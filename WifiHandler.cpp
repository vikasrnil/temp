#include "wifi.h"
#include <QProcess>
#include <QDebug>

WifiHandler::WifiHandler(QObject *parent)
    : QObject(parent)
{
}

bool WifiHandler::wifiOnOff(bool on)
{
    QString command = on ? "nmcli radio wifi on" : "nmcli radio wifi off";
    int exitCode = QProcess::execute(command);

    bool currentStatus = isConnected();
    if (currentStatus != lastStatus) {
        lastStatus = currentStatus;
        emit connectionStatusChanged(currentStatus);
    }

    return (exitCode == 0);
}

QStringList WifiHandler::scanWifi()
{
    QStringList result;
    QProcess p;
    p.start("nmcli -t -f SSID device wifi list");
    p.waitForFinished();

    QString output = p.readAll();
    for (const QString &line : output.split("\n")) {
        if (!line.trimmed().isEmpty())
            result << line.trimmed();
    }

    return result;
}

bool WifiHandler::connectToWifi(const QString &ssid, const QString &password)
{
    QString cmd = QString("nmcli device wifi connect \"%1\" password \"%2\"").arg(ssid, password);

    int exitCode = QProcess::execute(cmd);

    bool currentStatus = isConnected();
    if (currentStatus != lastStatus) {
        lastStatus = currentStatus;
        emit connectionStatusChanged(currentStatus);
    }

    return (exitCode == 0);
}

QString WifiHandler::getIpAddress()
{
    QProcess p;
    p.start("hostname -I");
    p.waitForFinished();

    QString ip = p.readAll().trimmed();
    QStringList list = ip.split(" ");

    if (list.isEmpty())
        return "";

    return list.first();  // only IPv4
}

bool WifiHandler::isConnected()
{
    QString ip = getIpAddress();
    return !ip.isEmpty();
}
