#include "operations.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QDebug>

Operations::Operations(QObject *parent)
    : QObject(parent)
{
    QString base = QDir::homePath() + "/version1";
    QDir dir(base);
    if (!dir.exists())
        dir.mkpath(base);

    tractorDbPath = base + "/tractordb.json";

    QFile f(tractorDbPath);
    if (!f.exists()) {
        f.open(QIODevice::WriteOnly);
        f.write("{}");
        f.close();
    }
}

QString Operations::saveTractorData(const QVariantMap &tractorData)
{
    QString name = tractorData.value("name").toString().trimmed();
    if (name.isEmpty())
        return "Invalid name";

    QFile file(tractorDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return "DB read error";

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject db = doc.object();

    // Convert QVariantMap → QJsonObject
    QJsonObject obj = QJsonObject::fromVariantMap(tractorData);

    db[name] = obj;

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return "DB write error";

    file.write(QJsonDocument(db).toJson());
    file.close();

    emit tractorSaved();
    return "Saved";
}

QVariantList Operations::loadAllTractors()
{
    QVariantList list;

    QFile file(tractorDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return list;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject db = doc.object();

    for (auto key : db.keys()) {
        QVariantMap map = db.value(key).toObject().toVariantMap();
        list.append(map);
    }

    return list;
}

bool Operations::deleteTractorData(const QString &tractorName)
{
    QFile file(tractorDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject db = doc.object();
    if (!db.contains(tractorName))
        return false;

    db.remove(tractorName);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;

    file.write(QJsonDocument(db).toJson());
    file.close();

    emit tractorDeleted(tractorName);
    return true;
}
