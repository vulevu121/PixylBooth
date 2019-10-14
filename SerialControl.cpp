#include "SerialControl.h"

SerialControl::SerialControl()
{
//    m_serial = new QSerialPort(this);

    auto list = QSerialPortInfo::availablePorts();
    if (list.length() > 0){
        foreach(QSerialPortInfo port, list){
            qDebug() << port.description();
            qDebug() << port.manufacturer();
            qDebug() << port.portName();

            if (port.description() == "Arduino Uno"){
                m_serial = new QSerialPort(this);
                m_serial->setPort(port);
            }
        }
        connect(m_serial,SIGNAL(readyRead()), this, SLOT(readData()));
        openSerialPort();
    }
    else{
        qDebug() << "[SerialControl] No serial device found";
    }
}



void SerialControl::readData()
{
    const QByteArray data = m_serial->readAll();
    qDebug() << "[SerialControl] Read" << data;
}



void SerialControl::openSerialPort()
{

    if (m_serial->open(QIODevice::ReadWrite))
    {
        //Connected
        m_ready = true;
        qDebug() << "[SerialControl] Connected";
        emit ready();
    }
    else
    {
        m_ready = false;
        //Open error
        qDebug() << "[SerialControl] Error:" << m_serial->errorString();
        closeSerialPort();
    }

}

/* Commands
   writeData("ColorSweep(FF0000,2)\n");
   writeData("Stop\n");
   writeData("SetColor(#A6433c)\n");
   writeData("Flash(#ffffaf,2,1)\n");
   writeData("FadeIn(#ffff00,2)\n");
   writeData("FadeOut(3)\n");

*/

void SerialControl::writeData(const QByteArray &data)
{
    if (!m_ready)
        return;
    qDebug() << "[SerialControl] Writing" << data;
    m_serial->write(data + "\n");
}

void SerialControl::closeSerialPort()
{
    qDebug() << "[SerialControl] Closing port";
    if (m_serial->isOpen())
        m_serial->close();
}
