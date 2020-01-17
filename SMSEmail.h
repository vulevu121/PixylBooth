#ifndef SMSEMAIL_H
#define SMSEMAIL_H

#include <QObject>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QJsonObject>

class SMSEmail : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString smsPath READ smsPath WRITE setSmsPath)
    Q_PROPERTY(QString emailPath READ emailPath WRITE setEmailPath)
public:
    explicit SMSEmail(QObject *parent = nullptr);
    QString smsPath();
    void setSmsPath(const QString &path);
    QString emailPath();
    void setEmailPath(const QString &path);

signals:

public slots:
    bool sendSms(const QString &phone, const QString &carrier, const QStringList &photoPaths);
    bool sendEmail(const QString &email, const QStringList &photoPaths);
    bool saveJson(const QString &path, const QJsonDocument &doc);
    QJsonDocument loadJson(const QString &path);

private:
//    QString smsPath = "C:/Users/vulevu/Documents/SMSEmail/SMS.txt";
//    QString emailPath = "C:/Users/vulevu/Documents/SMSEmail/Email.txt";
    QString m_smsPath = "";
    QString m_emailPath = "";
};

#endif // SMSEMAIL_H
