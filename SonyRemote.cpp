#include "SonyRemote.h"

enum Id { liveview, batteryPercent, ev, statusMsg, saveDir, photoButton, halfPressButton, IdCount };
static BOOL CALLBACK EnumChildProc(HWND hwnd, LPARAM lParam);
const int remoteHwndArrayLen = IdCount;
static HWND remoteHwndArray[remoteHwndArrayLen];

SonyRemote::SonyRemote(QQuickItem *parent) : QQuickPaintedItem(parent)
{

}

bool SonyRemote::isHostConnected() {
    return m_hostConnected;
}

bool SonyRemote::isFlipHorizontally() {
    return m_flipHorizontally;
}

bool SonyRemote::isLiveviewRunning() {
    return m_liveviewRunning;
}

void SonyRemote::setFlipHorizontally(bool hFlip) {
    if (hFlip == m_flipHorizontally)
        return;
    m_flipHorizontally = hFlip;
}

void SonyRemote::setLiveviewRunning(bool running) {
    if (running == m_liveviewRunning) return;
    m_liveviewRunning = running;
    if (running) {
        qDebug() << "[SonyRemote] Starting liveview";
        liveviewUpdateTimer->start();
    }
    else {
        qDebug() << "[SonyRemote] Stopping liveview";
        liveviewUpdateTimer->stop();
    }
}

bool SonyRemote::isPortraitMode() {
    return m_portraitMode;
}

void SonyRemote::setPortraitMode(bool portraitMode) {
    if (portraitMode == m_portraitMode)
        return;
    m_portraitMode = portraitMode;
}

QString SonyRemote::getSaveFolder() {
    return m_saveFolder;
}

void SonyRemote::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
    QDir saveDir(m_saveFolder);

    if (!saveDir.exists()) {
        saveDir.mkdir(m_saveFolder);
    }

}

//QString SonyRemote::actTakePictureFilePath() {
//    return m_actTakePictureFilePath;
//}

bool SonyRemote::readyFlag() {
    return m_readyFlag;
}


void SonyRemote::setExposureCompensation(int exposure) {
    qDebug() << "[SonyRemote] setExposureCompensation Requested!" << exposure;
}

void SonyRemote::getExposureCompensation() {
    qDebug() << "[SonyRemote] getExposureCompensation Requested!";
    emit exposureSignal(0);
}


void SonyRemote::paint(QPainter *painter)
{

    originalPixmap = screen->grabWindow(liveviewWid);
    QRectF bounding_rect = boundingRect();
    QImage scaled = originalPixmap.toImage().scaledToHeight(int(bounding_rect.height())).mirrored(m_flipHorizontally, false);
    painter->drawImage(bounding_rect, scaled);
}

void SonyRemote::stop() {
    if (!m_readyFlag) return;
    if (m_hostConnected) {
        qDebug() << "[SonyRemote] Terminating remote process";
//        closeRemoteWindow();
        remoteProc->terminate();
        remoteProc->waitForFinished(10000);
        qDebug() << "[SonyRemote] Remote process terminated";
        m_hostConnected = false;
    }
}

void SonyRemote::start() {
    if (!m_readyFlag) return;

//    QSettings *remoteSettings = new QSettings("Sony Corporation", "Imaging Edge");
//    qDebug() << remoteSettings->value("Remote/Setting/File/SaveDir01").toString();
//    qDebug() << m_saveFolder;
//    remoteSettings->setValue("Remote/Setting/File/SaveDir01", m_saveFolder);

    if (!m_hostConnected) {
        qDebug() << "[SonyRemote] Starting remote process";
        QString remotePath = "/Program Files/Sony/Imaging Edge/Remote.exe";
        remoteProc = new QProcess(this);
        QStringList arguments;
        remoteProc->start(remotePath, arguments);

        connect(checkRemoteHwndTimer, SIGNAL(timeout()), this, SLOT(getRemoteWid()));
        checkRemoteHwndTimer->start(1000);

    }
}

void SonyRemote::restart() {
    qDebug() << "[SonyRemote] Restarting remote";
    stop();
    start();
}

void SonyRemote::pauseLiveview() {
    qDebug() << "[SonyRemote] Liveview pause";
    liveviewUpdateTimer->stop();
}

void SonyRemote::resumeLiveview() {
    qDebug() << "[SonyRemote] Liveview resume";
    liveviewUpdateTimer->start();
}

