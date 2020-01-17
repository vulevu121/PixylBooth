#ifndef JSONSUPPORT_H
#define JSONSUPPORT_H

#include <QObject>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QJsonObject>

class JSONSupport : public QObject
{
    Q_OBJECT
public:
    explicit JSONSupport(QObject *parent = nullptr);

signals:

public slots:
    bool sendSms(const QString &phone, const QString &carrier, QStringList photoPaths);
    bool sendEmail(const QString &email, QStringList photoPaths);
    bool saveJson(const QString &path, const QJsonDocument &doc);
    QJsonDocument loadJson(const QString &path);

private:
    QString smsPath = "C:/Users/vulevu/Documents/JSONSupport/SMS.txt";
    QString emailPath = "C:/Users/vulevu/Documents/JSONSupport/Email.txt";
};

#endif // JSONSUPPORT_H
