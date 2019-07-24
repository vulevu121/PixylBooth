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
#include <QUrl>
#include "googleoauth2.h"

class GMAIL : public QObject
{
    Q_OBJECT
public:
    explicit GMAIL(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;
    GoogleOAuth2 auth;
    QString albumURL;
    QString accessToken;
    QString receiverEmail;
    QString senderEmail;

signals:
    void authenticated();
    void linkReady();

public slots:
    void SetAlbumURL(QString url);
    void SendEmail();
    void SetToEmail(QString email);
    void SetFromEmail(QString email);

private slots:
    void SendEmailReply(QNetworkReply * reply);
    void SetAccessToken(QString token);


};

#endif // GMAIL_H
