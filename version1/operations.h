#ifndef OPERATIONS_H
#define OPERATIONS_H

#include <QObject>
#include <QVariant>

class Operations : public QObject
{
    Q_OBJECT
public:
    explicit Operations(QObject *parent = nullptr);

public slots:
    QString saveTractorData(const QVariantMap &tractorData);
    QVariantList loadAllTractors();
    bool deleteTractorData(const QString &tractorName);

signals:
    void tractorSaved();
    void tractorDeleted(const QString &name);

private:
    QString tractorDbPath;
};

#endif // OPERATIONS_H
