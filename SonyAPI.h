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
    Q_PROPERTY(QString readyFlag READ readyFlag)

public:
    explicit SonyAPI(QObject *parent = nullptr);
    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);
    QString actTakePictureFilePath();
    bool readyFlag();

signals:
    void actTakePictureCompleted();
    void liveViewReady();
    void exposureSignal(int exposure);

public slots:
    void start();
    void stop();
    void startReply(QNetworkReply *reply);
    void startRecMode();
    void startRecModeReply(QNetworkReply *reply);
    void startLiveview();
    void startLiveviewReply(QNetworkReply *reply);
    void actTakePicture();
    void actTakePictureReply(QNetworkReply *reply);
    void downloadPicture(QNetworkReply *reply);
    void actHalfPressShutter();
    void actHalfPressShutterReply(QNetworkReply *reply);
    void cancelHalfPressShutter();
    void cancelHalfPressShutterReply(QNetworkReply *reply);
    void setExposureCompensation(int exposure);
    void setExposureCompensationReply(QNetworkReply *reply);
    void getExposureCompensation();
    void getExposureCompensationReply(QNetworkReply *reply);

//    void setCommand(const QString &command, int param);
//    void setCommandReply(QNetworkReply *reply);
//    void getCommand(const QString &command);
//    void getCommandReply(QNetworkReply *reply);


private:
    QString m_actTakePictureFilePath;
    QString m_saveFolder;
    QString m_fileName;
    bool m_readyFlag = true;
    QString urlString = "";
    QNetworkAccessManager *manager = nullptr;
    QNetworkAccessManager *downloadManager = nullptr;
};

#endif // SONYAPI_H
