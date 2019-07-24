#include "googlephotoqueu.h"

GooglePhotoQueu::GooglePhotoQueu(QObject *parent) : QObject(parent)
{
    //this works
    p.CreateAlbumAndUploadPhoto("C:/Users/khuon/Documents/GooglePhoto/1.jpg","Lava");
    //this doesnt work with above
//    p.UploadPhotoToAlbum("C:/Users/khuon/Documents/GooglePhoto/2.jpg");
    //This works
//    p.UploadPhotoToAlbum("C:/Users/khuon/Documents/GooglePhoto/me.jpg","AJIwpNCUWbDJkI0j59oZlAHP1JDaZcx6VbBBJHVsvJdfjNyKpqULz0HR5tGcl6fXb65Lx_mV_JXw");


    email.SetToEmail("khuong.dinh.ng@gmail.com");
    email.SetFromEmail("khuongnguyensac@gmail.com");
    connect(&p,SIGNAL(albumShared(QString)),&email,SLOT(SetAlbumURL(QString)));
    connect(&email,SIGNAL(linkReady()),&email,SLOT(SendEmail()));
}
