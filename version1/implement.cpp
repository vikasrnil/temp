#include "implement.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

Implement::Implement(QObject *parent)
    : QObject(parent)
{
    QString base = QDir::homePath() + "/version1";
    QDir dir(base);
    if (!dir.exists())
        dir.mkpath(base);

    implementDbPath = base + "/implementdb.json";

    QFile f(implementDbPath);
    if (!f.exists()) {
        f.open(QIODevice::WriteOnly);
        f.write("{}");
        f.close();
    }
}

static QString makeImplementKey(const QVariantMap &d)
{
    return d.value("type").toString() + "-" +
           d.value("tx").toString() + "-" +
           d.value("width").toString();
}

QString Implement::saveImplementData(const QVariantMap &implementData)
{
    QString key = makeImplementKey(implementData);
    if (key.trimmed().isEmpty())
        return "Invalid implement data";

    QFile file(implementDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return "DB open failed";

    QJsonObject db = QJsonDocument::fromJson(file.readAll()).object();
    file.close();

    QJsonObject obj;
    for (auto it = implementData.begin(); it != implementData.end(); ++it)
        obj[it.key()] = QJsonValue::fromVariant(it.value());

    db[key] = obj;

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return "Write failed";

    file.write(QJsonDocument(db).toJson(QJsonDocument::Compact));
    file.close();

    emit implementSaved();
    return "OK";
}

QVariantList Implement::loadAllImplements()
{
    QVariantList list;
    QFile file(implementDbPath);

    if (!file.open(QIODevice::ReadOnly))
        return list;

    QJsonObject db = QJsonDocument::fromJson(file.readAll()).object();
    file.close();

    for (auto key : db.keys()) {
        QVariantMap item = db.value(key).toObject().toVariantMap();
        item["id"] = key; // For ComboBox display
        list.append(item);
    }

    return list;
}

QString Implement::deleteImplementData(const QString &id)
{
    QFile file(implementDbPath);
    if (!file.open(QIODevice::ReadOnly))
        return "DB read failed";

    QJsonObject db = QJsonDocument::fromJson(file.readAll()).object();
    file.close();

    if (!db.contains(id))
        return "Not found";

    db.remove(id);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return "Write failed";

    file.write(QJsonDocument(db).toJson(QJsonDocument::Compact));
    file.close();

    emit implementDeleted();
    return "Deleted";
}
