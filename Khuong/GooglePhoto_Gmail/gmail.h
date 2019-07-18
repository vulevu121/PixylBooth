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

class GMAIL : public QObject
{
    Q_OBJECT
public:
    explicit GMAIL(QObject *parent = nullptr);
private:
    QNetworkAccessManager *manager = nullptr;
    QString albumURL;
    QString accessToken;

signals:

public slots:

    void SendEmail();
    void SendEmailReply(QNetworkReply * reply);


};

#endif // GMAIL_H
