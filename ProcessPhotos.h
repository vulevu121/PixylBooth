#ifndef PROCESSPHOTOS_H
#define PROCESSPHOTOS_H

#include <QObject>
#include <QDebug>
#include <QDir>
#include <QImage>
#include <QPainter>

class ProcessPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
public:
    explicit ProcessPhotos(QObject *parent = nullptr);
    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

signals:

public slots:
    QString combine(const QString &photoPaths);

private:
    QString m_saveFolder;
};

#endif // PROCESSPHOTOS_H
