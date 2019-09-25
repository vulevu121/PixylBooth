#include "QRGenerator.h"

QRGenerator::QRGenerator(QObject *parent) : QObject(parent)
{

}

void QRGenerator::getQrImage() {
    if (manager == nullptr) {
        manager = new QNetworkAccessManager(this);
    }
    QSslSocket ssl;

    manager->connectToHostEncrypted(QString("api.qr-code-generator.com"));
    QUrl serviceURL("https://api.qr-code-generator.com/v1/create/");
    QNetworkRequest req(serviceURL);
    req.setSslConfiguration(QSslConfiguration::defaultConfiguration());
    req.setRawHeader("Content-Type","application/json");

    QJsonObject jsonObject {
        {"frame_name", "no-frame"},
        {"qr_code_text", "https://www.google.com"},
        {"image_format", "PNG"},
    };

    QJsonDocument jsonDoc(jsonObject);
    QByteArray jsonRequest = jsonDoc.toJson();
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

    req.setRawHeader("Content-Length", postDataSize);
    manager->post(req, jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(getQrImageReply(QNetworkReply*)));

}

void QRGenerator::getQrImageReply(QNetworkReply *reply) {
    if(reply->error()) {
        qDebug() << "[QR] Error";
        qDebug() << "[QR]" << reply->errorString();
    } else {
        qDebug() << "[QR] Downloading QR Image";
        QString filePath = "C:/Users/vle/Pictures/myqr.png";
        QFile file(filePath);
        QByteArray imageData = reply->readAll();

        file.write(imageData);
        file.flush();
        file.close();
        emit receivedQrCode(filePath);
    }
}
