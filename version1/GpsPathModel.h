#ifndef GPSPATHMODEL_H
#define GPSPATHMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QList>

class GpsPathModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit GpsPathModel(QObject *parent = nullptr);

    enum Roles {
        LatitudeRole = Qt::UserRole + 1,
        LongitudeRole
    };
    Q_ENUM(Roles)  // exposes roles to QML

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addPoint(double lat, double lng);
    void clear();
    QList<QGeoCoordinate> path() const;

signals:
    void pointAdded(double lat, double lng);
    void pathUpdated();

private:
    QList<QGeoCoordinate> m_path;
};

#endif // GPSPATHMODEL_H

