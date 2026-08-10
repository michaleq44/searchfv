#include "detailsprovider.h"

DetailsProvider::DetailsProvider(QObject *parent) : QObject(parent) {}

void DetailsProvider::setDetailsText(const QString &text) {
    if (m_detailsText != text) {
        m_detailsText = text;
        emit detailsTextChanged();
    }
}