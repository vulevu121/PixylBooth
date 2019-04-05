#ifndef LIVEVIEWSTREAM_H
#define LIVEVIEWSTREAM_H

#include <QObject>
#include <QTcpSocket>
#include <QAbstractSocket>
#include <QDebug>
#include <QThread>
#include <QFile>
#include <QImage>

class LiveViewStream : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image NOTIFY imageUpdated)

public:
    explicit LiveViewStream(QObject *parent = nullptr);

signals:
    void imageUpdated();

public slots:
    void connected();
    void disconnected();
    void readyRead();
    void start();

private:
    QTcpSocket *socket;
    QByteArray array;
    QImage image;
};

#endif // LIVEVIEWSTREAM_H
