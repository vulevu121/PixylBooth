//#ifndef BACKEND_H
//#define BACKEND_H

//#include <QObject>

//class BackEnd : public QObject
//{
//    Q_OBJECT
//public:
//    explicit BackEnd(QObject *parent = nullptr);
    
//signals:
    
//public slots:
//};

//#endif // BACKEND_H

#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QThread>
#include <QFile>


class BackEnd : public QObject
{
    Q_OBJECT
//    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(QString actTakePictureFilePath READ actTakePictureFilePath)
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)

public:
    explicit BackEnd(QObject *parent = nullptr);

//    QString userName();
//    void setUserName(const QString &userName);
    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);
    QString actTakePictureFilePath();


signals:
//    void userNameChanged();
    void actTakePictureCompleted();

public slots:
    void startRecMode();
    void actTakePicture();
    void replyFinished(QNetworkReply *reply);
    void downloadPicFinished(QNetworkReply *reply);

private:
//    QString m_userName;
    QString m_actTakePictureFilePath;
    QString m_saveFolder;
    QString m_fileName;
    QNetworkAccessManager *manager;
    QNetworkAccessManager *downloadManager;
};

#endif // BACKEND_H
