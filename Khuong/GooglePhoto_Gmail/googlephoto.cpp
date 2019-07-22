#include "googlephoto.h"

GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
//    accessToken = QString("ya29.Gl1NB7_UvfBelOC2AHlH1mr1GZ630PzOfGnJAiF6xCGc9c5sGyApeQpl5rh15o8Nu-XXyS03AJ6NzNxCWY1n-Vabb8jOaIT2lqVmef9AOJGghnvzMn_k19KrD7ty4kQ");
//    SetAlbumName("Default");
//    CreateAlbum();
//    connect(this, SIGNAL(albumCreated()),this, SLOT(ShareAlbum()));
}

void GooglePhoto::GetAccess(){
    auth.SetScope(); // default scope is google photo
    auth.SetScopeRaw("https://www.googleapis.com/auth/photoslibrary");
//    auth.RequestAuthCode();   //Share scope cannot querry for list of albums from Google Photo
    connect(&auth,SIGNAL(tokenReady(QString)),this,SLOT(SetAccessToken(QString)));
}

void GooglePhoto::SetTargetAlbumID(QString id){
    albumID = id;
//    qDebug() << albumID;
}


void GooglePhoto::SetAccessToken(QString token){
    accessToken = token;
    emit accessTokenSaved();
}

void GooglePhoto::SetAlbumName(QString name){
    albumName = name;
}


void GooglePhoto::UploadPhoto(QString pathToPic){
    pathToFile = pathToPic;
    GetAccess();
    /* Query list of albums */
    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(GetAlbums()));

//    if(albumID.isEmpty()){
//        /* No album ID was provided. Create a new album*/
//        connect(this,SIGNAL(accessTokenSaved()),this,SLOT(CreateAlbum()));
//        connect(this,SIGNAL(albumCreated()),this,SLOT(ShareAlbum()));
//        connect(this,SIGNAL(albumShared()),this,SLOT(UploadPicData()));
//        connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));

//    }else{
//        /* Album ID (should have Shared setting) available. Create media thre */
//        connect(this,SIGNAL(accessTokenSaved()),this,SLOT(UploadPicData()));
//        connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));
//    }

}
void GooglePhoto::UploadPicData(){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }
        QFile file(pathToFile);
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

        manager->post(req, fileBytes);
        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(UploadReply(QNetworkReply*)));
}

void GooglePhoto::UploadReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
        manager->disconnect();

    } else {
        qDebug() << "Upload Binary Data Success!";
        uploadToken = QString(reply->readAll());
        manager->disconnect();
        emit uploadTokenReceived();

     }
}


void GooglePhoto::SetAlbumDescription(QString note){
    albumDescription = note;
}

void GooglePhoto::CreateMediaInAlbum(){
    qDebug() << "Creating media in Album";
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    QJsonObject temp;
        temp["uploadToken"] = uploadToken;

    if(albumDescription.isEmpty()){
        albumDescription = QString("Not available");
     }

    QJsonObject temp2;
    temp2 [ "description" ] = albumDescription;
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
    qDebug() << albumID;
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

void GooglePhoto::CreateAlbum(){
    qDebug() << "Creating new album!";
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    QJsonObject obj;
    obj["title"] = albumName;

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
        manager->disconnect();

    } else {
        qDebug() << "Create Album Success!";

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();


        albumID = jsonObj["id"].toString();
        qDebug() << "Album created! ID:" << albumID;

        albumURL = jsonObj["productUrl"].toString();
        qDebug() << "Album link:" << albumURL;
        manager->disconnect();
        emit albumCreated();

     }

}



void GooglePhoto::ShareAlbum(){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QString endpoint ("https://photoslibrary.googleapis.com/v1/albums/");

    QUrl reqURL(endpoint + albumID + QString(":share"));
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
        manager->disconnect();

    } else {
        qDebug() << "Sharing Albums Success";

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        albumURL =  jsonObj["shareInfo"].toObject()["shareableUrl"].toString();
//        qDebug() << albumURL;
        manager->disconnect();
        emit albumShared();

     }

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
