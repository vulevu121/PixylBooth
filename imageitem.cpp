#include "imageitem.h"
#include "backend.h"

ImageItem::ImageItem(QQuickItem *parent) : QQuickPaintedItem(parent)
{    
//this->current_image = QImage("C:/Users/Vu/Documents/PixylBooth/Images/liveviewstream.jpg");
}

void ImageItem::paint(QPainter *painter)
{
    QRectF bounding_rect = boundingRect();
    QImage scaled = this->current_image.scaledToHeight(bounding_rect.height());
    QPointF center = bounding_rect.center() - scaled.rect().center();

    if(center.x() < 0)
        center.setX(0);
    if(center.y() < 0)
        center.setY(0);
   painter->drawImage(center, scaled);
}

QImage ImageItem::image() const
{    return this->current_image;
}

void ImageItem::setImage(const QImage &image)
{
    this->current_image = image;
    update();
}


void ImageItem::start() {
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

void ImageItem::connected() {
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

//    socket->write("HEAD / HTTP/1.0\r\n\r\n\r\n\r\n");

}

void ImageItem::disconnected() {
    qDebug() << "Disconnected...";
}

void ImageItem::readyRead() {

//    QByteArray data = QByteArray::fromHex(socket->readAll());
//    qDebug() << data;

    array += socket->readAll();


    QByteArray startPayload = QByteArray::fromHex("FF01");
    QByteArray startCode = QByteArray::fromHex("24356879");

    int startIdx = array.indexOf(startPayload);
    int endIdx = array.indexOf(startPayload, startIdx+1);

    if (endIdx - startIdx >= 128) {
//        qDebug() << "Image Found!";

        QByteArray payloadDataSizeArray = array.mid(startIdx + 12, 3);
        int payloadDataSize = int((unsigned char)(payloadDataSizeArray[0]) << 16 | (unsigned char)(payloadDataSizeArray[1]) << 8 | (unsigned char)(payloadDataSizeArray[2]));

        int payloadIdx = array.indexOf(startCode, startIdx) + 128 + 8;

        QByteArray payloadData = array.mid(payloadIdx, payloadDataSize);

//        QImage image;
//        image.fromData(payloadData, "JPG");

//        QImage image = QImage("C:/Users/Vu/Documents/PixylBooth/Images/liveviewstream.jpg");

        QImage image = QImage::fromData(payloadData, "JPG");;
        setImage(image);

//        qDebug() << image.height();
//        qDebug() << image.width();



//        qDebug() << payloadData.toHex();

//        QFile file("C:/Users/Vu/Documents/PixylBooth/Images/liveviewstream.jpg");

//        file.open(QIODevice::WriteOnly | QIODevice::Truncate);

//        if(file.exists()) {
//            file.write(payloadData);
//            file.flush();
//            file.close();
//        }

        array.clear();

    }

}
