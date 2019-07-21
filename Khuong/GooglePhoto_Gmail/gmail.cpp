#include "gmail.h"

GMAIL::GMAIL(QObject *parent) : QObject(parent)
{
    accessToken = QString("ya29.GlxJB30WnIvGJ9IjDMPHxqspVhVOs5VntOmhy1uThP6kDKdC37FMlLnN0q7YzIJzVML46GBpM3_ptHOaNHp5dxfEzRNYuJA4De0E12jQL4HJb9esJo_9ulw_qtKFFA");
    albumURL = QString("https://photos.app.goo.gl/U59jf5pMxV1FHV4H8");
    SendEmail();

}
void GMAIL::SendEmail(){
    qDebug() << "Sending email with link...";

    if (manager == nullptr) {
         manager = new QNetworkAccessManager(this);
     }

    QString message ("From: khuongnguyensac@gmail.com\n"
                    "To: khuong.dinh.ng@gmail.com,vulevu121@gmail.com,timz1992@yahoo.com  \n"
                     "Subject: Sending Email is DONE!\n"
                     "\n"
                     "Time to up the pricing!\n"
                     "Shareable Album Link:" + albumURL );

    QByteArray encoded = message.toUtf8().toBase64(QByteArray::Base64UrlEncoding);
//    qDebug() << encoded ;


    /* Ensure encoded message is URL safe */
    encoded.replace("+","-");
    encoded.replace("/","_");
//    encoded.replace("=","*");

    qDebug() << encoded ;

    QJsonObject jsonObj;
    jsonObj ["raw"] = QString(encoded);


    QJsonDocument doc (jsonObj);

    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

    QString endPoint ("https://www.googleapis.com/gmail/v1/users/");
    QUrl sendURL(endPoint + "me"+ "/messages/send");
    QNetworkRequest sendReq(sendURL);
//    qDebug() << sendURL;

    sendReq.setRawHeader("Authorization","Bearer "+ accessToken.toUtf8());
    sendReq.setRawHeader("Content-Type","application/json");
    sendReq.setRawHeader("Content-Length", postDataSize);

    manager->post(sendReq,jsonRequest);

    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(SendEmailReply(QNetworkReply*)));
}

void GMAIL::SendEmailReply(QNetworkReply * reply){
    if(reply->error()) {
        qDebug() << "Sending Email Error" << reply->readAll();
        manager->disconnect();

    } else {
        qDebug() << "Sending Email Success";

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();

        qDebug() << jsonObj;

        manager->disconnect();

     }

}
