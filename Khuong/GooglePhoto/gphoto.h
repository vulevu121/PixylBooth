#ifndef GPHOTO_H
#define GPHOTO_H

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
#include <QHttpMultiPart>
#include <QJsonArray>

class GooglePhoto : public QObject
{
    Q_OBJECT

public:
    explicit GooglePhoto(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager;
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

private slots:

    void RequestAccessCode();
    void RequestAccessToken();

    void AccessCodeReply(QNetworkReply *reply);
    void AccessCodeRedirectReply(QUrl url);
    void AccessTokenReply(QNetworkReply *reply);
    void UploadReply(QNetworkReply *reply);
    void CreateMediaReply(QNetworkReply *reply);

    void UploadPicData();
    void CreateMedia();


};

#endif // GPHOTO_H
