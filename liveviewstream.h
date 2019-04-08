#ifndef LIVEVIEWSTREAM_H
#define LIVEVIEWSTREAM_H

#include <QQuickPaintedItem>
#include <QQuickItem>
#include <QPainter>
#include <QObject>
#include <QTcpSocket>
//#include <QAbstractSocket>
#include <QDebug>
//#include <QThread>
#include <QImage>

class LiveViewStream : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)

public:
    LiveViewStream(QQuickItem *parent = nullptr);
    Q_INVOKABLE void setImage(const QImage &image);
    void paint(QPainter *painter);
    QImage image() const;

signals:
    void imageChanged();

public slots:
    void connected();
    void disconnected();
    void readyRead();
    void start();
    void stop();

private:
    QTcpSocket *socket;
    QByteArray array;
    QImage current_image;
};

#endif // LIVEVIEWSTREAM_H
