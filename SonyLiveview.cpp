#include "SonyLiveview.h"

SonyLiveview::SonyLiveview(QQuickItem *parent) : QQuickPaintedItem(parent)
{
}

void SonyLiveview::paint(QPainter *painter)
{
    if (this->currentImage.isNull()) {
        return;
    }

    QRectF bounding_rect = boundingRect();

    QImage scaled = this->currentImage.scaledToHeight(int(bounding_rect.height())).mirrored(m_flipHorizontally, false);

    QPointF center = bounding_rect.center() - scaled.rect().center();

    if(center.x() < 0)
        center.setX(0);
    if(center.y() < 0)
        center.setY(0);
    painter->drawImage(center, scaled);
}

void SonyLiveview::setImage(const QImage &image)
{
    this->currentImage = image;
    update();
}

void SonyLiveview::stop() {
    socket->disconnectFromHost();
    socket->disconnect();
    m_hostConnected = false;
//    qDebug() << "Liveview disconnected!";
}

void SonyLiveview::start() {
    if (!m_hostConnected) {
        qDebug() << "Connecting to liveview...";

        if (socket == nullptr) {
            socket = new QTcpSocket(this);
        }


        QString url("http://192.168.122.1:8080/liveview/liveviewstream");
        QUrl qurl(url);
    //    qDebug() << qurl.host();
    //    qDebug() << qurl.port();
    //    qDebug() << qurl.path();

        socket->connectToHost(qurl.host(), quint16(qurl.port()));

        connect(socket, SIGNAL(connected()), this, SLOT(connected()));
        connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
        connect(socket, SIGNAL(readyRead()), this, SLOT(readyRead()));
    //    connect(this->socket, SIGNAL(error()), this, SLOT(liveviewError()));

    //    if(!socket->waitForConnected(100)) {
    //        qDebug() << "Error:" << socket->errorString();
    //        return false;
    //    }
    }


}

bool SonyLiveview::isHostConnected() {
    return m_hostConnected;
}


void SonyLiveview::connected() {
    qDebug() << "Liveview connection OK!";
    socket->write("GET /liveview/liveviewstream HTTP/1.1\r\n");
    socket->write("Host: 192.168.122.1:8080\r\n");
    socket->write("User-Agent: curl/7.64.1\r\n");
    socket->write("Accept: */*\r\n\r\n");
    qDebug() << "Liveview request sent!";

    m_hostConnected = true;

}

void SonyLiveview::disconnected() {
    qDebug() << "Liveview disconnected!";
    m_hostConnected = false;
}



void SonyLiveview::readyRead() {
    array += socket->readAll();

    QByteArray startPayload = QByteArray::fromHex("FF01");
    QByteArray startCode = QByteArray::fromHex("24356879");

    int startIdx = array.indexOf(startPayload);
    int endIdx = array.indexOf(startPayload, startIdx+1);

    if (endIdx - startIdx >= 128) {
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

bool SonyLiveview::flipHorizontally() {
    return m_flipHorizontally;
}

void SonyLiveview::setFlipHorizontally(bool hFlip) {
    if (hFlip == m_flipHorizontally)
        return;
    m_flipHorizontally = hFlip;
}

