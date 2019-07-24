#ifndef GOOGLEPHOTOQUEU_H
#define GOOGLEPHOTOQUEU_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QUrl>
#include "gmail.h"
#include "googlephoto.h"
#include "googleoauth2.h"

class GooglePhotoQueu: public QObject
{
    Q_OBJECT
public:
    explicit GooglePhotoQueu(QObject *parent = nullptr);

    GMAIL email;
    GooglePhoto  p;
};

#endif // GOOGLEPHOTOQUEU_H
