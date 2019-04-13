#ifndef IMAGEPRINT_H
#define IMAGEPRINT_H

#include <QObject>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QDebug>

class ImagePrint : public QObject
{
    Q_OBJECT
//    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
public:
    explicit ImagePrint(QObject *parent = nullptr);
//    QString saveFolder();
//    void setSaveFolder(const QString &saveFolder);

signals:

public slots:
    void printPhotos(const QString &photoPaths, const QString &printerName, const QString &saveFolder);
    QString getPrinterName();

private:
//    QString m_saveFolder;
};

#endif // IMAGEPRINT_H
