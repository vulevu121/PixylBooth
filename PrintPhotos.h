#ifndef PRINTPHOTOS_H
#define PRINTPHOTOS_H

#include <QObject>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QDebug>
#include <QThread>
#include <QDir>
//#include <QSettings>

class PrintPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
    Q_PROPERTY(QString printerName READ printerName WRITE setPrinterName)
    Q_PROPERTY(QString paperName READ paperName WRITE setPaperName)
    Q_PROPERTY(bool portraitMode READ portraitMode WRITE setPortraitMode)

public:
    explicit PrintPhotos(QObject *parent = nullptr);

    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

    QString printerName();
    void setPrinterName(const QString &printerName);

    QString paperName();
    void setPaperName(const QString &paperName);

    bool portraitMode();
    void setPortraitMode(bool enable);
signals:


public slots:
    void printPhoto(const QString &photoPath, int copyCount, bool printCanvas);
    QString getPrinterSettings(QString const &printerName);

private:
    QString m_saveFolder;
    QString m_printerName;
    QString m_paperName;
    bool m_portraitMode = false;
};


// ==================================================================


class PrintThread : public QThread
{
    Q_OBJECT
public:
    PrintThread(QObject *parent = nullptr);
    void run() override;

    QString photoPath = "";
    QString printerName = "";
    QString saveFolder = "";
    QString paperName = "";
    int copyCount = 0;
    bool printCanvas = false;
    bool portraitMode = false;
};

#endif // PRINTPHOTOS_H
