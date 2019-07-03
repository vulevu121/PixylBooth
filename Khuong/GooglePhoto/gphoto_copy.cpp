#include "gphoto.h"
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QOAuthHttpServerReplyHandler>
#include <QDesktopServices>


GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
{
//    this->google = new QOAuth2AuthorizationCodeFlow(this);
//    this->google->setScope("email");

//    connect(this->google, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, &QDesktopServices::openUrl);

//    QByteArray val;
//    QFile file;
//    file.setFileName(QDir::toNativeSeparators("/full/path/client_secret_XXXXXXX.apps.googleusercontent.com.json"));
//    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
//    {
//        val = file.readAll();
//        file.close();
//    }


    google.setScope("https://www.googleapis.com/auth/photoslibrary");
    connect(&google, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser,
            &QDesktopServices::openUrl);

//        connect(&google, &QOAuth2AuthorizationCodeFlow::statusChanged,
//                this, &GooglePhoto::authStatusChanged);

//        google.setModifyParametersFunction([](QAbstractOAuth::Stage stage, QVariantMap* parameters) {
//            if (stage == QAbstractOAuth::Stage::RequestingAuthorization) {
//                parameters->insert("resource", "<App ID URI>");
//            }
//        });




    QByteArray val;
    QFile file;
    file.setFileName(QDir::toNativeSeparators("C:/Users/khuon/Documents/GooglePhoto/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json"));
    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        val = file.readAll();
        file.close();
    }

        QJsonDocument document = QJsonDocument::fromJson(val);
        QJsonObject object = document.object();
        const auto settingsObject = object["web"].toObject();
        const QUrl authUri(settingsObject["auth_uri"].toString());
        const auto clientId = settingsObject["client_id"].toString();
        const QUrl tokenUri(settingsObject["token_uri"].toString());
        const auto clientSecret(settingsObject["client_secret"].toString());

        const auto redirectUris = settingsObject["redirect_uris"].toArray();
        const QUrl redirectUri(redirectUris[0].toString());
        const auto port = static_cast<quint16>(redirectUri.port());
        qDebug() << redirectUri << ":" << port;
//        req.setRawHeader("Content-Type","application/json");



    google.setAuthorizationUrl(authUri);
    google.setClientIdentifier(clientId);
    google.setAccessTokenUrl(tokenUri);
    google.setClientIdentifierSharedKey(clientSecret);

    auto replyHandler = new QOAuthHttpServerReplyHandler(port, this);
    google.setReplyHandler(replyHandler);
    google.grant();






    connect(&google, &QOAuth2AuthorizationCodeFlow::granted, [=](){
        qDebug() << __FUNCTION__ << __LINE__ << "Access Granted!";
        auto reply = google.get(QUrl("https://www.googleapis.com/plus/v1/people/me"));
        connect(reply, &QNetworkReply::finished, [reply](){
            qDebug() << "REQUEST FINISHED. Error? " << (reply->error() != QNetworkReply::NoError);
            qDebug() << reply->readAll();
        });
    });
}

void GooglePhoto::authStatusChanged(QAbstractOAuth::Status status)
{
    QString s;
    if (status == QAbstractOAuth::Status::Granted)
        s = "granted";

    if (status == QAbstractOAuth::Status::TemporaryCredentialsReceived) {
        s = "temp credentials";
        //oauth2.refreshAccessToken();
    }

    qDebug() << s << ":"  ;
}

void GooglePhoto::granted ()
{

    QString token = google.token();
    qDebug() << "Token: " + token;

//    isGranted = true;
}


void GooglePhoto::grant()
{
    google.grant();
}
