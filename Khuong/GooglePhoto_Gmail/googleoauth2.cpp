#include "googleoauth2.h"

GoogleOAuth2::GoogleOAuth2(QObject *parent) : QObject(parent)
{

}
void GoogleOAuth2::RequestAuthCode(QString RequestScope){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QFile jsonFile("C:/Users/khuon/Documents/GooglePhoto_Gmail/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json");
    jsonFile.open(QFile::ReadOnly);
    QJsonDocument document = QJsonDocument().fromJson(jsonFile.readAll());

    const auto object = document.object();
    settingsObject = object["web"].toObject();
    authEndpoint = settingsObject["auth_uri"].toString();
    tokenEndpoint = settingsObject["token_uri"].toString() + "?";

    if (RequestScope == "PHOTO"){
        qDebug() << "Scope for Google Photo";
        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary.sharing"); // scope for sharing
     }else{
        qDebug() << "Scope for Gmail";
        scope = QString("?scope=https://www.googleapis.com/auth/gmail.send"); // Create, read, update, and delete drafts. Send messages and drafts.
     }

    response_type = QString("&response_type=code");

    redirect_uri = QString("&redirect_uri=" + settingsObject["redirect_uris"].toArray()[0].toString());

    client_id = "&client_id=" + settingsObject["client_id"].toString();

    client_secret = "&client_secret=" + settingsObject["client_secret"].toString();

    QUrl url(authEndpoint + scope + response_type + redirect_uri + client_id);

//        qDebug() << url;
        QNetworkRequest req(url);

        manager->get(req);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(AuthCodeReply(QNetworkReply*)));
}

void GoogleOAuth2::AuthCodeReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << reply->errorString();
    } else {
        qDebug() << "Access Code request success!";
        QUrl url(reply->url());
        view = new QWebEngineView();
        view->load(url);
//        view->show();
        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(AuthCodeRedirectReply(QUrl)));
    }
    manager->disconnect();

}

void GoogleOAuth2::AuthCodeRedirectReply(QUrl url) {
    qDebug() << "Access Code Received!";
    QString url_string(url.toString());
//    qDebug() << url_string;

    /* For GMAIL authentication, needs to go through several steps, so this
     section will be different from Google Photo API*/
    url_string.replace("?","&");
    QStringList list  = url_string.split(QString("&"));

//    qDebug() << list;

    if (list[0] == settingsObject["redirect_uris"].toArray()[0].toString()){
        authCode = list.at(1);
//        qDebug() << authCode;

        RequestAccessToken();
    }
}

void GoogleOAuth2::RequestAccessToken(){
    qDebug() << "Requesting Access Token...";

    /* Exchange the access code for access token */
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    grant_type  = QString("&grant_type=authorization_code");

    QUrl urlToken(tokenEndpoint+ authCode+client_id+client_secret+redirect_uri+grant_type);
    QNetworkRequest req(urlToken);
    req.setRawHeader("Content-Type","application/x-www-form-urlencoded");

//    qDebug() << urlToken;
    QByteArray data;
    manager->post(req,data);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(AccessTokenReply(QNetworkReply*)));
}

void GoogleOAuth2::AccessTokenReply(QNetworkReply *reply) {
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

        accessToken = jsonObject["access_token"].toString();
        qDebug() <<  accessToken;
        manager->disconnect();
        emit tokenReady(accessToken);
    }
//    return;
}

QString GoogleOAuth2::GetAccessToken(){
    return accessToken;
}
