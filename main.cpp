//#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
//#include <QtWebView>
#include "process.h"
#include "sonyapi.h"
#include "sonyliveview.h"
#include "printphotos.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<Process>("Process", 1, 0, "Process");
    qmlRegisterType<SonyAPI>("SonyAPI", 1, 0, "SonyAPI");
    qmlRegisterType<SonyLiveview>("SonyLiveview", 1, 0, "SonyLiveview");
    qmlRegisterType<PrintPhotos>("PrintPhotos", 1, 0, "PrintPhotos");

    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
//    QtWebView::initialize();
    
    app.setOrganizationName("PixylBooth");
    app.setOrganizationDomain("PixylBooth.com");
    app.setApplicationName("PixylBooth");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
