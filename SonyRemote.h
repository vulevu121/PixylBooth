#ifndef SONYREMOTE_H
#define SONYREMOTE_H

#include <QObject>
#include <QString>
#include <QFile>

#include <QQuickPaintedItem>
#include <QQuickItem>
#include <QPainter>
#include <QObject>
#include <QDebug>
#include <QImage>
#include <QPixmap>
#include <QGuiApplication>
#include <QScreen>
#include <QTimer>
#include <QProcess>
#include <QSettings>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QDir>
#include <QDateTime>
#include <QScreen>

#include "Windows.h"



class SonyRemote : public QQuickPaintedItem
{
    Q_OBJECT
//    Q_PROPERTY(QString actTakePictureFilePath READ actTakePictureFilePath)
    Q_PROPERTY(QString saveFolder READ getSaveFolder WRITE setSaveFolder)
    Q_PROPERTY(QString readyFlag READ readyFlag)
    Q_PROPERTY(bool flipHorizontally READ isFlipHorizontally WRITE setFlipHorizontally)
    Q_PROPERTY(bool liveviewRunning READ isLiveviewRunning WRITE setLiveviewRunning)
public:
    SonyRemote(QQuickItem *parent = nullptr);
    void paint(QPainter *painter);
    QString getSaveFolder();
    void setSaveFolder(const QString &getSaveFolder);
//    QString actTakePictureFilePath();
    bool readyFlag();

signals:
    void actTakePictureCompleted(QString filePath);
    void liveViewReady();
    void exposureSignal(int exposure);
    void batteryPercentageSignal(int percent);
    void evSignal(const QString &ev);

public slots:
    void start();
    void stop();
    void resumeLiveview();
    void pauseLiveview();
    void restart();
    void actTakePicture();
    void actTakePictureReply();
    void actHalfPressShutter();
    void cancelHalfPressShutter();
    void setExposureCompensation(int exposure);
    void getExposureCompensation();
    void getBatteryPercentage();
    void getEV();
    QString getSaveDir();

    bool isHostConnected();
    bool isFlipHorizontally();
    bool isLiveviewRunning();
    void setFlipHorizontally(bool hFlip);
    void getRemoteWid();
    void resizeRemoteWindow();
    void closeRemoteWindow();
    void setLiveviewRunning(bool running);
    void releaseKey();

private:
    QString m_actTakePictureFilePath;
    QString m_saveFolder;
    QString m_fileName;
    bool m_readyFlag = true;
    bool m_hostConnected = false;
    bool m_flipHorizontally = false;
    bool m_liveviewRunning = false;

    QPixmap originalPixmap;
    WId liveviewWid;
    QProcess *remoteProc;
    QTimer *liveviewUpdateTimer = new QTimer(this);
    QTimer *actTakePictureTimer = new QTimer(this);
    QTimer *checkRemoteHwndTimer = new QTimer(this);
    HWND remoteHwnd;
    uint keycode;
    QScreen *screen = QGuiApplication::primaryScreen();

};



#endif // SONYREMOTE_H
