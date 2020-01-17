#include "JSONSupport.h"



JSONSupport::JSONSupport(QObject *parent) : QObject(parent)
{

}

QJsonDocument JSONSupport::loadJson(const QString &path)
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

bool JSONSupport::saveJson(const QString &path, const QJsonDocument &doc)
{
    QByteArray array = doc.toJson();

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning("Could not open sms file for writing.");
        return false;
    }

    file.write(array);
    file.close();
    return true;
}

bool JSONSupport::sendSms(const QString &phone, const QString &carrier, QStringList photoPaths)
{
    QJsonDocument doc(loadJson(smsPath));
    QJsonArray array = doc.array();
    QJsonArray photoPathsArray;

    foreach (const QString &s, photoPaths) {
        QJsonObject pathObj {
            {"path", s}
        };
        photoPathsArray.append(pathObj);
    }

    QJsonObject photoPathsObj {
        {"Phone", phone},
        {"Carrier", carrier},
        {"PhotoPaths", photoPathsArray},
        {"Status", ""}
    };

    array.append(QJsonValue(photoPathsObj));
    doc.setArray(array);
    return saveJson(smsPath, doc);
}

bool JSONSupport::sendEmail(const QString &email, QStringList photoPaths)
{
    QJsonDocument doc(loadJson(emailPath));
    QJsonArray array = doc.array();
    QJsonArray photoPathsArray;

    foreach (const QString &s, photoPaths) {
        QJsonObject pathObj {
            {"path", s}
        };
        photoPathsArray.append(pathObj);
    }

    QJsonObject photoPathsObj {
        {"Phone", email},
        {"PhotoPaths", photoPathsArray},
        {"Status", ""}
    };

    array.append(QJsonValue(photoPathsObj));
    doc.setArray(array);
    return saveJson(emailPath, doc);
}

