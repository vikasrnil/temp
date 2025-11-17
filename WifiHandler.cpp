#include "wifi.h"
#include <QProcess>
#include <QDebug>

WifiHandler::WifiHandler(QObject *parent)
    : QObject(parent)
{
}

// ---------------------------------------------------------
// Turn WiFi ON/OFF
// ---------------------------------------------------------
bool WifiHandler::wifiOnOff(bool on)
{
    QString cmd = on ? "nmcli radio wifi on" : "nmcli radio wifi off";
    return (QProcess::execute(cmd) == 0);
}

// ---------------------------------------------------------
// Scan WiFi Networks
// ---------------------------------------------------------
QStringList WifiHandler::scanWifi()
{
    QStringList list;
    QProcess p;

    p.start("nmcli -t -f SSID dev wifi list ifname wlan0");
    p.waitForFinished();

    QString out = p.readAll().trimmed();
    if (out.isEmpty())
        return list;

    QStringList lines = out.split("\n", Qt::SkipEmptyParts);
    for (const QString &l : lines)
        if (!l.trimmed().isEmpty())
            list.append(l.trimmed());

    return list;
}

// ---------------------------------------------------------
// Connect to WiFi
// ---------------------------------------------------------
bool WifiHandler::connectToWifi(const QString &ssid, const QString &password)
{
    QString cmd = QString("nmcli dev wifi connect \"%1\" password \"%2\" ifname wlan0")
                    .arg(ssid, password);

    QProcess p;
    p.start(cmd);
    p.waitForFinished();

    bool success = (p.exitStatus() == QProcess::NormalExit && p.exitCode() == 0);

    emit connectionStatusChanged(success);
    emit ssidChanged(getConnectedSSID());
    emit ipChanged(getIpAddress());

    return success;
}

// ---------------------------------------------------------
// Get Device IP Address
// ---------------------------------------------------------
QString WifiHandler::getIpAddress()
{
    QProcess p;
    p.start("hostname -I");
    p.waitForFinished();

    QString output = p.readAll().trimmed();
    QStringList list = output.split(" ", Qt::SkipEmptyParts);

    for (const QString &ip : list) {
        QRegExp ipv4("^(\\d{1,3}\\.){3}\\d{1,3}$");
        if (ipv4.exactMatch(ip))
            return ip;
    }

    return "No IP";
}

// ---------------------------------------------------------
// Get Connected SSID
// ---------------------------------------------------------
QString WifiHandler::getConnectedSSID()
{
    QProcess p;
    p.start("nmcli -t -f ACTIVE,SSID dev wifi");
    p.waitForFinished();

    QString out = p.readAll().trimmed();
    QStringList lines = out.split("\n");

    for (const QString &line : lines) {
        if (line.startsWith("yes:")) {
            return line.section(":", 1, 1);
        }
    }

    return "";
}

// ---------------------------------------------------------
// Is Connected?
// ---------------------------------------------------------
bool WifiHandler::isConnected()
{
    return !getConnectedSSID().isEmpty();
}
