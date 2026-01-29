#include "Connection.h"

#include <QDebug>
#include <QTimer>

Connection::Connection(QObject *parent)
    : QObject(parent)
{
}

// ------------------------------------------------
// Async nmcli helper
// ------------------------------------------------
void Connection::runNmcliAsync(const QStringList &args,
                              std::function<void(QString)> callback)
{
    QProcess *process = new QProcess(this);

    connect(process,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            [process, callback](int, QProcess::ExitStatus status) {

                QString output;
                if (status == QProcess::NormalExit)
                    output = process->readAllStandardOutput().trimmed();
                else
                    qDebug() << "[nmcli] crashed";

                process->deleteLater();
                callback(output);
            });

    process->start("nmcli", args);
}


// ------------------------------------------------
// Connect to WiFi (non-blocking)
// ------------------------------------------------
void Connection::connectToNetwork(const QString &ssid, const QString &password)
{
    if (ssid.trimmed().isEmpty()) {
        emit connectionResult("SSID is empty");
        return;
    }

    //runNmcliAsync({"radio", "wifi", "on"}, [](QString) {});
   // runNmcliAsync({"device", "wifi", "rescan"}, [](QString) {});

    QStringList args{"device", "wifi", "connect", ssid};
    if (!password.isEmpty())
        args << "password" << password;

    runNmcliAsync(args, [this, ssid](const QString &output) {

        if (!output.contains("successfully", Qt::CaseInsensitive)) {
            emit connectionResult("Failed to connect to " + ssid);
            return;
        }

        // Give NetworkManager time to assign IP (non-blocking)
        QTimer::singleShot(800, this, [this, ssid]() {

            runNmcliAsync(
                {"-t", "-f", "DEVICE,TYPE,STATE", "device"},
                [this, ssid](const QString &devices) {

                    QString device = currentWifiDevice(devices);
                    if (device.isEmpty()) {
                        emit connectionResult("Connected but no device found");
                        return;
                    }

                    runNmcliAsync(
                        {"-t", "-f", "IP4.ADDRESS", "device", "show", device},
                        [this, ssid](const QString &ipOut) {

                            QString ip = currentIp(ipOut);
                            if (!ip.isEmpty())
                                emit connectionResult("Connected to " + ssid, ip);
                            else
                                emit connectionResult("Connected but no IP");
                        });
                });
        });
    });
}

// ------------------------------------------------
// Disconnect
// ------------------------------------------------
void Connection::disconnectFromNetwork()
{
    runNmcliAsync(
        {"-t", "-f", "DEVICE,TYPE,STATE", "device"},
        [this](const QString &devices) {

            QString device = currentWifiDevice(devices);
            if (device.isEmpty()) {
                emit connectionResult("No active WiFi connection");
                return;
            }

            runNmcliAsync({"device", "disconnect", device},
                          [this](QString) {
                              emit connectionResult("Disconnected");
                          });
        });
}

// ------------------------------------------------
// Update WiFi list (non-blocking)
// ------------------------------------------------
void Connection::updateWifiList()
{
    runNmcliAsync({"device", "wifi", "rescan"}, [](QString) {});

    runNmcliAsync(
        {"-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"},
        [this](const QString &output) {

            QVariantList networks;

            for (const QString &line : output.split('\n')) {
                if (line.isEmpty())
                    continue;

                QStringList parts = line.split(':');
                if (parts.size() < 4)
                    continue;

                QVariantMap entry;
                entry["connected"] = (parts[0] == "*");
                entry["ssid"] = parts[1];
                entry["strength"] = parts[2].toInt();
                entry["security"] = parts[3];
                entry["requiresPassword"] =
                    !parts[3].isEmpty() && parts[3] != "--";

                networks.append(entry);
            }

            emit wifiListUpdated(networks);
        });
}

// ------------------------------------------------
// Helpers
// ------------------------------------------------
QString Connection::currentWifiDevice(const QString &output)
{
    for (const QString &line : output.split('\n')) {
        const QStringList parts = line.split(':');
        if (parts.size() == 3 &&
            parts[1] == "wifi" &&
            parts[2] == "connected")
            return parts[0];
    }
    return {};
}

QString Connection::currentIp(const QString &output)
{
    if (output.isEmpty())
        return {};

    return output.section(':', 1).section('/', 0);
}

