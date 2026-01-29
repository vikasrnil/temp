#include "farmbackend.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

FarmBackend::FarmBackend(QObject *parent)
    : QObject(parent)
{
    QString base = QDir::homePath() + "/version1";
    QDir dir(base);
    if (!dir.exists())
        dir.mkpath(base);

    farmDbPath = base + "/farmdb.json";

    QFile file(farmDbPath);
    if (!file.exists()) {
        file.open(QIODevice::WriteOnly);
        file.write("{}");
        file.close();
    }
}

bool FarmBackend::saveFarm(const QString &farmName, const QString &jsonArray)
{
    QFile file(farmDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject db = doc.object();

    QJsonDocument arrDoc = QJsonDocument::fromJson(jsonArray.toUtf8());
    QJsonArray arr = arrDoc.array();

    db[farmName] = arr;

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;

    file.write(QJsonDocument(db).toJson());
    file.close();

    emit farmSaved();
    return true;
}

QString FarmBackend::loadFarm(const QString &farmName)
{
    QFile file(farmDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return "";

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (!doc.object().contains(farmName))
        return "";

    return QString(QJsonDocument(doc.object()[farmName].toArray())
                       .toJson(QJsonDocument::Compact));
}

QStringList FarmBackend::listFarms()
{
    QFile file(farmDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    return doc.object().keys();
}

bool FarmBackend::deleteFarm(const QString &farmName)
{
    QFile file(farmDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject db = doc.object();
    if (!db.contains(farmName))
        return false;

    db.remove(farmName);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;

    file.write(QJsonDocument(db).toJson());
    file.close();

    emit farmDeleted();
    return true;
}
