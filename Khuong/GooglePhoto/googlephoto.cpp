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
    emit authenticated();
}

void GooglePhoto::SetAlbumName(QString name){
    albumName = name;

}

void GooglePhoto::SetAlbumDescription(QString note){
    albumDescription = note;
}

void GooglePhoto::SetPathToFile(QString path){
    qDebug() << path << "changed";
    emit pathToFileChanged(path);
}

//void GooglePhoto::CreateAlbumAndUploadPhoto(QString pathToPic, QString albumName){
//    pathToFile = pathToPic;
//    SetAlbumName(albumName);
//    /* Query list of albums */
////    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(GetAlbums()));

//    /* Create a new album, make album shareable, and upload a photo*/
//    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(CreateAlbum()));
//    connect(this,SIGNAL(albumCreated()),this,SLOT(ShareAlbum()));

//    connect(this,SIGNAL(albumShared(QString)),this,SLOT(UploadPicData()));
//    connect(this,SIGNAL(uploadTokenReceived()),this,SLOT(CreateMediaInAlbum()));

//}


void GooglePhoto::CreateAlbumByName(QString albumName){
    SetAlbumName(albumName);
    /* Create a new album, make album shareable, and upload a photo*/
    connect(this,SIGNAL(accessTokenSaved()),this,SLOT(CreateAlbum()));
    connect(this,SIGNAL(albumCreated(QString)),this,SLOT(ShareAlbum()));
}

void GooglePhoto::UploadPhoto(QString pathToPic){

    qDebug() << "Uploading to existing album...";

    if(accessToken.isEmpty()){
        qDebug() << "No access token!";
        return;
    }
    else if (pathToPic.isEmpty()){
        qDebug() << "No path to file!";
        return;
    }
    else if (albumID.isEmpty()){
        qDebug() << "No target upload album ID!";
        return;
     }


    /* Disconnect all previous connection to avoid multiple trigger */
    this->disconnect();
    /* Start uploading */
    UploadPicData(pathToPic);
    connect(this,SIGNAL(uploadTokenReceived(QString)),this,SLOT(CreateMediaInAlbum(QString)));
}


void GooglePhoto::AppendUploadTokenList(QString token){
    uploadTokenList.append(token);
    qDebug() << "Upload Token List";
    foreach(QString t, uploadTokenList){
        qDebug() << t << endl;
    }
}



void GooglePhoto::UploadPicData(QString path){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }
        /* set to false at the beginning of every upload */
        Uploading = true;

        QFile file(path);
        fileName  = file.fileName();
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

bool GooglePhoto::isUploading(){
    return Uploading;
}

void GooglePhoto::UploadReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
        manager->disconnect();

    } else {
        qDebug() << "Upload Binary Data Success!";
        uploadToken = QString(reply->readAll());
        manager->disconnect();
        emit uploadTokenReceived(uploadToken);

     }
}

void GooglePhoto::CreateMultipleMediaInAlbum(){
    qDebug() << "Creating multiple medias in Album";
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    /* Json request */
    if(albumDescription.isEmpty()){
        albumDescription = QString("Description not available");
     }

    QJsonArray arr;
    foreach(QString t, uploadTokenList){
        QJsonObject tokenPart;
            tokenPart["uploadToken"] = uploadToken;


        QJsonObject item;
        item [ "description" ] = albumDescription;
        item ["simpleMediaItem"] = tokenPart;
        arr.append(item);
    }

    QJsonObject obj;
    obj ["newMediaItems"] = arr;

    /* Add media to provided album id if available */
    if (albumID.isEmpty()){
        qDebug() << "album ID not available";
      }else{
        qDebug() << "album ID available";
        obj ["albumId"] = albumID;

    }

    qDebug() << obj;

    //to see the JSON output
    QJsonDocument doc (obj);


    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length", postDataSize);

    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(CreateMediaReply(QNetworkReply*)));
}

void GooglePhoto::CreateMediaInAlbum(QString token){
    qDebug() << "Creating media in Album";
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());

    QJsonObject temp;
        temp["uploadToken"] = token;

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
//        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];
        manager->disconnect();
        Uploading = false;
        manager->disconnect();
        emit mediaCreated(fileName);
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
        albumReady = true;
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

QString GooglePhoto::GetAlbumID(){
    return albumID;
}
