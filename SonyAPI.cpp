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


bool SonyAPI::readyFlag() {
    return m_readyFlag;
}

void SonyAPI::stop() {
    if (!m_readyFlag) {
        manager->disconnect();
        manager = nullptr;
        m_readyFlag = true;
    }
}

void SonyAPI::start() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QJsonArray param = {};

        QJsonObject jsonObject {
            {"method", "startRecMode"},
            {"params", param},
            {"id", 1},
            {"version", "1.0"}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(startReply(QNetworkReply*)));

        qDebug() << "[startRecMode] Requested!";
    }
}

void SonyAPI::startReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[startReply] Error";
        qDebug() << "[startReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject.contains("result")) {
            int result = jsonObject["result"].toInt();
            if (result == 0) {
                this->manager->disconnect();
                qDebug() << "[startRecMode] OK!";


                QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
                QNetworkRequest req(serviceURL);
                req.setRawHeader("Content-Type","application/json");

                QJsonArray param = {};

                QJsonObject jsonObject {
                    {"method", "startLiveview"},
                    {"params", param},
                    {"id", 1},
                    {"version", "1.0"}
                };

                QJsonDocument jsonDoc(jsonObject);
                QByteArray jsonRequest = jsonDoc.toJson();
                QByteArray postDataSize = QByteArray::number(jsonRequest.size());

                req.setRawHeader("Content-Length",postDataSize);
                manager->post(req,jsonRequest);

                connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                        this, SLOT(startLiveviewReply(QNetworkReply*)));

                qDebug() << "[startLiveview] Requested!";
            }
        }

    }

}

void SonyAPI::startRecMode() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);

        req.setRawHeader("Content-Type","application/json");

        QJsonArray param = {};

        QJsonObject jsonObject {
            {"method", "startRecMode"},
            {"params", param},
            {"id", 1},
            {"version", "1.0"}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(startRecModeReply(QNetworkReply*)));

        qDebug() << "[startRecMode] Requested!";
    }
}

void SonyAPI::startRecModeReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[startRecModeReply] Error";
        qDebug() << "[startRecModeReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject.contains("result")) {
            int result = jsonObject["result"].toInt();

            if (result == 0) {
                qDebug() << "[startRecModeReply] OK!";
            }
        }

    }
    m_readyFlag = true;
    manager->disconnect();
}

void SonyAPI::startLiveview() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QJsonArray param = {};

        QJsonObject jsonObject {
            {"method", "startLiveview"},
            {"params", param},
            {"id", 1},
            {"version", "1.0"}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(startLiveviewReply(QNetworkReply*)));

        qDebug() << "[startLiveview] Requested!";
        emit liveViewReady();

    }
}

void SonyAPI::startLiveviewReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[startLiveviewReply] Error";
        qDebug() << "[startLiveviewReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        int result = jsonObject["result"].toInt();

        if (result == 0) {
            qDebug() << "[startLiveviewReply] OK!";
        }


    }
    m_readyFlag = true;
    this->manager->disconnect();
}

void SonyAPI::actTakePicture()
{
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QByteArray jsonRequest ("{\"method\": \"actTakePicture\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());
        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(actTakePictureReply(QNetworkReply*)));

        qDebug() << "[actTakePicture] Requested!";

    }

}

void SonyAPI::actTakePictureReply (QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[actTakePictureReply] Error";
        qDebug() << "[actTakePictureReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;

        if (responseString.contains("error")) {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
            QJsonObject jsonObject = jsonDoc.object();

            QString errorString = jsonObject["error"].toArray()[1].toString();

            qDebug() << "[actTakePictureReply]" << errorString;

        }
        else {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
            QJsonObject jsonObject = jsonDoc.object();
            urlString = jsonObject["result"].toArray()[0].toArray()[0].toString();

            QUrl picUrl(urlString);

            m_fileName = picUrl.fileName();
            QNetworkRequest req(picUrl);

            if (downloadManager == nullptr) {
                downloadManager = new QNetworkAccessManager(this);
            }

            currentRetry = 0;
            downloadManager->get(req);

            connect(downloadManager, SIGNAL(finished(QNetworkReply*)),
                                this, SLOT(downloadPicture(QNetworkReply*)));
        }

    }
