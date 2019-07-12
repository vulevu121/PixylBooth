#include "gmail.h"

Gmail::Gmail(QObject *parent) : QObject(parent)
{
    G_RequestAuthCode();
}

void Gmail::G_RequestAuthCode(){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QFile jsonFile("C:/Users/khuon/Documents/GooglePhoto/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json");
    jsonFile.open(QFile::ReadOnly);
    QJsonDocument document = QJsonDocument().fromJson(jsonFile.readAll());

    const auto object = document.object();
    const auto settingsObject = object["web"].toObject();


        authEndpoint = settingsObject["auth_uri"].toString();

          tokenEndpoint = settingsObject["token_uri"].toString() + "?";

        scope = QString("?scope=https://www.googleapis.com/auth/gmail.compose"); // Create, read, update, and delete drafts. Send messages and drafts.

        response_type = QString("&response_type=code");

        redirect_uri = QString("&redirect_uri=" + settingsObject["redirect_uris"].toArray()[0].toString());

        client_id = "&client_id=" + settingsObject["client_id"].toString();

        client_secret = "&client_secret=" + settingsObject["client_secret"].toString();

        QUrl url(authEndpoint + scope + response_type + redirect_uri + client_id);

        QNetworkRequest req(url);

        manager->get(req);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(G_AuthCodeReply(QNetworkReply*)));
}

void Gmail::G_AuthCodeReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Access Code request success!";
        QUrl url = reply->url();
        QWebEngineView *view = new QWebEngineView;
        view->load(url);
        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(G_AuthCodeRedirectReply(QUrl)));
    }
    manager->disconnect();

}


void Gmail::G_AuthCodeRedirectReply(QUrl url) {
    qDebug() << "Access Code Received!";
    QString url_string(url.toString());

/* Extract the access code from the URI */
    url_string.replace("?","&");
    QStringList list  = url_string.split(QString("&"));
//    qDebug() << list;
    authCode = list.at(1);
    qDebug() << authCode;
    G_RequestAccessToken();
}

void Gmail::G_RequestAccessToken(){
    /* Exchange the access code for access token */
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    grant_type  = QString("&grant_type=authorization_code");

    QUrl urlToken(tokenEndpoint+ authCode+client_id+client_secret+redirect_uri+grant_type);
    QNetworkRequest req(urlToken);
    req.setRawHeader("Content-Type","application/x-www-form-urlencoded");

    QByteArray data;
    manager->post(req,data);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(G_AccessTokenReply(QNetworkReply*)));
}

void Gmail::G_AccessTokenReply(QNetworkReply *reply) {
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


    }

}
