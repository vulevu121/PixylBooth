#include "SonyAPI.h"

SonyAPI::SonyAPI(QObject *parent) :
    QObject(parent)
{
}


QString SonyAPI::actTakePictureFilePath() {
    return m_actTakePictureFilePath;
}

QString SonyAPI::saveFolder() {
    return m_saveFolder;
}

void SonyAPI::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}

void SonyAPI::start() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"startRecMode\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(startReply(QNetworkReply*)));

    qDebug() << "startRecMode Requested!";
}

void SonyAPI::startReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        int result = jsonObject["result"].toInt();

        if (result == 0) {
            this->manager->disconnect();
            qDebug() << "startRecMode...OK!";
            startLiveview();
        }


    }
//    this->manager->disconnect();
}

void SonyAPI::startRecMode() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"startRecMode\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(startRecModeReply(QNetworkReply*)));

    qDebug() << "startRecMode Requested!";
}

void SonyAPI::startRecModeReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        int result = jsonObject["result"].toInt();

        if (result == 0) {
            qDebug() << "startRecMode...OK!";
        }


    }
    this->manager->disconnect();
}

void SonyAPI::startLiveview() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }

    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"startLiveview\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(startLiveviewReply(QNetworkReply*)));

    qDebug() << "startLiveview Requested!";
    emit liveViewReady();
}

void SonyAPI::startLiveviewReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        int result = jsonObject["result"].toInt();

        if (result == 0) {
            qDebug() << "startLiveView...OK!";
        }


    }
    this->manager->disconnect();
}

void SonyAPI::actTakePicture()
{
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"actTakePicture\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(actTakePictureReply(QNetworkReply*)));

    qDebug() << "actTakePicture Requested!";

}

void SonyAPI::actTakePictureReply (QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;

        if (responseString.contains("error")) {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
            QJsonObject jsonObject = jsonDoc.object();

            QString errorString = jsonObject["error"].toArray()[1].toString();

            qDebug() << errorString;

        }
        else {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
            QJsonObject jsonObject = jsonDoc.object();
            QString urlString = jsonObject["result"].toArray()[0].toArray()[0].toString();

            qDebug() << urlString;

            QUrl picUrl(urlString);

            m_fileName = picUrl.fileName();
            QNetworkRequest req(picUrl);

            if (downloadManager == nullptr) {
                downloadManager = new QNetworkAccessManager(this);
            }

            downloadManager->get(req);

            connect(downloadManager, SIGNAL(finished(QNetworkReply*)),
                                this, SLOT(downloadPicture(QNetworkReply*)));
        }

    }

    this->manager->disconnect();
}

void SonyAPI::downloadPicture(QNetworkReply *reply)
{
    QString filePath = m_saveFolder + "/" + m_fileName;
    QFile file(filePath);

    file.open(QIODevice::WriteOnly | QIODevice::Truncate);

    if(file.exists()) {
        file.write(reply->readAll());
        file.flush();
        file.close();
    }
    reply->deleteLater();
    m_actTakePictureFilePath = filePath;
    qDebug() << m_actTakePictureFilePath;
    emit actTakePictureCompleted();

    this->downloadManager->disconnect();
}

void SonyAPI::actHalfPressShutter() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"actHalfPressShutter\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(actHalfPressShutterReply(QNetworkReply*)));

    qDebug() << "actHalfPressShutter Requested!";
}

void SonyAPI::actHalfPressShutterReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result

//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject["result"].toArray().isEmpty()) {
            qDebug() << "actHalfPressShutter...OK!";
        }


    }

    this->manager->disconnect();
}

void SonyAPI::cancelHalfPressShutter() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"cancelHalfPressShutter\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(cancelHalfPressShutterReply(QNetworkReply*)));

    qDebug() << "cancelHalfPressShutter Requested!";
}

void SonyAPI::cancelHalfPressShutterReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result

//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject["result"].toArray().isEmpty()) {
            qDebug() << "cancelHalfPressShutter...OK!";
        }


    }
    this->manager->disconnect();
}

