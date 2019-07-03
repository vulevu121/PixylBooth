#ifndef GPHOTO_H
#define GPHOTO_H


#include <QObject>
#include <QOAuth2AuthorizationCodeFlow>
#include <QNetworkReply>
#include <QAbstractOAuth2>

class GooglePhoto : public QObject
{
    Q_OBJECT
public:
    explicit GooglePhoto(QObject *parent = nullptr);

private slots:
    void grant();
    void granted();
    void authStatusChanged(QAbstractOAuth::Status status);
private:
    QOAuth2AuthorizationCodeFlow  google;
};

#endif // GPHOTO_H
