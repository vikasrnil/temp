#ifndef FARMBACKEND_H
#define FARMBACKEND_H

#include <QObject>
#include <QStringList>

class FarmBackend : public QObject
{
    Q_OBJECT
public:
    explicit FarmBackend(QObject *parent = nullptr);

    Q_INVOKABLE bool saveFarm(const QString &farmName, const QString &jsonArray);
    Q_INVOKABLE QString loadFarm(const QString &farmName);
    Q_INVOKABLE QStringList listFarms();
    Q_INVOKABLE bool deleteFarm(const QString &farmName);

signals:
    void farmSaved();
    void farmDeleted();

private:
    QString farmDbPath;
};

#endif // FARMBACKEND_H