void SonyRemote::getRemoteWid() {
    qDebug() << "[SonyRemote] Finding remote window";
    remoteHwnd = FindWindow(L"#32770", L"Remote");
    HWND liveviewContainerHwnd = FindWindowExW(remoteHwnd, NULL, L"#32770", L"");
    HWND liveviewHwnd = FindWindowExW(liveviewContainerHwnd, NULL, L"Static", L"");

    if (GetDlgCtrlID(liveviewHwnd) == 0xBB9) {
        qDebug() << "[SonyRemote] Found" << remoteHwnd << liveviewContainerHwnd << liveviewHwnd;
        liveviewWid = WId(liveviewHwnd);

        QTimer::singleShot(2000, this, SLOT(resizeRemoteWindow()));
//        QTimer::singleShot(2000, this, SLOT(getHwnd()));

        EnumChildWindows(remoteHwnd, EnumChildProc, NULL);

        for (int i = 0 ; i < remoteHwndArrayLen ; i++) {
            if (remoteHwndArray[i] == NULL) return;
        }

        checkRemoteHwndTimer->disconnect();

        connect(liveviewUpdateTimer, SIGNAL(timeout()), this, SLOT(update()));
        liveviewUpdateTimer->setInterval(60);
        liveviewUpdateTimer->start();

        QTimer *batteryPercentageUpdateTimer = new QTimer(this);
        connect(batteryPercentageUpdateTimer, SIGNAL(timeout()), this, SLOT(getBatteryPercentage()));
        batteryPercentageUpdateTimer->start(5000);

        QTimer *EVUpdateTimer = new QTimer(this);
        connect(EVUpdateTimer, SIGNAL(timeout()), this, SLOT(getEV()));
        EVUpdateTimer->start(5000);

        m_hostConnected = true;
        m_readyFlag = true;
    }

}

void SonyRemote::actTakePicture() {
    if (!m_readyFlag) return;

    qDebug() << "[SonyRemote] actTakePicture Requested!" << remoteHwnd;
//    keycode = 0x31;
//    PostMessageW(remoteHwnd, WM_KEYDOWN, keycode, 0);
//    QTimer::singleShot(300, this, SLOT(releaseKey()));
//    PostMessageW(remoteHwnd, WM_KEYUP, keycode, 0);
    SendMessageW(remoteHwndArray[photoButton], BM_CLICK, NULL, NULL);
    QTimer::singleShot(5000, this, SLOT(actTakePictureReply()));
}

void SonyRemote::releaseKey() {
    qDebug() << "[SonyRemote] Release Key" << keycode;
    PostMessageW(remoteHwnd, WM_KEYUP, keycode, 0);
}

void SonyRemote::actTakePictureReply() {
    QSettings *remoteSettings = new QSettings("Sony Corporation", "Imaging Edge");
    QString saveDir = remoteSettings->value("Remote/Setting/File/SaveDir01").toString();
    QString fileName = remoteSettings->value("Remote/Setting/File/DownloadFileNameAuto").toString();
    QString filePath = saveDir + "/" + fileName;
    filePath.replace("\\", "/");

    if (QFile::exists(filePath)) {
        qDebug() << filePath << "exists";

        QString targetFilePath = m_saveFolder + "/" + fileName;

        // move to target folder
        if (QFile::rename(filePath, targetFilePath)) {
            emit actTakePictureCompleted(targetFilePath);
        } else {
            // else append current datetime if target file already exists
            QString name = fileName.left(fileName.lastIndexOf("."));
            QString ext = fileName.right(fileName.length() - fileName.lastIndexOf("."));

            QString curDateTime = QDateTime::currentDateTime().toString("yyMMdd_HHmmss");
            QString newFileName = name + "_" + curDateTime + ext;
            targetFilePath = m_saveFolder + "/" + newFileName;

            QFile::rename(filePath, targetFilePath);
            emit actTakePictureCompleted(targetFilePath);
        }
    }


//    char textBuffer[2048];
////    qDebug() << remoteHwndArray[statusMsg];
//    SendMessageA(remoteHwndArray[statusMsg], WM_GETTEXT, sizeof(textBuffer)/sizeof(textBuffer[0]), LPARAM(textBuffer));
//    QString title = QString::fromUtf8(textBuffer);

//    QRegularExpression re("Transferred image: \\(([\\w.]+)\\). 0 files remaining");
////    qDebug() << textBuffer;
//    QRegularExpressionMatch match = re.match(title);

//    if (match.hasMatch()) {
////        qDebug() << match.captured(1);
//        m_fileName = match.captured(1);
//        m_actTakePictureFilePath = m_saveFolder + "/" + m_fileName;
//        qDebug() << "[actTakePictureReply]" << m_actTakePictureFilePath;
////        m_readyFlag = true;
//        emit actTakePictureCompleted(m_actTakePictureFilePath);
//    }
}

