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

class GooglePhoto : public QObject
{
    Q_OBJECT
public:
    explicit GooglePhoto(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;

    QString accessToken;
    QString uploadToken;
    QString uploadPicURL;
    QString albumID;
    QString albumURL;


signals:

public slots:
    void UploadPicData(QString pathToPic);
    void UploadReply(QNetworkReply *reply);

    void CreateAlbum(QString new_album_name);
    void CreateAlbumReply(QNetworkReply * reply);

    void ShareAlbum(QString albumID = "");
    void ShareAlbumReply(QNetworkReply * reply);

    void CreateMediaInAlbum(QString albumID = "");
    void CreateMediaReply(QNetworkReply *reply);

    void GetAlbums();
    void GetAlbumsReply(QNetworkReply * reply);

    QString getAlbumId();
};

#endif // GOOGLEPHOTO_H
