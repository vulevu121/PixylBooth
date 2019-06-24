#ifndef PROCESSPHOTOS_H
#define PROCESSPHOTOS_H

#include <QObject>
#include <QDebug>
#include <QDir>
#include <QImage>
#include <QPainter>
#include <QList>

class ProcessPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
//    Q_PROPERTY(QString photoData READ photoData WRITE setPhotoData)
//    Q_PROPERTY(QString photoURLs READ photoURLs WRITE setPhotoURLs)

public:
    explicit ProcessPhotos(QObject *parent = nullptr);

    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

//    QString photoData();
//    void setPhotoData(const QString &jsonString);

//    QString photoURLs();
//    void setPhotoURLs(const QString &photoURLs);

signals:

public slots:
    QString combine(const QString &photoPaths);

private:
    QString m_saveFolder;
//    QString m_photoData;
//    QString &m_photoURLs;
//    QJsonObject *photoJson = nullptr;
};

#endif // PROCESSPHOTOS_H
