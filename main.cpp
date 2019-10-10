//#include <QGuiApplication>
#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
//#include <QtWebView/QtWebView>
//#include "process.h"
//#include "SonyAPI.h"
//#include "SonyLiveview.h"
#include "ProcessPhotos.h"
#include "PrintPhotos.h"
//#include "CSVFile.h"
//#include "MoveMouse.h"
#include "Firebase.h"
#include "SonyRemote.h"
//#include "QRGenerator.h"

int main(int argc, char *argv[])
{
//    qmlRegisterType<Process>("Process", 1, 0, "Process");
//    qmlRegisterType<SonyAPI>("SonyAPI", 1, 0, "SonyAPI");
//    qmlRegisterType<SonyLiveview>("SonyLiveview", 1, 0, "SonyLiveview");
    qmlRegisterType<ProcessPhotos>("ProcessPhotos", 1, 0, "ProcessPhotos");
    qmlRegisterType<PrintPhotos>("PrintPhotos", 1, 0, "PrintPhotos");
//    qmlRegisterType<CSVFile>("CSVFile", 1, 0, "CSVFile");
//    qmlRegisterType<Firebase>("Firebase", 1, 0, "Firebase");
    qmlRegisterType<SonyRemote>("SonyRemote", 1, 0, "SonyRemote");
//    qmlRegisterType<QRGenerator>("QRGenerator", 1, 0, "QRGenerator");

//    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
//    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    QGuiApplication app(argc, argv);

//    app.setOrganizationName("PixylBooth");
//    app.setOrganizationDomain("PixylBooth");
//    app.setApplicationName("PixylBooth");

//    QQmlApplicationEngine engine;
//    const QUrl url(QStringLiteral("qrc:/main.qml"));
//    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
//                     &app, [url](QObject *obj, const QUrl &objUrl) {
//        if (!obj && url == objUrl)
//            QCoreApplication::exit(-1);
//    }, Qt::QueuedConnection);
//    engine.load(url);
//    return app.exec();

    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
//    QGuiApplication app(argc, argv);
//    QtWebView::initialize();
    
    app.setOrganizationName("Pixyl");
    app.setOrganizationDomain("gopixyl.com");
    app.setApplicationName("PixylBooth");

    QSettings *settings = new QSettings("Pixyl", "PixylBooth");
    settings->setValue("exePath", app.applicationFilePath());
    settings->setValue("version", app.applicationVersion());

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
