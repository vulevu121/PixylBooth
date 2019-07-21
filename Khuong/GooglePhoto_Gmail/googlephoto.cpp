#include "googlephoto.h"

GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
    accessToken = QString("ya29.GlxJBzGdZ8G2uLEwy7HZXfTFnltjMhQgj4ocn4VGNfLTp5zlqHlLuYKelkl478v-7-yvUwXoRKXDRDpSBCVtVEBklOk45Ym1PtotozTID0sr4oJNVYNo38UffBbmXQ");
    CreateAlbum("tonight album");
}
void GooglePhoto::UploadPicData(QString path_to_pic){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }
//        QFile file("C:/Users/khuon/Documents/GooglePhoto_Gmail/3.jpg");
        QFile file(path_to_pic);
        qDebug() << "File exists:" << file.exists();

        file.open(QIODevice::ReadOnly);
        QByteArray fileBytes = file.readAll();
        file.close();


        QNetworkRequest req (QUrl("https://photoslibrary.googleapis.com/v1/uploads"));
        req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());
        req.setRawHeader("Content-Type","application/octet-stream");
        req.setRawHeader("X-Goog-Upload-File-Name",file.fileName().toUtf8());
        req.setRawHeader("X-Goog-Upload-File-Name","rdm1.jpg");
        req.setRawHeader("X-Goog-Upload-Protocol", "raw");

//        qDebug() << req.rawHeader("Authorization");
//        qDebug() << req.rawHeader("X-Goog-Upload-File-Name");
//        qDebug() << req.rawHeader("X-Goog-Upload-Protocol");
//        qDebug() << req.rawHeader("Content-Type");


        manager->post(req, fileBytes);
        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(UploadReply(QNetworkReply*)));
}

void GooglePhoto::UploadReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Upload Success!";
        uploadToken = reply->readAll();
//        qDebug() << "Upload Token: " << uploadToken << endl;
    }
    manager->disconnect();
    CreateMediaInAlbum(albumID);
}


void GooglePhoto::CreateMediaInAlbum(QString albumID){
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    QJsonObject temp;
        temp["uploadToken"] = uploadToken;

    QJsonObject temp2;
    temp2 [ "description" ] = "my rdm";
    temp2 ["simpleMediaItem"] = temp;

    QJsonArray arr;
    arr.append(temp2);

    QJsonObject obj;
    obj ["newMediaItems"] = arr;


    /* Add media to provided album id if available */
    if (albumID.isEmpty()){
        qDebug() << "album ID not available";
      }else{
        qDebug() << "album ID available";
        obj ["albumId"] = albumID;

    }
    //to see the JSON output
    QJsonDocument doc (obj);


    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length", postDataSize);

      manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(CreateMediaReply(QNetworkReply*)));
}

void GooglePhoto::CreateMediaReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << "Create Media Error" << reply->readAll();
    } else {
        qDebug() << "Create Media Success!";

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];

    }
    manager->disconnect();

}

void GooglePhoto::CreateAlbum(QString new_album_name){
    qDebug() << "Creating new album!";

    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    QJsonObject obj;
    obj["title"] = new_album_name;

    QJsonObject jsonObj {
        {"album",obj}
    };

    QJsonDocument doc (jsonObj);


    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length", postDataSize);

    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(CreateAlbumReply(QNetworkReply*)));
}


void GooglePhoto::CreateAlbumReply(QNetworkReply * reply){
    if(reply->error()) {
        qDebug() << "Create Album Error" << reply->readAll();
    } else {
        qDebug() << "Create Album Success!";
//        qDebug() << reply->readAll();

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();


        albumID = jsonObj["id"].toString();
        qDebug() << "Album created:" << albumID;

          albumURL = jsonObj["productUrl"].toString();
          qDebug() << "Album link:" << albumURL;
     }
    manager->disconnect();

    ShareAlbum(albumID);

}

QString GooglePhoto::getAlbumId(){
    return GooglePhoto::albumID;
}

void GooglePhoto::GetAlbums(){
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    manager->get(req);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(GetAlbumsReply(QNetworkReply*)));
}

void GooglePhoto::GetAlbumsReply(QNetworkReply * reply){
    if(reply->error()) {
        qDebug() << "Get Shared Albums Error" << reply->readAll();
    } else {

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        qDebug() << jsonObj; //["mediaItems"].toArray()["mediaItem"].toObject()["description"];

     }
    manager->disconnect();
}

void GooglePhoto::ShareAlbum(QString AlbumID){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QString endpoint ("https://photoslibrary.googleapis.com/v1/albums/");

    QUrl reqURL(endpoint + AlbumID + QString(":share"));
    QNetworkRequest req(reqURL);
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());
    req.setRawHeader("Content-Type","application/json");

    QJsonObject temp{
        {"isCollaborative", "false"},
        {"isCommentable", "false"}
    };

    QJsonObject jsonObj{
        {"sharedAlbumOptions", temp}
    };

    QJsonDocument doc (jsonObj);

//    qDebug() << doc;

    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length", postDataSize);

    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(ShareAlbumReply(QNetworkReply*)));
}
void GooglePhoto::ShareAlbumReply(QNetworkReply * reply){
    if(reply->error()) {
        qDebug() << "Sharing Albums Error" << reply->readAll();
    } else {
        qDebug() << "Sharing Albums Success";

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        albumURL =  jsonObj["shareInfo"].toObject()["shareableUrl"].toString();
//        qDebug() << albumURL;

     }
    manager->disconnect();

    UploadPicData("C:/Users/khuon/Documents/GooglePhoto_Gmail/3.jpg");

}
