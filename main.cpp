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
#include "SerialControl.h"
//#include "QRGenerator.h"
#include "SMSEmail.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<ProcessPhotos>("ProcessPhotos", 1, 0, "ProcessPhotos");
    qmlRegisterType<PrintPhotos>("PrintPhotos", 1, 0, "PrintPhotos");
//    qmlRegisterType<Firebase>("Firebase", 1, 0, "Firebase");
    qmlRegisterType<SonyRemote>("SonyRemote", 1, 0, "SonyRemote");
    qmlRegisterType<SMSEmail>("SMSEmail", 1, 0, "SMSEmail");
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QFont font("Consolas");
    app.setFont(font);
    
    app.setOrganizationName("Pixyl");
    app.setOrganizationDomain("gopixyl.com");
    app.setApplicationName("PixylBooth");

    QSettings *settings = new QSettings("Pixyl", "PixylBooth");
    settings->setValue("exePath", app.applicationFilePath());
    settings->setValue("version", app.applicationVersion());

    QQmlApplicationEngine engine;
//    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.load(QUrl(QStringLiteral("qrc:/TemplateEditor.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
