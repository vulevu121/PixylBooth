#ifndef PRINTPHOTOS_H
#define PRINTPHOTOS_H

#include <QObject>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QDebug>

class PrintPhotos : public QObject
{
    Q_OBJECT
//    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
public:
    explicit PrintPhotos(QObject *parent = nullptr);
//    QString saveFolder();
//    void setSaveFolder(const QString &saveFolder);

signals:

public slots:
    void printPhotos(const QString &photoPaths, const QString &printerName, const QString &saveFolder, int copyCount);
    QString getPrinterName();

private:
//    QString m_saveFolder;
};

#endif // PRINTPHOTOS_H
