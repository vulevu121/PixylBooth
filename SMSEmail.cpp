#include "SMSEmail.h"

SMSEmail::SMSEmail(QObject *parent) : QObject(parent)
{

}

QString SMSEmail::smsPath()
{
    return m_smsPath;
}

void SMSEmail::setSmsPath(const QString &path)
{
    if (path != m_smsPath) {
        m_smsPath = path;
    }
}

QString SMSEmail::emailPath()
{
    return m_emailPath;
}

void SMSEmail::setEmailPath(const QString &path)
{
    if (path != m_emailPath) {
        m_emailPath = path;
    }
}

QJsonDocument SMSEmail::loadJson(const QString &path)
{
    QFile file(path);
    QJsonDocument doc;
    if (file.open(QIODevice::ReadOnly)) {
        doc = QJsonDocument::fromJson(file.readAll());
        file.close();
    }
    else {
        qWarning("Could not open sms file for reading.");
    }
    return doc;
}

bool SMSEmail::saveJson(const QString &path, const QJsonDocument &doc)
{
    QByteArray array = doc.toJson();

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning("Could not open sms file for writing.");
        return false;
    }

    file.write(array);
    file.close();

//    qDebug() << path;
    return true;
}

bool SMSEmail::sendSms(const QString &phone, const QString &carrier, const QStringList &photoPaths)
{
    QJsonDocument doc(loadJson(m_smsPath));
    QJsonArray array = doc.array();
    QJsonArray photoPathsArray;

    foreach (const QString &s, photoPaths) {
//        QJsonObject pathObj {
//            {"path", s}
//        };
        photoPathsArray.append(s);
    }

    QJsonObject photoPathsObj {
        {"Phone", phone},
        {"Carrier", carrier},
        {"PhotoPaths", photoPathsArray},
        {"Status", ""}
    };

    array.append(QJsonValue(photoPathsObj));
    doc.setArray(array);

//    qDebug() << doc;

    return saveJson(m_smsPath, doc);
}

bool SMSEmail::sendEmail(const QString &email, const QStringList &photoPaths)
{
    QJsonDocument doc(loadJson(m_emailPath));
    QJsonArray array = doc.array();
    QJsonArray photoPathsArray;

    foreach (const QString &s, photoPaths) {
//        QJsonObject pathObj {
//            {"path", s}
//        };
        photoPathsArray.append(s);
    }

    QJsonObject photoPathsObj {
        {"Email", email},
        {"PhotoPaths", photoPathsArray},
        {"Status", ""}
    };

    array.append(QJsonValue(photoPathsObj));
    doc.setArray(array);
//    qDebug() << doc;
    return saveJson(m_emailPath, doc);
}

