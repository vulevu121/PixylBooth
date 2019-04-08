#ifndef IMAGEITEM_H
#define IMAGEITEM_H
#include <QQuickPaintedItem>
#include <QQuickItem>
#include <QPainter>
#include <QImage>

#include <QTcpSocket>
#include <QAbstractSocket>
#include <QDebug>
#include <QThread>
#include <QFile>

class ImageItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)

public:
    ImageItem(QQuickItem *parent = nullptr);
    Q_INVOKABLE void setImage(const QImage &image);
    void paint(QPainter *painter);
    QImage image() const;

public slots:
    void connected();
    void disconnected();
    void readyRead();
    void start();

signals:
    void imageChanged();


private:
    QImage current_image;
    QTcpSocket *socket;
    QByteArray array;
};
#endif // IMAGEITEM_H


