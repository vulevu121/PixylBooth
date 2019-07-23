
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
    //this works
    p.CreateAlbumAndUploadPhoto("C:/Users/khuon/Documents/GooglePhoto_Gmail/rdm.jpg","new sea");
    //this doesnt work with above
    p.UploadPhotoToAlbum("C:/Users/khuon/Documents/GooglePhoto_Gmail/2.jpg");
    //This works
//    p.UploadPhotoToAlbum("C:/Users/khuon/Documents/GooglePhoto_Gmail/2.jpg","AJIwpNCZCdWFDnPJAeaZkiSkprgBSOHAUuE1ku-iekI_fBYwwez4Y64tW3XYXy8vgm8144_0bvEY");


    return app.exec();
}


