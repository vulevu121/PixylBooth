#include "gphoto.h"

GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
    RequestAccessCode();
//    uploadBinary();
}

void GooglePhoto::RequestAccessCode(){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

        authEndpoint = QString("https://accounts.google.com/o/oauth2/auth");
        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary");
        response_type = QString("&response_type=code");
        redirect_uri = QString("&redirect_uri=http://127.0.0.1:8080/");
        client_id = QString("&client_id=1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com");


        QUrl url(authEndpoint + scope + response_type + redirect_uri + client_id);

//        qDebug()<< url;

        QNetworkRequest req(url);

        manager->get(req);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(AccessCodeReply(QNetworkReply*)));
}

void GooglePhoto::AccessCodeReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Access Code request success!";
        QUrl url = reply->url();
        QWebEngineView *view = new QWebEngineView;
        view->load(url);
        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(AccessCodeRedirectReply(QUrl)));
    }
    manager->disconnect();

}


void GooglePhoto::AccessCodeRedirectReply(QUrl url) {
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
        qDebug() << "C Success!";

        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);

        QJsonObject jsonObject = jsonDoc.object();

        token = jsonObject["access_token"].toString();
        qDebug() <<  token;
        manager->disconnect();
        UploadPicData();
    }


}

void GooglePhoto::UploadPicData(){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }

        QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
        QHttpPart imagePart;


//        QFile file("C:/Users/khuon/Documents/GooglePhoto/rdm.jpg");
        QFile file("C:/Users/khuon/Documents/GooglePhoto/IMG_20190418_140249.jpg");

//        qDebug() << "File exists:" << file.exists();

        file.open(QIODevice::ReadOnly);
        QByteArray fileBytes = file.readAll();
        file.close();


        imagePart.setBody(fileBytes);
        multiPart->append(imagePart);


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


//        manager->post(req, multiPart);
        manager->post(req, fileBytes);
        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(D_ReceivedReply(QNetworkReply*)));
}

void GooglePhoto::UploadReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Upload Success!";
        uploadToken = reply->readAll();
        qDebug() << "Upload Token: " << uploadToken << endl;
    }
    manager->disconnect();
    CreateMedia();
}


void GooglePhoto::CreateMedia(){
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

//    qDebug() << obj << endl;


    //to see the JSON output
    QJsonDocument doc (obj);
//    qDebug() << doc << endl; //this object works, but something goes wrong when convert to QJsonDocument


    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length", postDataSize);

      manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(E_ReceivedReply(QNetworkReply*)));
}

void GooglePhoto::CreateMediaReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << "E Error" << reply->readAll();
    } else {
        qDebug() << "E Success!";
//        qDebug() << reply->readAll();

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];


    }
    manager->disconnect();
}
