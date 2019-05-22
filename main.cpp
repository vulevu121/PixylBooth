//#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include "process.h"
#include "SonyAPI.h"
#include "SonyLiveview.h"
#include "ProcessPhotos.h"
#include "PrintPhotos.h"
#include "CSVFile.h"
//#include "MoveMouse.h"
#include "Firebase.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<Process>("Process", 1, 0, "Process");
    qmlRegisterType<SonyAPI>("SonyAPI", 1, 0, "SonyAPI");
    qmlRegisterType<SonyLiveview>("SonyLiveview", 1, 0, "SonyLiveview");
    qmlRegisterType<ProcessPhotos>("ProcessPhotos", 1, 0, "ProcessPhotos");
    qmlRegisterType<PrintPhotos>("PrintPhotos", 1, 0, "PrintPhotos");
    qmlRegisterType<CSVFile>("CSVFile", 1, 0, "CSVFile");
    qmlRegisterType<Firebase>("Firebase", 1, 0, "Firebase");


    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
//    QGuiApplication app(argc, argv);

    QtWebView::initialize();
    
    app.setOrganizationName("PixylBooth");
    app.setOrganizationDomain("PixylBooth.com");
    app.setApplicationName("PixylBooth");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
