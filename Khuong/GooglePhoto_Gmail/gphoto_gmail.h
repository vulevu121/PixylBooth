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
#include <QUrl>
#include <QWebEngineView>

//#include <QHttpMultiPart>
//#include <QThread>
//#include <QDir>

class GooglePhoto : public QObject
{
    Q_OBJECT

public:
    explicit GooglePhoto(QObject *parent = nullptr);

private:
//    QNetworkAccessManager *manager = nullptr;
//    QWebEngineView *view = nullptr;
//    QJsonObject settingsObject;

//    QString authCode;
//    QString authEndpoint;
//    QString scope;
//    QString response_type;
//    QString redirect_uri;
//    QString client_id;
//    QString token;
//    QString tokenEndpoint ;
//    QString client_secret;
//    QString grant_type ;

    QString uploadToken;
    QString uploadPicURL;
    QString albumID;
    QString albumURL;
    QString shareableURL;
    QString inputAlbumName;
    QString pathToPic;



public slots:

//    void RequestAuthCode();
//    void RequestAccessToken();
//    void AuthCodeReply(QNetworkReply *reply);
//    void AuthCodeRedirectReply(QUrl url);
//    void AccessTokenReply(QNetworkReply *reply);

//    void UploadReply(QNetworkReply *reply);
//    void CreateMedia(QString AlbumID = "");
//    void CreateMediaReply(QNetworkReply *reply);
//    void UploadPicData();
//    void CreateAlbum(QString album_name);
//    void CreateAlbumReply(QNetworkReply * reply);

//    void GetAlbums();
//    void GetAlbumsReply(QNetworkReply * reply);

//    void ShareAlbum(QString AlbumID = "");
//    void ShareAlbumReply(QNetworkReply * reply);

//    QString getAlbumId();

//    void DraftEmail();
//    void DraftEmailReply(QNetworkReply * reply);
//    void SendEmail(QString draftID = "");
//    void SendEmailReply(QNetworkReply * reply);

//    void _SendEmail();
//    void _SendEmailReply(QNetworkReply * reply);



};

#endif // GPHOTO_H
