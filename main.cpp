#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QFile>
#include <QtQuickControls2/QQuickStyle>

#include "stringlistmodel.h"
#include "detailsprovider.h"
#include "controller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Fusion");

    Q_INIT_RESOURCE(appsearchfv_raw_qml_0);
    Q_INIT_RESOURCE(qmake_searchfv);

    StringListModel fileModel;
    StringListModel keywordModel;
    StringListModel outputModel;

    DetailsProvider detailsProvider;
    Controller controller(&fileModel, &keywordModel, &outputModel);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("fileModel", &fileModel);
    engine.rootContext()->setContextProperty("keywordModel", &keywordModel);
    engine.rootContext()->setContextProperty("outputModel", &outputModel);
    engine.rootContext()->setContextProperty("detailsProvider", &detailsProvider);
    engine.rootContext()->setContextProperty("controller", &controller);
    QObject::connect(
        &outputModel,
        &StringListModel::itemClicked,
        [&](int index, QString text){
            Invoice invoice = outputModel.invoices().at(index);
            auto infotext = QString("Numer faktury: %1\nSprzedający: %2\nKupujący: %3\nProdukty:\n")
                                .arg(invoice.number, invoice.person1, invoice.person2);
            for (QString item : invoice.products) {
                infotext += " - " + item + "\n";
            }
            detailsProvider.setDetailsText(infotext);
        });

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    QStringList possibleQMLPaths = {
        ":/qt/qml/searchfv/Main.qml",
        ":/searchfv/Main.qml",
        ":/Main.qml"
    };
    for (const QString &path : possibleQMLPaths) {
        if (QFile::exists(path)) {
            qDebug() << "Found QML at:" << path;
            engine.load(QUrl("qrc" + path));
            break;
        }
    }

    return app.exec();
}
