#include "liveviewstream.h"

LiveViewStream::LiveViewStream(QObject *parent) : QObject(parent)
{

}

void LiveViewStream::start() {
//    QTcpSocket *socket = new QTcpSocket(this);

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
    qDebug() << "Connected...";
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

void LiveViewStream::disconnected() {
    qDebug() << "Disconnected...";
}

void LiveViewStream::readyRead() {

//    QByteArray data = QByteArray::fromHex(socket->readAll());
//    qDebug() << data;

    array += socket->readAll();


    QByteArray startPayload = QByteArray::fromHex("FF01");
    QByteArray startCode = QByteArray::fromHex("24356879");

    int startIdx = array.indexOf(startPayload);
    int endIdx = array.indexOf(startPayload, startIdx+1);

    if (endIdx - startIdx >= 128) {
        qDebug() << "Image Found!";

        QByteArray payloadDataSizeArray = array.mid(startIdx + 12, 3);
        int payloadDataSize = int((unsigned char)(payloadDataSizeArray[0]) << 16 | (unsigned char)(payloadDataSizeArray[1]) << 8 | (unsigned char)(payloadDataSizeArray[2]));

        int payloadIdx = array.indexOf(startCode, startIdx) + 128 + 8;

        QByteArray payloadData = array.mid(payloadIdx, payloadDataSize);

//        QImage image;
        image.loadFromData(payloadData, "JPG");

        emit imageUpdated();






//        qDebug() << payloadData.toHex();

//        QFile file("C:/Users/Vu/Documents/Sony-Camera-API/example/downloaded.jpg");

//        file.open(QIODevice::WriteOnly | QIODevice::Truncate);

//        if(file.exists()) {
//            file.write(payloadData);
//            file.flush();
//            file.close();
//        }

        array.clear();
        readyRead();
    }



//    if(array.contains("$5hy"))
//    {
//        qDebug() << "Found!";
//        int bytes = array.indexOf("$5hy") + 1;
//        QByteArray message = array.left(bytes);
//        array = array.mid(bytes);

//        //processMessage(message);

//        array.clear();
//        readyRead();
//    }

//    qDebug() << socket->readAll();
}
