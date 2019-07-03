#ifndef GPHOTO_H
#define GPHOTO_H


#include <QObject>
#include <QNetworkReply>
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

    void A_ReceivedReply(QNetworkReply *reply);
    void B_ReceivedReply(QUrl url);
    void C_ReceivedReply(QNetworkReply *reply);
    void D_ReceivedReply(QNetworkReply *reply);
    void E_ReceivedReply(QNetworkReply *reply);

    void uploadBinary();
    void createMedia();


};

#endif // GPHOTO_H
