#include "liveviewstream.h"

LiveViewStream::LiveViewStream(QQuickItem *parent) : QQuickPaintedItem(parent)
{
}

void LiveViewStream::paint(QPainter *painter)
{
    if (this->current_image.isNull()) {
        return;
    }

    QRectF bounding_rect = boundingRect();
    QImage scaled = this->current_image.scaledToHeight(int(bounding_rect.height()));
    QPointF center = bounding_rect.center() - scaled.rect().center();

    if(center.x() < 0)
        center.setX(0);
    if(center.y() < 0)
        center.setY(0);
   painter->drawImage(center, scaled);
}

QImage LiveViewStream::image() const
{    return this->current_image;
}

void LiveViewStream::setImage(const QImage &image)
{
    this->current_image = image;
    update();
}

void LiveViewStream::stop() {
    disconnect(socket, SIGNAL(readyRead()), this, SLOT(readyRead()));

}

void LiveViewStream::start() {
//    QTcpSocket *socket = new QTcpSocket(this);
    
//    BackEnd backEnd;
//    backEnd.startLiveview();
    
//    QThread::sleep(2);

    socket = new QTcpSocket(this);

    connect(socket, SIGNAL(connected()), this, SLOT(connected()));
    connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
    connect(socket, SIGNAL(readyRead()), this, SLOT(readyRead()));

    QString url("http://192.168.122.1:8080/liveview/liveviewstream");
//    QUrl qurl(url);
//    qDebug() << qurl.host();
//    qDebug() << qurl.port();
//    qDebug() << qurl.path();

    socket->connectToHost("192.168.122.1", 8080);

    if(!socket->waitForConnected(5000))
    {
      qDebug() << "Error: " << socket->errorString();
    }

//    while (true)
//    {
//        QThread::sleep(1);
//        qDebug() << "loop";
//    }

//    socket->close();
//    qDebug() << "Socket closed.";
}

void LiveViewStream::connected() {
//    QThread::sleep(2);
//    qDebug() << "Connected...";
////    QByteArray line1("GET /liveview/liveviewstream HTTP/1.1\r\n");
////    QByteArray line2("Host: 192.168.122.1:8080\r\n");
////    QByteArray line3("User-Agent: curl/7.64.1\r\n");
////    QByteArray line4("Accept: */*\r\n");
    socket->write("GET /liveview/liveviewstream HTTP/1.1\r\n");
    socket->write("Host: 192.168.122.1:8080\r\n");
    socket->write("User-Agent: curl/7.64.1\r\n");
    socket->write("Accept: */*\r\n\r\n");

}

void LiveViewStream::disconnected() {
    qDebug() << "Disconnected...";
}

void LiveViewStream::readyRead() {
    array += socket->readAll();

    QByteArray startPayload = QByteArray::fromHex("FF01");
    QByteArray startCode = QByteArray::fromHex("24356879");

    int startIdx = array.indexOf(startPayload);
    int endIdx = array.indexOf(startPayload, startIdx+1);

    if (endIdx - startIdx >= 128) {
//        qDebug() << "Image Found!";

        QByteArray payloadDataSizeArray = array.mid(startIdx + 12, 3);
        int payloadDataSize = int(static_cast<unsigned char>(payloadDataSizeArray[0]) << 16 | static_cast<unsigned char>(payloadDataSizeArray[1]) << 8 | static_cast<unsigned char>(payloadDataSizeArray[2]));

        int payloadIdx = array.indexOf(startCode, startIdx) + 128 + 8;

        QByteArray payloadData = array.mid(payloadIdx, payloadDataSize);

        QImage image = QImage::fromData(payloadData, "JPG");;
        setImage(image);

        array.clear();
//        readyRead();
    }

}
