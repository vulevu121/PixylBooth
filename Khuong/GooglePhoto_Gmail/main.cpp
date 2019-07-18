
#include "gmail.h"
#include "googleoauth2.h"
#include "googlephoto.h"
#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>


void printOut(QString text);

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    GoogleOAuth2 auth;
//    auth.RequestAuthCode();
//    auth.RequestAuthCode("GMAIL");

//    QObject::connect(auth, SIGNAL(tokenReady()),this,SLOT(printOut(QString)));
//    GMAIL g;
    GooglePhoto p;
    return app.exec();
}


void printOut(QString text){
    qDebug() << text;
    return;
}
