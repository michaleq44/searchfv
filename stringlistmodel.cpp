#include "stringlistmodel.h"
#include "pugixml.hpp"

StringListModel::StringListModel(QObject *parent) : QAbstractListModel(parent) {}

int StringListModel::rowCount(const QModelIndex &) const {
    return m_list.size();
}

QVariant StringListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_list.size())
        return QVariant();
    if (role == Qt::DisplayRole || role == Qt::EditRole)
        return m_list.at(index.row());
    return QVariant();
}

bool StringListModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (index.isValid() && index.row() < m_list.size() && role == Qt::EditRole) {
        m_list.replace(index.row(), value.toString());
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}

Qt::ItemFlags StringListModel::flags(const QModelIndex &index) const {
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

void StringListModel::appendString(const QString &str) {
    beginInsertRows(QModelIndex(), m_list.size(), m_list.size());
    m_list.append(str);
    endInsertRows();
    emit countChanged();
}

Invoice StringListModel::parseInvoice(const QString &name) {
    pugi::xml_document doc;
    doc.load_file(name.toStdString().c_str());

    Invoice invoice;
    pugi::xml_node fvnode = doc.child("Faktura");
    pugi::xml_node datanode = fvnode.child("Fa");

    invoice.date = datanode.child("P_1").text().as_string();
    invoice.number = datanode.child("P_2").text().as_string();
    invoice.person1 = fvnode.child("Podmiot1").child("DaneIdentyfikacyjne").child("Nazwa").text().as_string();
    invoice.person2 = fvnode.child("Podmiot2").child("DaneIdentyfikacyjne").child("Nazwa").text().as_string();
    for (pugi::xml_node wiersz : datanode.children("FaWiersz")) {
        QString item = wiersz.child("P_7").text().as_string();
        invoice.products.push_back(item);
    }

    return invoice;
}

void StringListModel::appendToInvoices(const Invoice& invoice) {
    m_invoices.push_back(invoice);
}

void StringListModel::parseLastAndAddToInvoices() {
    appendToInvoices(parseInvoice(m_list.last()));
}

void StringListModel::removeAt(int index) {
    if (index < 0 || index >= m_list.size()) return;
    beginRemoveRows(QModelIndex(), index, index);
    m_list.removeAt(index);
    endRemoveRows();
    emit countChanged();
}

void StringListModel::clear() {
    if (m_list.isEmpty()) return;
    beginResetModel();
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void StringListModel::setStringList(const QStringList &list) {
    beginResetModel();
    m_list = list;
    endResetModel();
    emit countChanged();
}

void StringListModel::clickedItem(int index) {
    emit itemClicked(index, m_list.at(index));
}
