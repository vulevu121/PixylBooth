#ifndef SONYAPI_H
#define SONYAPI_H

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

class SonyAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString actTakePictureFilePath READ actTakePictureFilePath)
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)

public:
    explicit SonyAPI(QObject *parent = nullptr);
    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);
    QString actTakePictureFilePath();


signals:
    void actTakePictureCompleted();
    void liveViewReady();

public slots:
    void start();
    void startReply(QNetworkReply *reply);
    void startRecMode();
    void startRecModeReply(QNetworkReply *reply);
    void startLiveview();
    void startLiveviewReply(QNetworkReply *reply);
    void actTakePicture();
    void actHalfPressShutter();
    void actHalfPressShutterReply(QNetworkReply *reply);
    void cancelHalfPressShutter();
    void cancelHalfPressShutterReply(QNetworkReply *reply);
    void actTakePictureReply(QNetworkReply *reply);
    void downloadPicture(QNetworkReply *reply);

private:
    QString m_actTakePictureFilePath;
    QString m_saveFolder;
    QString m_fileName;
    QNetworkAccessManager *manager = nullptr;
    QNetworkAccessManager *downloadManager = nullptr;
};

#endif // SONYAPI_H
