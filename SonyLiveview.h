#ifndef SONYLIVEVIEW_H
#define SONYLIVEVIEW_H

#include <QQuickPaintedItem>
#include <QQuickItem>
#include <QPainter>
#include <QObject>
#include <QTcpSocket>
//#include <QAbstractSocket>
#include <QDebug>
//#include <QThread>
#include <QImage>

class SonyLiveview : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(bool flipHorizontally READ flipHorizontally WRITE setFlipHorizontally)

public:
    SonyLiveview(QQuickItem *parent = nullptr);
    Q_INVOKABLE void setImage(const QImage &image);
    void paint(QPainter *painter);


signals:
    void imageChanged();

public slots:
    void connected();
    void disconnected();
    void readyRead();
    void start();
    void stop();
    bool isHostConnected();
    bool flipHorizontally();
    void setFlipHorizontally(bool hFlip);


private:
    QTcpSocket *socket = nullptr;
    QByteArray array;
    QImage currentImage;
    bool m_hostConnected = false;
    bool m_flipHorizontally = false;
};

#endif // SONYLIVEVIEW_H
