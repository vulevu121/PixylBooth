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
#include "gmail.h"

class GooglePhoto : public QObject
{
    Q_OBJECT
public:
    explicit GooglePhoto(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;
    GoogleOAuth2 auth;
    GMAIL email;
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
    void albumShared(QString link2Share);
    void albumIdChanged();
    void mediaCreated();


private slots:
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

    void SetTargetAlbumToUpload(QString id);
    void SetAlbumName(QString name);



public slots:
    /* If album already exists, this function will set the target album for all uploads */
    void SetAlbumDescription(QString note);
    void CreateAlbumAndUploadPhoto(QString pathToPic, QString albumName);
    void UploadPhotoToAlbum(QString pathToPic, QString id= NULL);

};

#endif // GOOGLEPHOTO_H
