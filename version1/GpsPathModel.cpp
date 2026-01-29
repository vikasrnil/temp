#include "GpsPathModel.h"

GpsPathModel::GpsPathModel(QObject *parent) : QAbstractListModel(parent)
{
}

int GpsPathModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_path.size();
}

QVariant GpsPathModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_path.size())
        return QVariant();

    const QGeoCoordinate &point = m_path.at(index.row());
    switch (role) {
    case LatitudeRole:  return point.latitude();
    case LongitudeRole: return point.longitude();
    default:            return QVariant();
    }
}

QHash<int, QByteArray> GpsPathModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[LatitudeRole] = "latitude";
    roles[LongitudeRole] = "longitude";
    return roles;
}

void GpsPathModel::addPoint(double lat, double lng)
{
    beginInsertRows(QModelIndex(), m_path.size(), m_path.size());
    m_path.append(QGeoCoordinate(lat, lng));
    endInsertRows();

    emit pointAdded(lat, lng);
}

void GpsPathModel::clear()
{
    if (m_path.isEmpty())
        return;

    beginResetModel();
    m_path.clear();
    endResetModel();

    emit pathUpdated();
}

QList<QGeoCoordinate> GpsPathModel::path() const
{
    return m_path;
}
