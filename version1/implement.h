#ifndef IMPLEMENT_H
#define IMPLEMENT_H

#include <QObject>
#include <QVariant>

class Implement : public QObject
{
    Q_OBJECT
public:
    explicit Implement(QObject *parent = nullptr);

public slots:
    QString saveImplementData(const QVariantMap &implementData);       // create or update
    QVariantList loadAllImplements();                                   // load all
    QString deleteImplementData(const QString &name);                   // delete

signals:
    void implementSaved();
    void implementDeleted();

private:
    QString implementDbPath;
};

#endif // IMPLEMENT_H
