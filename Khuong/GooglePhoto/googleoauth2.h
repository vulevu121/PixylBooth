#ifndef GOOGLEOAUTH2_H
#define GOOGLEOAUTH2_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QUrl>
#include <QWebEngineView>

class GoogleOAuth2 : public QObject
{
    Q_OBJECT
public:
    explicit GoogleOAuth2(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;
    QWebEngineView *view = nullptr;
    QJsonObject settingsObject;
    QString jsonFilePath = QString("C:/Users/khuon/Documents/GooglePhoto/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json");
    QString authCode;
    QString authEndpoint;
    QString scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary.sharing");
    QString response_type;
    QString redirect_uri;
    QString client_id;
    QString accessToken;
    QString tokenEndpoint ;
    QString client_secret;
    QString grant_type = QString("&grant_type=authorization_code");


private slots:
    void ExchangeAccessToken();
    void ExchangeTokenReply(QNetworkReply *reply);

    void AuthenticateReply(QNetworkReply *reply);
    void AuthenticateRedirectReply(QUrl url);

public slots:
    void Authenticate();
    void SetScope(QString RequestScope = "PHOTO");
    void SetScopeRaw(QString RawScope);
    void SetJsonFilePath(QString path);

signals:
    void tokenReady(QString token);
    void jsonFilePathSet();
    void scopeSet();

};

#endif // GOOGLEOAUTH2_H
