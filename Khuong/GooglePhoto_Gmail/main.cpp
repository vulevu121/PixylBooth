
#include "gmail.h"
#include "googlephoto.h"
#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>



int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
//    GMAIL g;
//    g.SetAlbumURL("https://photos.app.goo.gl/U59jf5pMxV1FHV4H8");
//    g.SetToEmail("khuong.dinh.ng@gmail.com");
//    g.SetFromEmail("khuongnguyensac@gmail.com");

    GooglePhoto p;
//    p.SetAlbumName("Default name");
//    p.SetTargetAlbumID("AJIwpNCxInDhwKm-5qIbArwKmV11yOejSzOIsQDixP_sLHHZx6k3Cgw24wzyPXzk0Lk71R6-IIx9");
    p.UploadPhoto("C:/Users/khuon/Documents/GooglePhoto_Gmail/3.jpg");
    return app.exec();
}


