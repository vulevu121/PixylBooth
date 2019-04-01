//#include "backend.h"

//BackEnd::BackEnd(QObject *parent) : QObject(parent)
//{
    
//}


#include "backend.h"

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
}


QString BackEnd::actTakePictureFilePath() {
    return m_actTakePictureFilePath;
}

QString BackEnd::saveFolder() {
    return m_saveFolder;
}

void BackEnd::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}

void BackEnd::startRecMode() {
    manager = new QNetworkAccessManager(this);
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"startRecMode\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(replyFinished(QNetworkReply*)));

    qDebug() << "startRecMode Requested!";
}

void BackEnd::startLiveview() {
    manager = new QNetworkAccessManager(this);
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"startLiveview\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(replyFinished(QNetworkReply*)));

    qDebug() << "startLiveview Requested!";
}

void BackEnd::actTakePicture()
{
    manager = new QNetworkAccessManager(this);
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray jsonRequest ("{\"method\": \"actTakePicture\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
    req.setRawHeader("Content-Length",postDataSize);
    manager->post(req,jsonRequest);

    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));

    qDebug() << "actTakePicture Requested!";

}


void BackEnd::replyFinished (QNetworkReply *reply)
{
    if(reply->error()) {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
    } else {
        QByteArray response = reply->readAll();

        QString responseString(response); // grab picture url from result
//        qDebug() << responseString;

        // if "not available  now" in response, then camera is not ready for actTakePicture and need startRecMode
        if (responseString.indexOf("Not Available Now") >= 0) {
            startRecMode();
            QThread::sleep(5);
            actTakePicture();
        }

        if (responseString.indexOf("http") >= 0){ // otherwise if http is found in repsonse, we can dl pic
            responseString = responseString.replace("{\"result\":[[\"", "");
            responseString = responseString.replace("\"]],\"id\":1}", "");
            responseString = responseString.replace("\\", "");

            qDebug() << responseString;

            QString URL(responseString);
            QUrl picURL(URL);

            m_fileName = picURL.fileName();

            QNetworkRequest req(picURL);

            downloadManager = new QNetworkAccessManager(this);
            downloadManager->get(req);

            connect(downloadManager, SIGNAL(finished(QNetworkReply*)),
                    this, SLOT(downloadPicture(QNetworkReply*)));

        }

//        if (responseString.indexOf("{\"result\":[0],\"id\":1}") >= 0) {
//            QThread::sleep(2);
//            actTakePicture();
//        }

    }
}


void BackEnd::downloadPicture(QNetworkReply *reply)
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
//    qDebug() << m_fileName;
    emit actTakePictureCompleted();
}
