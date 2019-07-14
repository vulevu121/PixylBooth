#ifndef GMAIL_H
#define GMAIL_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QWebEngineView>
#include <QJsonArray>

class Gmail : public QObject
{
    Q_OBJECT

public:
    explicit Gmail(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager;
    QString pathToPic;
    QString authCode;
    QString authEndpoint;
    QString scope;
    QString response_type;
    QString redirect_uri;
    QString client_id;
    QString token;
    QString tokenEndpoint ;
    QString client_secret;
    QString grant_type ;
    QString uploadToken;
    QString albumID;
    QString albumURL;
    QString shareableURL;
    QString inputAlbumName;


private slots:
    void G_RequestAuthCode();
    void G_RequestAccessToken();
    void G_AuthCodeReply(QNetworkReply *reply);
    void G_AuthCodeRedirectReply(QUrl url);
    void G_AccessTokenReply(QNetworkReply *reply);
    void G_UploadReply(QNetworkReply *reply);



};

#endif // GMAIL_H
