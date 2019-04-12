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

public slots:
    void startRecMode();
    void startLiveview();
    void actTakePicture();
    void replyFinished(QNetworkReply *reply);
    void downloadPicture(QNetworkReply *reply);

private:
    QString m_actTakePictureFilePath;
    QString m_saveFolder;
    QString m_fileName;
    QNetworkAccessManager *manager;
    QNetworkAccessManager *downloadManager;
};

#endif // SONYAPI_H
