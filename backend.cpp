//#include "backend.h"

//BackEnd::BackEnd(QObject *parent) : QObject(parent)
//{
    
//}


#include "backend.h"

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
}

//QString BackEnd::userName()
//{
//    return m_userName;
//}

//void BackEnd::setUserName(const QString &userName)
//{
//    if (userName == m_userName)
//        return;

//    m_userName = userName;
//    emit userNameChanged();
//}

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

    QByteArray start_rec ("{\"method\": \"startRecMode\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize1 = QByteArray::number(start_rec.size());
    req.setRawHeader("Content-Length",postDataSize1);
    manager->post(req,start_rec);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(replyFinished(QNetworkReply*)));

    qDebug() << "startRecMode Requested!";
}

void BackEnd::actTakePicture()
{
    manager = new QNetworkAccessManager(this);
    QUrl serviceURL("http://192.168.122.1:8080/sony/camera");
    QNetworkRequest req(serviceURL);
    req.setRawHeader("Content-Type","application/json");

    QByteArray take_pic ("{\"method\": \"actTakePicture\", \"params\": [], \"id\": 1, \"version\": \"1.0\"}");
    QByteArray postDataSize2 = QByteArray::number(take_pic.size());
    req.setRawHeader("Content-Length",postDataSize2);
    manager->post(req,take_pic);

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
        qDebug() << responseString;

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
                    this, SLOT(downloadPicFinished(QNetworkReply*)));

        }

//        if (responseString.indexOf("{\"result\":[0],\"id\":1}") >= 0) {
//            QThread::sleep(2);
//            actTakePicture();
//        }

    }
}


void BackEnd::downloadPicFinished(QNetworkReply *reply)
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
