#include "Firebase.h"

Firebase::Firebase(QObject *parent) : QObject(parent)
{

}


void Firebase::authenticate(const QString &user, const QString &password) {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=" + key);
    QNetworkRequest req(endpoint);

    req.setRawHeader("Content-Type","application/json");

    QJsonObject jsonObject {
        {"email", user},
        {"password", password},
        {"returnSecureToken", true}
    };

    QJsonDocument jsonDoc(jsonObject);
    QByteArray jsonRequest = jsonDoc.toJson();
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(authenticateReply(QNetworkReply*)));

}

void Firebase::authenticateReply(QNetworkReply *reply) {
    if(reply->error()) {
//        qDebug() << reply->errorString();
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        qDebug() << jsonObject["error"].toObject()["message"].toString();


    } else {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

//        qDebug() << jsonObject;

        if (jsonObject.contains("idToken")) {
            QString idToken(jsonObject["idToken"].toString());

            if (idToken.length() > 0) {
                userJsonObject = jsonObject;
                qDebug() << userJsonObject["idToken"];
            }
        }

    }
    manager->disconnect();

}

void Firebase::getUserData() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://firestore.googleapis.com/v1/projects/pixylbooth/databases/(default)/documents/users/vulevu121");
    QNetworkRequest req(endpoint);

    QString authHeader("Bearer {" + userJsonObject["idToken"].toString() + "}");

    req.setRawHeader("Content-Type","application/json");
    req.setRawHeader("Authorization", authHeader.toUtf8());

    qDebug() << authHeader;

//    QJsonObject jsonObject {
//        {"email", "user"},
//        {"password", "password"},
//        {"returnSecureToken", true}
//    };

//    QJsonDocument jsonDoc(jsonObject);
//    QByteArray jsonRequest = jsonDoc.toJson();
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    req.setRawHeader("Content-Length",postDataSize);
//    manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(authenticateReply(QNetworkReply*)));
}

void Firebase::getAccountInfo() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=" + key);
    QNetworkRequest req(endpoint);

    req.setRawHeader("Content-Type","application/json");

    QString idToken(userJsonObject["idToken"].toString());

    QJsonObject jsonObject {
        {"idToken", idToken}
    };

    QJsonDocument jsonDoc(jsonObject);
    QByteArray jsonRequest = jsonDoc.toJson();
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

    req.setRawHeader("Content-Length", postDataSize);
    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(getAccountInfoReply(QNetworkReply*)));

}

void Firebase::getAccountInfoReply(QNetworkReply *reply) {
    if(reply->error()) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        qDebug() << jsonObject["error"].toObject()["message"].toString();
    } else {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        userInfoJsonObject = jsonObject;

        qDebug() << jsonObject;

    }
    manager->disconnect();
}
