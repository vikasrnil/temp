#include "WifiHandler.h"
#include <QProcess>
#include <QDebug>

WifiHandler::WifiHandler(QObject *parent)
    : QObject(parent)
{
}

bool WifiHandler::wifiOnOff(bool on)
{
    QString cmd = on ? "nmcli radio wifi on" : "nmcli radio wifi off";
    return (QProcess::execute(cmd) == 0);
}

QStringList WifiHandler::scanWifi()
{
    QStringList wifiList;
    QProcess p;
    p.start("nmcli -t -f SSID dev wifi list");
    p.waitForFinished();

    if (p.exitStatus() != QProcess::NormalExit || p.exitCode() != 0) {
        qDebug() << "WiFi scan failed. Error:" << p.readAllStandardError();
        return wifiList;  // Return empty list on failure
    }

    QString output = p.readAll();
    if (output.isEmpty()) {
        qDebug() << "No WiFi networks found.";
        return wifiList;  // Return empty list if no networks found
    }

    QStringList lines = output.split("\n", Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        if (!line.trimmed().isEmpty())
            wifiList << line.trimmed();
    }

    return wifiList;
}

bool WifiHandler::connectToWifi(const QString &ssid, const QString &password)
{
    QString cmd = QString("nmcli dev wifi connect \"%1\" password \"%2\"").arg(ssid, password);

    QProcess p;
    p.start(cmd);
    p.waitForFinished();

    QString errorOutput = p.readAllStandardError();
    bool success = (p.exitStatus() == QProcess::NormalExit && p.exitCode() == 0);

    if (!success && !errorOutput.isEmpty()) {
        qDebug() << "Error connecting to WiFi:" << errorOutput;
    }

    emit connectionStatusChanged(success, errorOutput);
    return success;
}

QString WifiHandler::getIpAddress()
{
    QProcess p;
    p.start("hostname -I");
    p.waitForFinished();

    QString output = p.readAll().trimmed();

    // Split the output into individual addresses (space-separated)
    QStringList ipList = output.split(" ", QString::SkipEmptyParts);

    // Loop through the list of addresses and return the first IPv4 address
    for (const QString &ip : ipList) {
        // Check if the address looks like an IPv4 (simple regex check)
        QRegExp ipv4Regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$");
        if (ipv4Regex.exactMatch(ip)) {
            return ip;
        }
    }

    return "No IP";  // Return "No IP" if no IPv4 address found
}

QString WifiHandler::getConnectedSSID()
{
    // Check if Wi-Fi is enabled
    QProcess p;
    p.start("nmcli -t -f WIFI g");
    p.waitForFinished();
    QString wifiStatus = p.readAll().trimmed();  // Should be "enabled" if Wi-Fi is on
    
    if (wifiStatus != "enabled") {
        return "";  // Wi-Fi is off, return empty string
    }

    // Check if the device is connected to a network
    QProcess p2;
    p2.start("nmcli -t -f STATE g");
    p2.waitForFinished();
    QString connectionState = p2.readAll().trimmed();  // "connected" or "disconnected"
    
    if (connectionState != "connected") {
        return "";  // Device is not connected, return empty string
    }

    // Get the SSID of the connected network
    QProcess ssidProcess;
    ssidProcess.start("nmcli -t -f SSID dev wifi");
    ssidProcess.waitForFinished();
    QString ssid = ssidProcess.readAll().trimmed();
    
    if (ssid.isEmpty()) {
        return "";  // No SSID found
    }

    return ssid;  // Return the connected SSID
}


bool WifiHandler::isConnected()
{
    // Check if Wi-Fi is turned on
    QProcess p;
    p.start("nmcli -t -f WIFI g");
    p.waitForFinished();
    QString wifiStatus = p.readAll().trimmed();
    
    if (wifiStatus != "enabled") {
        return false;  // Wi-Fi is off
    }

    // Check if the device is connected to a network
    QProcess p2;
    p2.start("nmcli -t -f STATE g");
    p2.waitForFinished();
    QString connectionState = p2.readAll().trimmed();
    
    if (connectionState != "connected") {
        return false;  // Device is not connected
    }

    // Check for IP address
    QProcess ipCheck;
    ipCheck.start("hostname -I");
    ipCheck.waitForFinished();
    QString ipOutput = ipCheck.readAll().trimmed();
    
    if (ipOutput.isEmpty() || ipOutput == "No IP") {
        return false;  // No valid IP address
    }

    return true;  // Wi-Fi is connected and has a valid IP
}



