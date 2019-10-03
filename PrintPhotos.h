#ifndef PRINTPHOTOS_H
#define PRINTPHOTOS_H

#include <QObject>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QDebug>
#include <QThread>
#include <QDir>


class PrintPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
    Q_PROPERTY(QString printerName READ printerName WRITE setPrinterName)

public:
    explicit PrintPhotos(QObject *parent = nullptr);

    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

    QString printerName();
    void setPrinterName(const QString &printerName);

signals:

public slots:
    void printPhoto(const QString &photoPath, int copyCount, bool printCanvas);
    QString getPrinterName(QString const &printerName);

private:
    QString m_saveFolder;
    QString m_printerName;
};


// ==================================================================


class PrintThread : public QThread
{
    Q_OBJECT
public:
    PrintThread(const QString &photoPath, const QString &printerName, int copyCount, bool printCanvas, QObject *parent = nullptr);
    void run() override;

signals:

public slots:

private:
    QString photoPath = "";
    QString printerName = "";
    QString saveFolder = "";
    int copyCount = 0;
    bool printCanvas = false;
};

#endif // PRINTPHOTOS_H