//    m_readyFlag = true;
    this->manager->disconnect();
}

void SonyAPI::downloadPicture(QNetworkReply *reply)
{
    QString filePath = m_saveFolder + "/" + m_fileName;
    QFile file(filePath);
    QByteArray imageData = reply->readAll();

    bool headerFound = imageData.indexOf(QByteArray::fromHex("FFD8")) > -1;
    bool footerFound = imageData.indexOf(QByteArray::fromHex("FFD9")) > -1;

//    if (imageData.length() > 200000) {
    if (headerFound && footerFound) {
        if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {

            if (file.exists()) {
                file.write(imageData);
                file.flush();
                file.close();
            }
            reply->deleteLater();

            m_actTakePictureFilePath = filePath;
            qDebug() << "[downloadPicture] Downloading" << m_actTakePictureFilePath;
            emit actTakePictureCompleted();

            m_readyFlag = true;
            this->downloadManager->disconnect();
        }

    } else {
//        this->downloadManager->disconnect();
        if (currentRetry < maxRetries) {
            qDebug() << "[downloadPicture] Current retry is " << currentRetry;
            QUrl picUrl(urlString);
            QNetworkRequest req(picUrl);
            downloadManager->get(req);
//            connect(downloadManager, SIGNAL(finished(QNetworkReply*)),
//                                this, SLOT(downloadPicture(QNetworkReply*)));
            currentRetry++;
//            return;
        }
    }


}

void SonyAPI::actHalfPressShutter() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QByteArray jsonRequest ("{\"method\": \"actHalfPressShutter\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());
        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(actHalfPressShutterReply(QNetworkReply*)));

        qDebug() << "[actHalfPressShutter] Requested!";

    }
}

void SonyAPI::actHalfPressShutterReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[actHalfPressShutterReply] Error";
        qDebug() << "[actHalfPressShutterReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result

//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject["result"].toArray().isEmpty()) {
            qDebug() << "[actHalfPressShutterReply] OK!";
        }


    }
    m_readyFlag = true;
    this->manager->disconnect();
}

void SonyAPI::cancelHalfPressShutter() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QByteArray jsonRequest ("{\"method\": \"cancelHalfPressShutter\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());
        req.setRawHeader("Content-Length",postDataSize);
        manager->post(req,jsonRequest);

        connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(cancelHalfPressShutterReply(QNetworkReply*)));

        qDebug() << "[cancelHalfPressShutter] Requested!";

    }
}

void SonyAPI::cancelHalfPressShutterReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[cancelHalfPressShutterReply] Error";
        qDebug() << "[cancelHalfPressShutterReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result

//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject["result"].toArray().isEmpty()) {
            qDebug() << "[cancelHalfPressShutterReply] OK!";
        }

    }
    m_readyFlag = true;
    this->manager->disconnect();
}


void SonyAPI::setExposureCompensation(int exposure) {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }
        m_readyFlag = false;
        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QJsonArray param = {exposure};

        QJsonObject jsonObject {
            {"method", "setExposureCompensation"},
            {"params", param},
            {"id", 1},
            {"version", "1.0"}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length", postDataSize);
        manager->post(req, jsonRequest);

        connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(setExposureCompensationReply(QNetworkReply*)));

        qDebug() << "[setExposureCompensation] Requested!";

    }
}

void SonyAPI::setExposureCompensationReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[setExposureCompensationReply] Error";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

//        qDebug() << jsonObject;

        if (jsonObject.contains("error")) {
            qDebug() << "[setExposureCompensationReply]" << jsonObject["error"].toArray()[1];
        }
        else if (jsonObject.contains("result")) {
            if (jsonObject["result"].toInt() == 0) {
                qDebug() << "[setExposureCompensationReply] OK!";

            }

        }

    }
    m_readyFlag = true;
    this->manager->disconnect();
}



