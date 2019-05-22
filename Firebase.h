#ifndef FIREBASE_H
#define FIREBASE_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

class Firebase : public QObject
{
    Q_OBJECT
public:
    explicit Firebase(QObject *parent = nullptr);

private:
    QNetworkAccessManager *manager = nullptr;
    QJsonObject userJsonObject;
    QJsonObject userInfoJsonObject;
    QString key = "AIzaSyBKWMrLRUNoPpZ9fMshmA3ZD19Wbujk9wU";

signals:

public slots:
    void authenticate(const QString &user, const QString &password);
    void getUserData();
    void getAccountInfo();


private slots:
    void authenticateReply(QNetworkReply *reply);
    void getAccountInfoReply(QNetworkReply *reply);

};

#endif // FIREBASE_H
