#ifndef PRINTTHREAD_H
#define PRINTTHREAD_H

#include <QThread>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QDebug>

class PrintThread : public QThread
{
    Q_OBJECT
public:
    PrintThread(const QString &photoPaths, const QString &printerName, const QString &saveFolder, QObject *parent = nullptr);
    void run() override;

signals:

public slots:

private:
    QString photoPaths;
    QString printerName;
    QString saveFolder;
};

#endif // PRINTTHREAD_H
