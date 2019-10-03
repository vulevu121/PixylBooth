#ifndef QRGENERATOR_H
#define QRGENERATOR_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QThread>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QSslConfiguration>

class QRGenerator : public QObject
{
    Q_OBJECT
public:
    explicit QRGenerator(QObject *parent = nullptr);

signals:
    void receivedQrCode(QString imgPath);

public slots:
    void getQrImage();
    void getQrImageReply(QNetworkReply *reply);

private:
    QNetworkAccessManager *manager = nullptr;
};

#endif // QRGENERATOR_H
