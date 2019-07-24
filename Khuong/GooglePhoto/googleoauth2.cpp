#include "googleoauth2.h"

GoogleOAuth2::GoogleOAuth2(QObject *parent) : QObject(parent)
{

}
void GoogleOAuth2::SetScope(QString RequestScope){

    if(RequestScope == "GMAIL"){
        qDebug() << "Scope for Gmail";
        scope = QString("?scope=https://www.googleapis.com/auth/gmail.send"); // Create, read, update, and delete drafts. Send messages and drafts.
    }else{
        qDebug() << "Scope for Google Photo";
        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary.sharing"); // scope for sharing
    }
}

void GoogleOAuth2::SetScopeRaw(QString RawScope){
    scope = QString("?scope="+RawScope);

}

void GoogleOAuth2::SetJsonFilePath(QString path){
    jsonFilePath = path;
}
void GoogleOAuth2::RequestAuthCode(){
    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QFile jsonFile(jsonFilePath);
    jsonFile.open(QFile::ReadOnly);
    QJsonDocument document = QJsonDocument().fromJson(jsonFile.readAll());

    const auto object = document.object();
    settingsObject = object["web"].toObject();
    authEndpoint = settingsObject["auth_uri"].toString();
    tokenEndpoint = settingsObject["token_uri"].toString() + "?";

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
        view->show();
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
        emit tokenReady(accessToken);

        manager->disconnect();
    }
}

//QString GoogleOAuth2::GetAccessToken(){
//    return accessToken;
//}
