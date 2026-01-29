
#include "GpsDataManager.h"
#include <QDebug>

GpsDataManager::GpsDataManager(QObject *parent)
    : QObject(parent),
    m_serialPort(new QSerialPort(this))
{
    // Serial ready
    connect(m_serialPort, &QSerialPort::readyRead,
            this, &GpsDataManager::readSerialData);

    // Serial error
    connect(m_serialPort, &QSerialPort::errorOccurred,
            this, [this](QSerialPort::SerialPortError error){
                if (error != QSerialPort::NoError)
                    emit serialPortError(m_serialPort->errorString());
            });

    // Throttle UI updates (10Hz)
    connect(&m_publishTimer, &QTimer::timeout,
            this, &GpsDataManager::publishData);
    m_publishTimer.start(100);
}

void GpsDataManager::connectSerialPort(const QString &portName, qint32 baudRate)
{
    if (m_serialPort->isOpen())
        m_serialPort->close();

    m_serialPort->setPortName(portName);
    m_serialPort->setBaudRate(baudRate);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (!m_serialPort->open(QIODevice::ReadOnly)) {
        emit serialPortError(m_serialPort->errorString());
        qCritical() << "Serial open failed:" << m_serialPort->errorString();
    } else {
        qDebug() << "Serial port opened:" << portName;
    }
}

void GpsDataManager::readSerialData()
{
    m_nmeaBuffer += m_serialPort->readAll();

    // Your custom format
    static QRegularExpression pattern(
        "Latitude:\\s*([\\d\\.]+)\\s*,\\s*"
        "Longitude:\\s*([\\d\\.]+)\\s*,\\s*"
        "Heading:\\s*([\\d\\.]+)\\s*,\\s*"
        "Speed:\\s*([\\d\\.]+)\\s*km/h"
        );

    while (true) {
        int idx = m_nmeaBuffer.indexOf("\r\n");
        if (idx < 0)
            return;

        QString line = m_nmeaBuffer.left(idx).trimmed();
        m_nmeaBuffer.remove(0, idx + 2);

        QRegularExpressionMatch m = pattern.match(line);

        if (m.hasMatch()) {
            m_latitude  = m.captured(1).toDouble();
            m_longitude = m.captured(2).toDouble();
            m_heading   = m.captured(3).toDouble();
            m_speed     = m.captured(4).toDouble();
        }
    }
}

void GpsDataManager::publishData()
{
    emit dataUpdated();
}
