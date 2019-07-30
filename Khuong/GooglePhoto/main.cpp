#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>
#include "googlephotoqueu.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

//    GoogleOAuth2 auth;
//    auth.Authenticate();
    GooglePhotoQueu q;
//    GooglePhoto p;
    return app.exec();
}


