#ifndef SERIALCONTROL_H
#define SERIALCONTROL_H

#include <QObject>
#include <QSerialPortInfo>
#include <QSerialPort>
#include <QDebug>

class SerialControl : public QObject
{
    Q_OBJECT
public:
    SerialControl();

signals:
    void getData(const QByteArray &data);
    void ready();

public slots:
    void writeData(const QByteArray &data);
    void readData();
    void openSerialPort();
    void closeSerialPort();

private:
    QSerialPort *m_serial = nullptr;
    bool m_ready = false;
};

#endif // SERIALCONTROL_H
