#ifndef GPSDATAMANAGER_H
#define GPSDATAMANAGER_H

#include <QObject>
#include <QString>
#include <QSerialPort>
#include <QRegularExpression>
#include <QTimer>

class GpsDataManager : public QObject {
    Q_OBJECT

    // QML Properties
    Q_PROPERTY(double latitude  READ latitude  NOTIFY dataUpdated)
    Q_PROPERTY(double longitude READ longitude NOTIFY dataUpdated)
    Q_PROPERTY(double heading   READ heading   NOTIFY dataUpdated)
    Q_PROPERTY(double speed     READ speed     NOTIFY dataUpdated)

public:
    explicit GpsDataManager(QObject *parent = nullptr);

    // Data getters for QML
    double latitude()  const { return m_latitude; }
    double longitude() const { return m_longitude; }
    double heading()   const { return m_heading; }
    double speed()     const { return m_speed; }

    // Serial port control
    Q_INVOKABLE void connectSerialPort(const QString &portName, qint32 baudRate);

signals:
    void dataUpdated();                 // emitted at 10Hz
    void serialPortError(const QString &error);

private slots:
    void readSerialData();              // called when serial reads
    void publishData();                 // throttled output to UI

private:
    double m_latitude  = 0.0;
    double m_longitude = 0.0;
    double m_heading   = 0.0;
    double m_speed     = 0.0;

    QSerialPort *m_serialPort = nullptr;
    QString m_nmeaBuffer;

    QTimer m_publishTimer;
};

#endif // GPSDATAMANAGER_H
