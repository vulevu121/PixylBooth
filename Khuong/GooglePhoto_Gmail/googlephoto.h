#ifndef GOOGLEPHOTO_H
#define GOOGLEPHOTO_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QUrl>
#include "googleoauth2.h"

class GooglePhoto : public QObject
{
    Q_OBJECT
public:
    explicit GooglePhoto(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;
    GoogleOAuth2 auth;
    QString accessToken;
    QString uploadToken;
    QString uploadedPicURL;
    QString albumName;
    QString albumID;
    QString albumDescription;
    QString albumURL;
    QString pathToFile;

signals:
    void accessTokenSaved();
    void uploadTokenReceived();
    void albumCreated();
    void albumShared();


private slots:
    void GetAccess();
    void SetAccessToken(QString token);

    void UploadPicData();
    void UploadReply(QNetworkReply *reply);

    void CreateAlbum();
    void CreateAlbumReply(QNetworkReply * reply);

    void ShareAlbum();
    void ShareAlbumReply(QNetworkReply * reply);

    void CreateMediaInAlbum();
    void CreateMediaReply(QNetworkReply *reply);

    void GetAlbums();
    void GetAlbumsReply(QNetworkReply * reply);



public slots:
    /* If album already exists, this function will set the target album for all uploads */
    void SetTargetAlbumID(QString id);
    void SetAlbumDescription(QString note);
    void UploadPhoto(QString pathToPic);
    void SetAlbumName(QString name);
};

#endif // GOOGLEPHOTO_H
