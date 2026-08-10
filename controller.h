#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include "stringlistmodel.h"

class Controller : public QObject {
    Q_OBJECT
public:
    explicit Controller(StringListModel *fileModel,
                        StringListModel *keywordModel,
                        StringListModel *outputModel,
                        QObject *parent = nullptr);

    Q_INVOKABLE void scanAll();

signals:
    void showDialog(const QString &msg);

private:
    StringListModel *m_fileModel;
    StringListModel *m_keywordModel;
    StringListModel *m_outputModel;
};

#endif
