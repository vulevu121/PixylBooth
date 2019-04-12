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
public:
    explicit ImagePrint(QObject *parent = nullptr);

signals:

public slots:
    void printText();
};

#endif // IMAGEPRINT_H
