#include "gphoto.h"


GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }




//    QByteArray val;
//    QFile file;
//    file.setFileName(QDir::toNativeSeparators("C:/Users/khuon/Documents/GooglePhoto/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json"));
//    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
//    {
//        val = file.readAll();
//        file.close();
//    }

//        QJsonDocument document = QJsonDocument::fromJson(val);
//        QJsonObject object = document.object();
//        const auto settingsObject = object["web"].toObject();
//        const QUrl authUri(settingsObject["auth_uri"].toString());
//        const auto clientId = settingsObject["client_id"].toString();
//        const QUrl tokenUri(settingsObject["token_uri"].toString());
//        const auto clientSecret(settingsObject["client_secret"].toString());

//        const auto redirectUris = settingsObject["redirect_uris"].toArray();
//        const QUrl redirectUri(redirectUris[0].toString());
//        const auto port = static_cast<quint16>(redirectUri.port());

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
                this, SLOT(A_ReceivedReply(QNetworkReply*)));
}


void GooglePhoto::A_ReceivedReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "A Success!";
        QUrl url = reply->url();
        QWebEngineView *view = new QWebEngineView;
        view->load(url);
        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(B_ReceivedReply(QUrl)));
    }
    manager->disconnect();

}


void GooglePhoto::B_ReceivedReply(QUrl url) {
    qDebug() << "B Success!";
    QString url_string(url.toString());
    url_string.replace("?","&");
    QStringList list  = url_string.split(QString("&"));
//    qDebug() << list;
    authCode = list.at(1);
//    qDebug() << authCode;

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
            this, SLOT(C_ReceivedReply(QNetworkReply*)));
}

void GooglePhoto::C_ReceivedReply(QNetworkReply *reply) {
    if(reply->error()) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        qDebug() << jsonObject["error"].toObject()["message"].toString();
    } else {
        qDebug() << "C Success!";

        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        token = jsonObject["access_token"].toString();
        qDebug() <<  token;

    }
    manager->disconnect();
    uploadBinary();

}

void GooglePhoto::uploadBinary(){
        qDebug() << "Uploading binary";

        if (manager == nullptr) {
             manager = new QNetworkAccessManager(this);
         }

        QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
        QHttpPart imagePart;
//        imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
//        imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\""));
        QFile *file = new QFile("C:/Users/khuon/Documents/GooglePhoto/me.jpg");
        file->open(QIODevice::ReadOnly);
        imagePart.setBodyDevice(file);
        file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart
        multiPart->append(imagePart);



        QNetworkRequest req (QUrl("https://photoslibrary.googleapis.com/v1/uploads"));
//        token = "ya29.Gls6B4jX4XDNIQdKo4vMpMhcjBOHatW3tseUtyZMJYUOJ90Sxlg14rjpBbBx77BmDrJqMiXNRV4-y_24peVwF5qgKKkh6Rq_jo6oX0ljbHyBoaJMavhSsrRxLl6W"
        req.setRawHeader("Authorization","Bearer "+ token.toUtf8());
        req.setRawHeader("Content-Type","application/octet-stream");
        req.setRawHeader("X-Goog-Upload-File-Name",file->fileName().toUtf8());
        req.setRawHeader("X-Goog-Upload-File-Name","rdm.jpg");
        req.setRawHeader("X-Goog-Upload-Protocol", "raw");

//        qDebug() << req.rawHeader("Authorization");
//        qDebug() << req.rawHeader("X-Goog-Upload-File-Name");
//        qDebug() << req.rawHeader("X-Goog-Upload-Protocol");
//        qDebug() << req.rawHeader("Content-Type");


        manager->post(req, multiPart);
        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(D_ReceivedReply(QNetworkReply*)));
}

void GooglePhoto::D_ReceivedReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "D Success!";
        uploadToken = reply->readAll();
        qDebug() << uploadToken << endl;
    }
    manager->disconnect();
    createMedia();
}

void GooglePhoto::createMedia(){
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
    QNetworkRequest req(endpoint);
//    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::MixedType);

    QHttpPart textPart;
//    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"text\""));
//    textPart.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//    textPart.setRawHeader("Content-Type","application/json");

    QJsonObject temp;
        temp["uploadToken"] = QString("CAISmQMASsyg4Mlj+Z95bIqEZ17qXHmEmwQ4QzYKTyRYelCGgi7PfP3HWAtg+68PLWAMuBEUOWZP/j9cW8tbgOsK4ih3pqbck+3+lmJIzNAQ9Rvqx5zyQXZ0zoYTHeI6t8K+1hXitKMBgBlpRsbpxi/zP4odm6KAUnKL8wh3eeFYIBkUC1EBaKyUcg/0V/+17Smu4Dms+sQ/fdb3l8RYJ0RrZvypCS+P/Fm7UICcIGvQ5knM1LPDSkbtO/pwc2bQwKu9MDO5pWEEklj80PyqvrB7uDXdkG+NRwN934n/dlKfFKDkB3Rv0cgJHZrRNpOFVzBWIzelEojDa9jcFItZiMydTlorqpTGUrdPovFBu3B9OTQN3FG7D0Tjkx0Px6oAPya/l10+sGASnx78CH6mHUjatnuusj83VOMGwcOjmEa1DA8Gnajy8TiTfKqi6K0xYWH/rvpqDAbWbE0jqQZhcQtQCp5BEy7J1w2vPQstWhDd1LD7NoPMith6+v3V4TkGgD9Zl0kaVuW2gwj3KE+iWOt7ISoZIFfBY7hadasx");
               // uploadToken;

    QJsonObject temp2;
    temp2 [ "description" ] = "my photo";
    temp2 ["simpleMediaItem"] = temp;

    QJsonArray arr;
    arr.append(temp2);

    QJsonObject obj;
    obj ["newMediaItems"] = arr;

    qDebug() << obj << endl;  //this object works, but something goes wrong when convert to QJsonDocument


    //to see the JSON output
    QJsonDocument doc (obj);
    qDebug() << doc << endl; //this object works, but something goes wrong when convert to QJsonDocument


    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    textPart.setRawHeader("Content-Length", postDataSize);

    qDebug() << jsonRequest << endl;

    textPart.setBody(jsonRequest);
    multiPart->append(textPart);

    manager->post(req,multiPart);
//      manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(E_ReceivedReply(QNetworkReply*)));
}

void GooglePhoto::E_ReceivedReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << "E Error" << reply->readAll();
    } else {
        qDebug() << "E Success!";
        qDebug() << reply->readAll();
    }
    manager->disconnect();
}
