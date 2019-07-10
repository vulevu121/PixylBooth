#include "gphoto.h"

GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
    RequestAuthCode();
}

void GooglePhoto::RequestAuthCode(){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

        authEndpoint = QString("https://accounts.google.com/o/oauth2/auth");
//        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary"); //scope for all access except sharing

        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary.sharing"); // scope for sharing
        response_type = QString("&response_type=code");
        redirect_uri = QString("&redirect_uri=http://127.0.0.1:8080/");
        client_id = QString("&client_id=1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com");
        inputAlbumName = QString("My shared album");

        QUrl url(authEndpoint + scope + response_type + redirect_uri + client_id);

//        qDebug()<< url;

        QNetworkRequest req(url);

        manager->get(req);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(AuthCodeReply(QNetworkReply*)));
}

void GooglePhoto::AuthCodeReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Access Code request success!";
        QUrl url = reply->url();
        QWebEngineView *view = new QWebEngineView;
        view->load(url);
        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(AuthCodeRedirectReply(QUrl)));
    }
    manager->disconnect();

}


void GooglePhoto::AuthCodeRedirectReply(QUrl url) {
    qDebug() << "Access Code Received!";
    QString url_string(url.toString());

    /* Extract the access code from the URI */
    url_string.replace("?","&");
    QStringList list  = url_string.split(QString("&"));
//    qDebug() << list;
    authCode = list.at(1);
//    qDebug() << authCode;
    RequestAccessToken();
}

void GooglePhoto::RequestAccessToken(){
    /* Exchange the access code for access token */
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    tokenEndpoint = QString("https://www.googleapis.com/oauth2/v4/token?");
    client_secret = QString("&client_secret=tIML2i8JEn2oR7K0XQ-GNepp");
    grant_type  = QString("&grant_type=authorization_code");

    QUrl urlToken(tokenEndpoint+ authCode+client_id+client_secret+redirect_uri+grant_type);
    QNetworkRequest req(urlToken);
    req.setRawHeader("Content-Type","application/x-www-form-urlencoded");

//     qDebug() << urlToken;
     QByteArray data;
    manager->post(req,data);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(AccessTokenReply(QNetworkReply*)));
}

void GooglePhoto::AccessTokenReply(QNetworkReply *reply) {
    if(reply->error()) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();
        qDebug() << jsonObject["error"].toObject()["message"].toString();
        manager->disconnect();

    } else {
        qDebug() << "Token Received!";

        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);

        QJsonObject jsonObject = jsonDoc.object();

        token = jsonObject["access_token"].toString();
        qDebug() <<  token;
        manager->disconnect();

        UploadPicData();
//        CreateAlbum("Made by Qt");
//        GetAlbums();
//        ShareAlbum("AJIwpNCWJXch_FSn4sOy_T2qHRVMGGZ2uHK_BzSKTMuqTSSlxd8NYLGpLlyPNShUt1w_ym5gTJIW");

    }

}

void GooglePhoto::UploadPicData(){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }


//        QFile file("C:/Users/khuon/Documents/GooglePhoto/rdm.jpg");
        QFile file("C:/Users/khuon/Documents/GooglePhoto/IMG_20190418_140249.jpg");

//        qDebug() << "File exists:" << file.exists();

        file.open(QIODevice::ReadOnly);
        QByteArray fileBytes = file.readAll();
        file.close();


        QNetworkRequest req (QUrl("https://photoslibrary.googleapis.com/v1/uploads"));
        req.setRawHeader("Authorization","Bearer "+ token.toUtf8());
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
//    CreateMedia();
    CreateAlbum(inputAlbumName);
}


void GooglePhoto::CreateMedia(QString AlbumID){
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

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
    if (AlbumID.isEmpty()){
        qDebug() << "album ID not available";
      }else{
        qDebug() << "album ID available";
        obj ["albumId"] = AlbumID;

    }


    //to see the JSON output
    QJsonDocument doc (obj);
//    qDebug() << doc << endl; //this object works, but something goes wrong when convert to QJsonDocument


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
//        qDebug() << reply->readAll();

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];

    }
    manager->disconnect();

}

void GooglePhoto::CreateAlbum(QString album_name){
    qDebug() << "Creating new album!";

    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
    QNetworkRequest req(endpoint);
    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

    QJsonObject obj;
    obj["title"] = album_name;

    QJsonObject jsonObj {
        {"album",obj}
    };

    QJsonDocument doc (jsonObj);

//    qDebug() << doc;

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
//        qDebug() << "Create Album Success!";
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
    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

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
    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());
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

//        qDebug() << jsonObj;
        shareableURL =  jsonObj["shareInfo"].toObject()["shareableUrl"].toString();
        qDebug() << shareableURL;

     }
    manager->disconnect();
    CreateMedia(albumID);


}
