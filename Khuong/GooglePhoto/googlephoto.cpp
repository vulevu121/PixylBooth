#include "googlephoto.h"

GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
//    auth.SetScopeRaw("https://www.googleapis.com/auth/photoslibrary"); // for list album

    auth.SetScope(); // default scope is google photo
    auth.Authenticate();   //Share scope cannot querry for list of albums from Google Photo
    connect(&auth,SIGNAL(tokenReady(QString)),this,SLOT(SetAccessToken(QString)));
}


void GooglePhoto::SetTargetAlbumToUpload(QString id){
    albumID = id;
    emit albumIdChanged();
//    qDebug() << albumID;
}


void GooglePhoto::SetAccessToken(QString token){
    accessToken = token;
    emit accessTokenSaved();
}

void GooglePhoto::SetAlbumName(QString name){
    albumName = name;
}


void GooglePhoto::CreateAlbumAndUploadPhoto(QString pathToPic, QString albumName){
    pathToFile = pathToPic;
    SetAlbumName(albumName);
    /* Query list of albums */
//    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(GetAlbums()));

    /* Create a new album, make album shareable, and upload a photo*/
    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(CreateAlbum()));
    connect(this,SIGNAL(albumCreated()),this,SLOT(ShareAlbum()));

    connect(this,SIGNAL(albumShared(QString)),this,SLOT(UploadPicData()));
    connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));

}

void GooglePhoto::UploadPhotoToAlbum(QString pathToPic, QString id){
    pathToFile = pathToPic;
    qDebug()<< "token is Null:" <<!accessToken.isNull();
    qDebug() << "ID is Null:" << id.isNull();

    /* if token is not available but an existing album ID is provided. Needs to wait for access token */
    if(accessToken.isNull() && !id.isNull()){
        qDebug() << "uploading to existing album w/o a token, but w/ an album ID";
        SetTargetAlbumToUpload(id);
        connect(this,SIGNAL(accessTokenSaved()),this,SLOT(UploadPicData()));
        connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));

    }//Need to figure out the logic for this: Create album and upload a photo, then immediately upload another photo to that album
    /* otherise, if token is available but album ID is NOT provided, we are uploading a photo into a existing album created by the step just before */
    else if(!accessToken.isNull() && id.isNull() ){
        qDebug() << " Uploading a photo AFTER the album has been created. The token is already saved";
        /* wait until createAlbumAndUploadPhoto is done first */
        connect(this,SIGNAL(mediaCreated()),this,SLOT(UploadPicData()));
        connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));
        }
    /* album is already created, shared and albumID is available, upload photo data */
    else{
        qDebug() << "Undefined case";
        return;
        }

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
        manager->disconnect();

    } else {
        qDebug() << "Create Media Success!";
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();
        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];
        manager->disconnect();
        emit mediaCreated();
    }

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
//        qDebug() << "Album link:" << albumURL;
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
        emit albumShared(albumURL);

     }

}
/* Must use non-sharing scope when request OAuth2 for those functions */
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

        qDebug() << jsonObj;

     }
    manager->disconnect();
}