void SonyAPI::getExposureCompensation() {
    if (m_readyFlag) {
        if (manager == nullptr) {
            manager = new QNetworkAccessManager(this);
        }

        m_readyFlag = false;

        QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
        QNetworkRequest req(serviceURL);
        req.setRawHeader("Content-Type","application/json");

        QJsonArray param = {};

        QJsonObject jsonObject {
            {"method", "getExposureCompensation"},
            {"params", param},
            {"id", 1},
            {"version", "1.0"}
        };

        QJsonDocument jsonDoc(jsonObject);
        QByteArray jsonRequest = jsonDoc.toJson();
        QByteArray postDataSize = QByteArray::number(jsonRequest.size());

        req.setRawHeader("Content-Length", postDataSize);
        manager->post(req, jsonRequest);

        connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(getExposureCompensationReply(QNetworkReply*)));


        qDebug() << "[getExposureCompensation] Requested!";

    }
}

void SonyAPI::getExposureCompensationReply(QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "[getExposureCompensationReply] Error";
        qDebug() << "[getExposureCompensationReply]" << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

//        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObject = jsonDoc.object();

        if (jsonObject.contains("result")) {
            int exposure = jsonObject["result"].toArray()[0].toInt();
            emit exposureSignal(exposure);
            qDebug() << "[getExposureCompensationReply] Exposure number:" << exposure;
        }


    }
    m_readyFlag = true;
    this->manager->disconnect();
}




//void SonyAPI::setCommand(const QString &command, int param) {
//    if (manager == nullptr) {
//        manager = new QNetworkAccessManager(this);
//    }
//    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
//    QNetworkRequest req(serviceURL);
//    req.setRawHeader("Content-Type","application/json");

//    QJsonArray paramArray = {param};

//    QJsonObject jsonObject {
//        {"method", command},
//        {"params", paramArray},
//        {"id", 1},
//        {"version", "1.0"}
//    };

//    QJsonDocument jsonDoc(jsonObject);
//    QByteArray jsonRequest = jsonDoc.toJson();
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    req.setRawHeader("Content-Length", postDataSize);
//    manager->post(req, jsonRequest);

//    connect(manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(setCommandReply(QNetworkReply*)));


//    qDebug() << command + " Requested!";
//}

//void SonyAPI::setCommandReply(QNetworkReply *reply)
//{
//    if(reply->error()) {
//        qDebug() << "ERROR!";
//        qDebug() << reply->errorString();
//    } else {
//        QByteArray response = reply->readAll();

////        QString responseString(response); // grab picture url from result
////        qDebug() << responseString;
//        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
//        QJsonObject jsonObject = jsonDoc.object();

//        if (jsonObject["result"].toInt() == 0) {
//            qDebug() << "setCommand...OK!";
//        }


//    }
//    this->manager->disconnect();
//}

//void SonyAPI::getCommand(const QString &command) {
//    if (manager == nullptr) {
//        manager = new QNetworkAccessManager(this);
//    }
//    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
//    QNetworkRequest req(serviceURL);
//    req.setRawHeader("Content-Type","application/json");

//    QJsonArray paramArray = {};

//    QJsonObject jsonObject {
//        {"method", command},
//        {"params", paramArray},
//        {"id", 1},
//        {"version", "1.0"}
//    };

//    QJsonDocument jsonDoc(jsonObject);
//    QByteArray jsonRequest = jsonDoc.toJson();
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    req.setRawHeader("Content-Length", postDataSize);
//    manager->post(req, jsonRequest);

//    connect(manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(getCommandReply(QNetworkReply*)));


//    qDebug() << command + " Requested!";
//}

//void SonyAPI::getCommandReply(QNetworkReply *reply)
//{
//    if(reply->error()) {
//        qDebug() << "ERROR!";
//        qDebug() << reply->errorString();
//    } else {
//        QByteArray response = reply->readAll();

////        QString responseString(response); // grab picture url from result

////        qDebug() << responseString;
//        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
//        QJsonObject jsonObject = jsonDoc.object();

//        qDebug() << jsonObject;

//        m_returnValueInt = jsonObject["result"].toArray()[0].toInt();


//        emit getCompleted();

////        int reply = jsonObject["result"].toArray()[0].toInt();
////        qDebug() << exposure;
////        emit getExposureReply(exposure);



////        if (jsonObject["result"].toInt() == 0) {
////            qDebug() << "getCommand...OK!";
////        }


//    }
//    this->manager->disconnect();
//}


