#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include "process.h"
#include "backend.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<Process>("Process", 1, 0, "Process");
    qmlRegisterType<BackEnd>("BackEnd", 1, 0, "BackEnd");
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
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
