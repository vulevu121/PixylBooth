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

    QString authCode;
    QString authEndpoint;
    QString scope;
    QString response_type;
    QString redirect_uri;
    QString client_id;
    QString accessToken;
    QString tokenEndpoint ;
    QString client_secret;
    QString grant_type ;

private slots:
    void RequestAccessToken();
    void AuthCodeReply(QNetworkReply *reply);
    void AuthCodeRedirectReply(QUrl url);
    void AccessTokenReply(QNetworkReply *reply);

public slots:
    void RequestAuthCode();
    void SetScope(QString RequestScope = "PHOTO");
    void SetScopeRaw(QString RawScope);
signals:
    void tokenReady(QString token);
};

#endif // GOOGLEOAUTH2_H
