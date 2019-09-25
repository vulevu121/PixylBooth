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
#include <QPixmap>
#include <QGuiApplication>
#include <QScreen>
#include <QTimer>
#include <QProcess>


class SonyLiveview : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(bool flipHorizontally READ flipHorizontally WRITE setFlipHorizontally)

public:
    SonyLiveview(QQuickItem *parent = nullptr);
//    Q_INVOKABLE void setImage(const QImage &image);
    void paint(QPainter *painter);

signals:
    void imageChanged();

public slots:
    void connected();
    void disconnected();
    void readyRead();
    void error();
    void start();
    void stop();
    bool isHostConnected();
    bool flipHorizontally();
    void setFlipHorizontally(bool hFlip);
    void getRemoteWid();


private:
    QTcpSocket *socket = nullptr;
    QByteArray array = QByteArray("", 65535);
    int payloadDataSize = 0;
    QImage currentImage = QImage(640, 424, QImage::Format_RGB32);
    QImage *currentImage2 = nullptr;
    bool m_hostConnected = false;
    bool m_flipHorizontally = false;
    QPixmap originalPixmap;
    WId liveviewWid;
    QProcess *remoteProc;
    QTimer *liveviewUpdateTimer;
};

#endif // SONYLIVEVIEW_H
