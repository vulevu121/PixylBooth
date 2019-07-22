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

//private:
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


public slots:

    void RequestAuthCode();
    void RequestAccessToken();
    void AuthCodeReply(QNetworkReply *reply);
    void AuthCodeRedirectReply(QUrl url);
    void AccessTokenReply(QNetworkReply *reply);
//    void UploadReply(QNetworkReply *reply);

//    void CreateMediaReply(QNetworkReply *reply);
//    void UploadPicData();
//    void CreateMedia(QString AlbumID = "");
//    void CreateAlbum(QString album_name);
//    void CreateAlbumReply(QNetworkReply * reply);

//    void GetAlbums();
//    void GetAlbumsReply(QNetworkReply * reply);

//    void ShareAlbum(QString AlbumID = "");
//    void ShareAlbumReply(QNetworkReply * reply);

//    QString getAlbumId();

//    void EmailAlbumLink();
//    void EmailAlbumLinkReply(QNetworkReply * reply);

};

#endif // GPHOTO_H