void SonyRemote::actHalfPressShutter() {
    if (!m_readyFlag) return;
    qDebug() << "[SonyRemote] actHalfPressShutter Requested!";
//    uint keycode = 0x47;
//    PostMessageW(remoteHwnd, WM_KEYDOWN, keycode, 0);
//    PostMessageW(remoteHwnd, WM_KEYUP, keycode, 0);

    SendMessageW(remoteHwndArray[halfPressButton], BM_CLICK, NULL, NULL);
}

void SonyRemote::cancelHalfPressShutter() {
    if (!m_readyFlag) return;
    qDebug() << "[SonyRemote] cancelHalfPressShutter Requested!";
    uint keycode = 0x47;
    PostMessageW(remoteHwnd, WM_KEYDOWN, keycode, 0);
    PostMessageW(remoteHwnd, WM_KEYUP, keycode, 0);
}

static BOOL CALLBACK ::EnumChildProc(HWND hwnd, LPARAM lParam) {
//    qDebug() << GetDlgCtrlID(hwnd);
    switch (GetDlgCtrlID(hwnd)) {
        case 0xBB9: remoteHwndArray[liveview] = hwnd; break;
        case 0x76E: remoteHwndArray[batteryPercent] = hwnd; break;
        case 0x456: remoteHwndArray[ev] = hwnd; break;
        case 0x57A: remoteHwndArray[saveDir] = hwnd; break;
        case 0xFFFF: remoteHwndArray[statusMsg] = hwnd; break;
        case 0x3E9: remoteHwndArray[photoButton] = hwnd; break;
        case 0x3EC: remoteHwndArray[halfPressButton] = hwnd; break;
    }

//    char textBuffer[2048];
//    SendMessageA(hwnd, WM_GETTEXT, sizeof(textBuffer)/sizeof(textBuffer[0]), LPARAM(textBuffer));
//    QString title = QString::fromUtf8(textBuffer);
//    qDebug() << hwnd << title;
//    remoteHwndArray[remoteHwndArrayLen++] = hwnd;
    return TRUE;
}

void SonyRemote::getBatteryPercentage() {
    if (!m_readyFlag) return;
    char textBuffer[2048];
    SendMessageA(remoteHwndArray[batteryPercent], WM_GETTEXT, sizeof(textBuffer)/sizeof(textBuffer[0]), LPARAM(textBuffer));
    QString title = QString::fromUtf8(textBuffer);
    QRegularExpression re("([\\w]+)%");
    QRegularExpressionMatch match = re.match(title);
    if (match.hasMatch()) {
        emit batteryPercentageSignal(match.captured(1).toInt());
    }
}

void SonyRemote::getEV() {
    if (!m_readyFlag) return;
    char textBuffer[20];
    SendMessageA(remoteHwndArray[ev], WM_GETTEXT, sizeof(textBuffer)/sizeof(textBuffer[0]), LPARAM(textBuffer));
    QString title = QString::fromUtf8(textBuffer);
    emit evSignal(title);
}

QString SonyRemote::getSaveDir() {
    if (!m_readyFlag) return "";
    char textBuffer[2048];
    SendMessageA(remoteHwndArray[saveDir], WM_GETTEXT, NULL, LPARAM(textBuffer));
    return QString(textBuffer);
}

void SonyRemote::resizeRemoteWindow() {
    if (!m_readyFlag) return;
    qDebug() << "[SonyRemote] Resizing window";
    QRect availableGeometry = screen->availableGeometry();

    qDebug() << availableGeometry;

    int width = int(availableGeometry.width() * 0.5);
    int height = int(width / 1.75);


    MoveWindow(remoteHwnd, 0, 0, width, height, BOOL(true));

}

void SonyRemote::closeRemoteWindow() {
    SendMessageA(remoteHwnd, WM_CLOSE, NULL, NULL);
}

