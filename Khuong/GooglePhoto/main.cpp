#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>
#include "googlephotoqueu.h"
//#include "googleoauth2.h"
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

//    GoogleOAuth2 auth;
//    auth.Authenticate();
    GooglePhotoQueu q;
//    GooglePhoto p;
//    p.CreateAlbumAndUploadPhoto("C:/Users/khuon/Documents/GooglePhoto/me.jpg","Ice");
    return app.exec();
}


