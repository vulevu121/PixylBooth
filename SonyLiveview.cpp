#include "SonyLiveview.h"
#include "Windows.h"

SonyLiveview::SonyLiveview(QQuickItem *parent) : QQuickPaintedItem(parent)
{

}


void SonyLiveview::paint(QPainter *painter)
{
    QScreen *screen = QGuiApplication::primaryScreen();

    originalPixmap = screen->grabWindow(liveviewWid);

    QRectF bounding_rect = boundingRect();
    QImage scaled = originalPixmap.toImage().scaledToHeight(int(bounding_rect.height())).mirrored(m_flipHorizontally, false);

    painter->drawImage(bounding_rect, scaled);


//    if (currentImage.isNull()) return;

//    QRectF bounding_rect = boundingRect();
//    QImage scaled = currentImage.scaledToHeight(int(bounding_rect.height())).mirrored(m_flipHorizontally, false);

//    painter->drawImage(bounding_rect, scaled);
}

//void SonyLiveview::setImage(const QImage &image)
//{
//    this->currentImage = image;
//    update();
//}

void SonyLiveview::stop() {
    if (m_hostConnected) {

        qDebug() << "[SonyLiveview] Terminating remote process";
        remoteProc->terminate();
        remoteProc->waitForFinished(5000);
        qDebug() << "[SonyLiveview] Terminating remote process...done";
    }
//    if (m_hostConnected) {
//        socket->disconnectFromHost();
//        socket->disconnect();
//        m_hostConnected = false;
//        qDebug() << "[Liveview] Stop!";
//    }
}

void SonyLiveview::start() {
    if (!m_hostConnected) {

        qDebug() << "[SonyLiveview] Starting remote process";
        QString remotePath = "/Program Files/Sony/Imaging Edge/Remote.exe";
        remoteProc = new QProcess(this);
        QStringList arguments;

    //    connect(remoteProc, SIGNAL(started()), this, SLOT(getRemoteWid()));

        remoteProc->start(remotePath, arguments);

        QTimer *delay = new QTimer(this);
        delay->singleShot(2000, this, SLOT(getRemoteWid()));

    }


//    if (!m_hostConnected) {
//        qDebug() << "[Liveview] Connecting...";

//        if (socket == nullptr) {
//            socket = new QTcpSocket(this);
//        }


//        QString url("http://192.168.122.1:8080/liveview/liveviewstream");
//        QUrl qurl(url);


//        socket->connectToHost(qurl.host(), quint16(qurl.port()));

//        connect(socket, SIGNAL(connected()), this, SLOT(connected()));
//        connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
//        connect(socket, SIGNAL(readyRead()), this, SLOT(readyRead()));

//    }


}

void SonyLiveview::getRemoteWid() {
    qDebug() << "[getRemoteWid] Finding Remote Window";
    HWND remoteHwnd = FindWindow(L"#32770", L"Remote");
    HWND liveviewContainerHwnd = FindWindowExW(remoteHwnd, NULL, L"#32770", L"");
    HWND liveviewHwnd = FindWindowExW(liveviewContainerHwnd, NULL, L"Static", L"");
    qDebug() << remoteHwnd << liveviewHwnd << liveviewHwnd;
    liveviewWid = WId(liveviewHwnd);

    liveviewUpdateTimer = new QTimer(this);
    connect(liveviewUpdateTimer, SIGNAL(timeout()), this, SLOT(update()));
    liveviewUpdateTimer->start(50);

    m_hostConnected = true;
}

bool SonyLiveview::isHostConnected() {
    return m_hostConnected;
}


void SonyLiveview::connected() {
    qDebug() << "[Liveview] Connection successful!";
    socket->write("GET /liveview/liveviewstream HTTP/1.1\r\n");
    socket->write("Host: 192.168.122.1:8080\r\n");
    socket->write("User-Agent: curl/7.64.1\r\n");
    socket->write("Accept: */*\r\n\r\n");
    qDebug() << "[Liveview] GET request sent!";

    m_hostConnected = true;

}

void SonyLiveview::disconnected() {
    qDebug() << "[Liveview] Disconnected!";
    m_hostConnected = false;
}

void SonyLiveview::error() {
    qDebug() << "[Liveview] Error!";
}


void SonyLiveview::readyRead() {
    array += socket->readAll();
    // start byte + payload type 1
    const QByteArray commonHeaderStartBytes = QByteArray::fromHex("FF01");
    // start code
    const QByteArray payloadHeaderStartBytes = QByteArray::fromHex("24356879");
    // start of common header
    int commonHeaderIdx = array.indexOf(commonHeaderStartBytes);
    // start of payload header
    int payloadHeaderIdx = array.indexOf(payloadHeaderStartBytes);
    // start of payload data size (data size is 3 bytes)
    int payloadDataSizeIdx = payloadHeaderIdx+4;

    const int payloadHeaderSize = 128;

    if (payloadHeaderIdx - commonHeaderIdx == 8 && array.length() > payloadDataSizeIdx+3) {
        QByteArray payloadDataSizeArray = array.mid(payloadDataSizeIdx, 3);
        payloadDataSize = static_cast<unsigned char>(payloadDataSizeArray[0]) << 16 | static_cast<unsigned char>(payloadDataSizeArray[1]) << 8 | static_cast<unsigned char>(payloadDataSizeArray[2]);
    }

    if (array.length() > payloadHeaderIdx+payloadHeaderSize+payloadDataSize) {
        int payloadDataIdx = payloadHeaderIdx+128+8;

        if (payloadDataSize > 10000 && array.length() > payloadDataIdx+payloadDataSize) {
            QByteArray payloadData = array.mid(payloadDataIdx, payloadDataSize);

            if (payloadData.indexOf(QByteArray::fromHex("FFD8")) == 0 && payloadData.contains(QByteArray::fromHex("FFD9"))) {
                currentImage = QImage::fromData(payloadData, "JPG");


//                currentImage2->fromData(payloadData, "JPG");

//                qDebug() << currentImage2->format();
                update();
                array.clear();
            }
            else {
                qDebug() << "Invalid liveview payload data";
                currentImage = QImage(640, 424, QImage::Format_RGB32);
                update();
            }

//            QFile file("C:/Users/Vu/Documents/test.jpg");
//            file.open(QIODevice::WriteOnly | QIODevice::Truncate);
//            if(file.exists()) {
//                file.write(payloadData);
//                file.flush();
//            }
//            file.close();

//            qDebug() << payloadData.length();
//            qDebug() << array.length();

        }
    }

    // just in case if overrun
    if (array.length() > 60000) {
        array.clear();
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

