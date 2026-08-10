#ifndef STRINGLISTMODEL_H
#define STRINGLISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>

struct Invoice {
    QString number;
    QString person1, person2;
    QString date;
    QList<QString> products;
};

class StringListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    public:
    explicit StringListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    int count() const { return m_list.size(); }

    QStringList stringList() const { return m_list; }
    QList<Invoice> invoices() const { return m_invoices; }
    Q_INVOKABLE void setStringList(const QStringList &list);
    Q_INVOKABLE void appendString(const QString &str);
    static Invoice parseInvoice(const QString &name);
    Q_INVOKABLE void appendToInvoices(const Invoice &invoice);
    Q_INVOKABLE void parseLastAndAddToInvoices();
    Q_INVOKABLE void removeAt(int index);
    Q_INVOKABLE void clear();
    //void moveUp(int index);
    //void moveDown(int index);
    Q_INVOKABLE void clickedItem(int index);

    signals:
    void countChanged();
    void itemClicked(int index, QString text);

    private:

    QStringList m_list;
    QList<Invoice> m_invoices;
};

#endif
