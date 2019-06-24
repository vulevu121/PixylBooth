#include "Firebase.h"

Firebase::Firebase(QObject *parent) : QObject(parent)
{

}

QString Firebase::idToken() {
    return m_idToken;
}

void Firebase::setIdToken(const QString &idToken) {
    if (idToken == m_idToken)
        return;
    m_idToken = idToken;
}

QString Firebase::refreshToken() {
    return m_idToken;
}

void Firebase::setRefreshToken(const QString &refreshToken) {
    if (refreshToken == m_refreshToken)
        return;
    m_idToken = refreshToken;
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

        QString msg(jsonObject["error"].toObject()["message"].toString());
        msg = msg.replace("_", " ").toLower();
        msg[0] = msg[0].toUpper();

        qDebug() << msg;
        emit userNotAuthenticated(msg);

    } else {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

//        qDebug() << jsonObject;

        if (jsonObject.contains("idToken")) {
            QString idToken(jsonObject["idToken"].toString());
            QString refreshToken(jsonObject["refreshToken"].toString());

            if (idToken.length() > 100) {
                userJsonObject = jsonObject;
                manager->disconnect();
                m_idToken = idToken;
                m_refreshToken = refreshToken;
                getAccountInfo();
                emit userAuthenticated();
//                emit userAuthenticated(userJsonObject);

//                qDebug() << userJsonObject["idToken"].toString();
            }
        }

    }


}

void Firebase::getUserData() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QString userEmail(userJsonObject["email"].toString());

    QUrl endpoint("https://firestore.googleapis.com/v1beta1/projects/pixylbooth/databases/(default)/documents/users/" + userEmail);
    QNetworkRequest req(endpoint);


    QString authHeader("Bearer " + userJsonObject["idToken"].toString());

    req.setRawHeader("Authorization", authHeader.toUtf8());

    manager->get(req);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(getUserDataReply(QNetworkReply*)));
}

void Firebase::getUserDataReply(QNetworkReply *reply) {
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

        qDebug() << jsonObject["fields"];

//        qDebug() << jsonObject["fields"].toObject()["registration"].toObject()["stringValue"].toString();

    }
    manager->disconnect();
}

void Firebase::getAccountInfo() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl endpoint("https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=" + key);
    QNetworkRequest req(endpoint);

    req.setRawHeader("Content-Type","application/json");

//    QString idToken(userJsonObject["idToken"].toString());

    if (m_idToken.length() > 0) {
        QJsonObject jsonObject {
            {"idToken", m_idToken}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length", postDataSize);
        manager->post(req,jsonRequest);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(getAccountInfoReply(QNetworkReply*)));
    }



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
        emit userInfoReceived();
//        emit userInfoReceived(userInfoJsonObject);
//        qDebug() << jsonObject;

    }
    manager->disconnect();
}
