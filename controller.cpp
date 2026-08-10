#include "controller.h"
#include <QSize>

Controller::Controller(StringListModel* fileModel, StringListModel* keywordModel, StringListModel* outputModel, QObject* parent)
: QObject(parent), m_fileModel(fileModel), m_keywordModel(keywordModel), m_outputModel(outputModel) {}

void Controller::scanAll() {
    m_outputModel->clear();
    QStringList keywords = m_keywordModel->stringList();
    QStringList files = m_fileModel->stringList();
    QList<Invoice> invoices = m_fileModel->invoices();

    if (invoices.isEmpty()) {
        emit showDialog("Lista plików jest pusta!");
        return;
    }
    if (keywords.isEmpty()) {
        emit showDialog("Lista słów kluczowych jest pusta!");
        return;
    }

    for (qsizetype i = 0; i < invoices.size(); i++) {
        Invoice invoice = invoices.at(i);
        QString file = files.at(i);
        bool found = false;
        for (QString product : invoice.products) {
            for (QString keyword : keywords) {
                if (product.contains(keyword, Qt::CaseInsensitive)) {
                    found = true;
                    break;
                }
            }
            if (found) {
                break;
            }
        }

        if (found) {
            m_outputModel->appendString(file);
            m_outputModel->appendToInvoices(invoice);
        }
    }

    if (m_outputModel->rowCount() == 0) {
        emit showDialog("Brak pasujących wyników");
    }
}
