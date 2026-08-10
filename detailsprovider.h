#ifndef DETAILSPROVIDER_H
#define DETAILSPROVIDER_H

#include <QObject>

class DetailsProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString detailsText READ detailsText NOTIFY detailsTextChanged)

public:
    explicit DetailsProvider(QObject *parent = nullptr);

    QString detailsText() const { return m_detailsText; }

public slots:
    void setDetailsText(const QString &text);

signals:
    void detailsTextChanged();

private:
    QString m_detailsText;
};

#endif
